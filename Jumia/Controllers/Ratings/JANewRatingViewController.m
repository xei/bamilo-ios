//
//  JANewRatingViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANewRatingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RIForm.h"
#import "RIField.h"
#import "RIProductRatings.h"
#import "JADynamicForm.h"
#import "JAAddRatingView.h"
#import "RICustomer.h"
#import "JAPriceView.h"
#import "JAUtils.h"
#import "RIProduct.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "RICategory.h"

#define kDistanceBetweenStarsAndText 70.0f

@interface JANewRatingViewController ()
<
UITextFieldDelegate,
UIAlertViewDelegate
>{
    BOOL _didAppeared;
    BOOL _didSubViews;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) CGRect scrollViewInitialRect;
@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UILabel *fixedLabel;
@property (strong, nonatomic) UIButton *sendReviewButton;
@property (nonatomic, strong) UISwitch *modeSwitch;
@property (nonatomic, assign) BOOL isShowingRating;

@property (nonatomic, strong) RIForm* ratingsForm;
@property (nonatomic, strong) JADynamicForm* ratingsDynamicForm;
@property (nonatomic, strong) UIView* ratingsContentView;
@property (nonatomic, strong) RIForm* reviewsForm;
@property (nonatomic, strong) JADynamicForm* reviewsDynamicForm;
@property (nonatomic, strong) UIView* reviewsContentView;

@property (nonatomic, strong) JAPriceView *priceView;
@property (assign, nonatomic) NSInteger numberOfFields;

@property (assign, nonatomic) NSInteger numberOfRequests;
@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JANewRatingViewController

@synthesize numberOfRequests=_numberOfRequests;
-(void)setNumberOfRequests:(NSInteger)numberOfRequests
{
    _numberOfRequests=numberOfRequests;
    if (0 == numberOfRequests) {
        [self finishedRequests];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(VALID_NOTEMPTY(self.product.sku, NSString))
    {
        self.screenName = [NSString stringWithFormat:@"WriteRatingScreen / %@", self.product.sku];
    }
    else
    {
        self.screenName = @"WriteRatingScreen";
    }
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.brandLabel.font = [UIFont fontWithName:kFontMediumName size:self.brandLabel.font.pointSize];
    self.nameLabel.font = [UIFont fontWithName:kFontRegularName size:self.nameLabel.font.pointSize];
    
    self.brandLabel.text = self.product.brand;
    
    self.nameLabel.text = self.product.name;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboards)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
    if (!self.ratingsForm)
        [self ratingsRequests];
}

-(void) viewWillDisappear:(BOOL)animated
{
    //[super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _didAppeared = NO;
    _didSubViews = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _didAppeared = YES;
    
    if(_didSubViews)
    {
        if ([self landscapePopViewController]) {
            return;
        }
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _didSubViews = YES;
    if(_didAppeared)
       [self landscapePopViewController];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self hideViews];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if(UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation || UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)
    {
        NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
        [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"animated"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification object:self userInfo:userInfo];
    }
}

- (BOOL)landscapePopViewController
{
    if(UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation || UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)
    {
        NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
        [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"animated"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification object:self userInfo:userInfo];
        return YES;
    }
    return NO;
}

- (void)ratingsRequests
{
    _numberOfRequests = 0;
    
    [self hideViews];
    if(RIApiResponseSuccess != self.apiResponse)
    {
        if(VALID_NOTEMPTY(self.ratingsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.ratingsDynamicForm.formViews, NSMutableArray) &&
           VALID_NOTEMPTY(self.reviewsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.reviewsDynamicForm.formViews, NSMutableArray))
        {
            [self showLoading];
        }
        
        self.apiResponse = RIApiResponseSuccess;
    }
    else
    {
        [self showLoading];
    }
    typedef void (^GetReviewDynamicFormBlock)(void);
    GetReviewDynamicFormBlock getReviewFormBlock = ^void{
        [RIForm getForm:@"review"
           successBlock:^(RIForm *form)
         {
             self.reviewsForm = form;
             self.numberOfRequests--;
         } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
             self.apiResponse = apiResponse;
             self.numberOfRequests--;
         }];
    };
    typedef void (^GetRatingDynamicFormBlock)(void);
    GetRatingDynamicFormBlock getRatingFormBlock = ^void{
        [RIForm getForm:@"rating"
           successBlock:^(RIForm *form)
         {
             self.ratingsForm = form;
             self.numberOfRequests--;
         } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
             self.apiResponse = apiResponse;
             self.numberOfRequests--;
         }];
    };
    
    if ([[RICountryConfiguration getCurrentConfiguration].ratingIsEnabled boolValue]) {
        self.numberOfRequests++;
    }
    if ([[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
        self.numberOfRequests++;
    }
    if ([[RICountryConfiguration getCurrentConfiguration].ratingIsEnabled boolValue]) {
        getRatingFormBlock();
    }
    if ([[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
        getReviewFormBlock();
    }
    
    
}

- (void)hideViews
{
    [self.topView setHidden:YES];
    [self.scrollView setHidden:YES];
}

-(void)finishedRequests
{
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
    
    [self removeErrorView];
    if(RIApiResponseSuccess == self.apiResponse)
    {
        if (VALID_NOTEMPTY(self.ratingsForm, RIForm)) {
            self.isShowingRating = YES;
        } else {
            self.isShowingRating = NO;
        }
        [self setupViews];
    }

    else if (RIApiResponseNoInternetConnection == self.apiResponse)
    {
        if(VALID_NOTEMPTY(self.ratingsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.ratingsDynamicForm.formViews, NSMutableArray) &&
           VALID_NOTEMPTY(self.reviewsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.reviewsDynamicForm.formViews, NSMutableArray))
        {
            [self showMessage:STRING_NO_CONNECTION success:NO];
        }
        else
        {
            [self showErrorView:YES startingY:0.0f selector:@selector(ratingsRequests) objects:nil];
        }
    }
    else
    {
        if(VALID_NOTEMPTY(self.ratingsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.ratingsDynamicForm.formViews, NSMutableArray) &&
           VALID_NOTEMPTY(self.reviewsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.reviewsDynamicForm.formViews, NSMutableArray))
        {
            [self showMessage:STRING_ERROR success:NO];
        }
        else
        {
            [self showErrorView:NO startingY:0.0f selector:@selector(ratingsRequests) objects:nil];
        }
    }
    
    [self hideLoading];
}

-(void)setupTopView
{
    [self.brandLabel setFrame:CGRectMake(12.0f,
                                         6.0f,
                                         self.view.frame.size.width - 24.0f,
                                         self.view.frame.size.height)];
    [self.brandLabel sizeToFit];
    [self.nameLabel setFrame:CGRectMake(12.0f,
                                        CGRectGetMaxY(self.brandLabel.frame) + 6.0f,
                                        self.view.frame.size.width - 24.0f,
                                        self.view.frame.size.height)];
    [self.nameLabel sizeToFit];
    
    if(VALID(self.priceView, JAPriceView))
    {
        [self.priceView removeFromSuperview];
    }
    
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:self.product.priceFormatted
                     specialPrice:self.product.specialPriceFormatted
                         fontSize:14.0f
            specialPriceOnTheLeft:YES];
    
    self.priceView.frame = CGRectMake(12.0f,
                                      CGRectGetMaxY(self.nameLabel.frame) + 4.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.topView addSubview:self.priceView];
    
    CGFloat topViewMinHeight = CGRectGetMaxY(self.priceView.frame);
    if(topViewMinHeight < 38.0f)
    {
        topViewMinHeight = 38.0f;
    }
    topViewMinHeight += 6.0f;
    
    [self.topView setFrame:CGRectMake(0.0f,
                                      0.0f,
                                      self.view.frame.size.width,
                                      topViewMinHeight)];
    [self.topView setHidden:NO];
}

-(void)setupViews
{
    [self setupTopView];
    
    CGFloat verticalMargin = 6.0f;
    CGFloat horizontalMargin = 6.0f;
    
    BOOL isiPad = NO;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        isiPad = YES;
    }
    CGFloat scrollViewWidth = self.view.frame.size.width;
    
    [self.scrollView setFrame:CGRectMake(0.0f,
                                         CGRectGetMaxY(self.topView.frame),
                                         scrollViewWidth,
                                         self.view.frame.size.height - CGRectGetMaxY(self.topView.frame))];
    self.scrollViewInitialRect = self.scrollView.frame;

    if (!self.centerView) {
        self.centerView = [[UIView alloc] init];
        self.centerView.backgroundColor = [UIColor whiteColor];
        self.centerView.layer.cornerRadius = 5.0f;
        [self.scrollView addSubview:self.centerView];
    }
    
    CGFloat centerViewWidth = scrollViewWidth - (2 * horizontalMargin);
    CGFloat dynamicFormHorizontalMargin = 6.0f;
    if(isiPad)
    {
        dynamicFormHorizontalMargin = 250.0f;
    }
    
    if(!VALID_NOTEMPTY(self.fixedLabel, UILabel))
    {
        self.fixedLabel = [[UILabel alloc] initWithFrame:CGRectMake(dynamicFormHorizontalMargin,
                                                                    verticalMargin,
                                                                    centerViewWidth - (2 * dynamicFormHorizontalMargin),
                                                                    16.0f)];
        self.fixedLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
        self.fixedLabel.text = STRING_RATE_PRODUCT;
        self.fixedLabel.textColor = UIColorFromRGB(0x666666);
        [self.centerView addSubview:self.fixedLabel];
    }

    CGFloat currentY = CGRectGetMaxY(self.fixedLabel.frame) + 12.0f;
    CGFloat spaceBetweenFormFields = 6.0f;
    
    if (self.ratingsForm) {
        if (!self.ratingsContentView) {
            NSInteger count = 0;
            CGFloat initialContentY = 0;
            self.ratingsDynamicForm = [[JADynamicForm alloc] initWithForm:self.ratingsForm
                                                         startingPosition:initialContentY
                                                                widthSize:centerViewWidth
                                                       hasFieldNavigation:YES];
            
            self.ratingsContentView = [UIView new];
            for (UIView *view in self.ratingsDynamicForm.formViews)
            {
                view.tag = count;
                CGRect frame = view.frame;
                if(isiPad)
                {
                    frame.origin.x = dynamicFormHorizontalMargin;
                    if (![view isKindOfClass:[JAAddRatingView class]]) {
                        frame.size.width = centerViewWidth - (2 * dynamicFormHorizontalMargin);
                    }
                }
                else
                {
                    frame.size.width = centerViewWidth;
                }
                
                view.frame = frame;
                
                [self.ratingsContentView addSubview:view];
                initialContentY += view.frame.size.height + spaceBetweenFormFields;
                count++;
            }
            
            [self.ratingsContentView setFrame:CGRectMake(0.0,
                                                         currentY,
                                                         centerViewWidth,
                                                         initialContentY)];
            [self.centerView addSubview:self.ratingsContentView];
        }
        
    }
    
    if (self.reviewsForm) {
        if (!self.reviewsContentView)
        {
            CGFloat initialContentY = 0;
            self.reviewsDynamicForm = [[JADynamicForm alloc] initWithForm:self.reviewsForm
                                                         startingPosition:initialContentY
                                                                widthSize:centerViewWidth
                                                       hasFieldNavigation:YES];
            self.reviewsContentView = [UIView new];
            for (int i = 0; i < self.reviewsDynamicForm.formViews.count; i++)
            {
                UIView* view = [self.reviewsDynamicForm.formViews objectAtIndex:i];
                view.tag = i;
                CGRect frame = view.frame;
                if(isiPad)
                {
                    frame.origin.x = dynamicFormHorizontalMargin;
                    if (NO == [view isKindOfClass:[JAAddRatingView class]]) {
                        frame.size.width = centerViewWidth - (2 * dynamicFormHorizontalMargin);
                    }else
                        frame.size.width = centerViewWidth;
                }
                else
                {
                    frame.size.width = centerViewWidth;
                }
                if (NO == [view isKindOfClass:[JAAddRatingView class]]) {
                    if (VALID_NOTEMPTY(self.ratingsForm, RIForm) && VALID_NOTEMPTY(self.reviewsForm, RIForm)) {
                        //has switch
                        frame.origin.y = frame.origin.y + kDistanceBetweenStarsAndText;
                        frame.size.width = centerViewWidth - (2 * dynamicFormHorizontalMargin);
                    }
                }
                
                view.frame = frame;
                
                [self.reviewsContentView addSubview:view];

                initialContentY += view.frame.size.height + spaceBetweenFormFields;
            }
            
            if (VALID_NOTEMPTY(self.ratingsForm, RIForm) && VALID_NOTEMPTY(self.reviewsForm, RIForm)) {
                //has switch
                initialContentY += kDistanceBetweenStarsAndText;
            }
            [self.reviewsContentView setFrame:CGRectMake(0.0,
                                                         currentY,
                                                         centerViewWidth,
                                                         initialContentY)];
            [self.centerView addSubview:self.reviewsContentView];
        }
    }

    CGFloat modeSwitchY = currentY + self.ratingsContentView.frame.size.height;
    
    if (self.isShowingRating && VALID_NOTEMPTY(self.ratingsContentView, UIView)) {
        self.reviewsContentView.hidden = YES;
        currentY += self.ratingsContentView.frame.size.height;
    } else if (NO == self.isShowingRating && VALID_NOTEMPTY(self.reviewsContentView, UIView)){
        self.ratingsContentView.hidden = NO;
        currentY += self.reviewsContentView.frame.size.height;
    }
    
    if (VALID_NOTEMPTY(self.ratingsForm, RIForm) && VALID_NOTEMPTY(self.reviewsForm, RIForm)) {
        if (!self.modeSwitch) {
            //show the switch
            self.modeSwitch = [UISwitch new];
            [self.modeSwitch addTarget:self action:@selector(switchBetweenModes) forControlEvents:UIControlEventTouchUpInside];
            [self.modeSwitch setY:modeSwitchY];
            [self.centerView addSubview:self.modeSwitch];
            
            CGFloat modeSwitchX = 10.0f;
            if (isiPad) {
                modeSwitchX = 260.0f;
            }
            [self.modeSwitch setX:modeSwitchX];
            
            CGFloat writeReviewLabelX = CGRectGetMaxX(self.modeSwitch.frame) + 15.0f;
            CGFloat maxWriteReviewWidth = centerViewWidth - writeReviewLabelX;
            UILabel* writeReviewLabel = [UILabel new];
            writeReviewLabel.textColor = UIColorFromRGB(0x666666);
            writeReviewLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
            writeReviewLabel.numberOfLines = 2;
            writeReviewLabel.text = STRING_WRITE_FULL_REVIEW;
            [writeReviewLabel sizeToFit];
            CGFloat finalWidth = writeReviewLabel.frame.size.width;
            CGFloat finalHeight = writeReviewLabel.frame.size.height;
            CGFloat yOffset = 5.0f;
            if (maxWriteReviewWidth < writeReviewLabel.frame.size.width) {
                finalWidth = maxWriteReviewWidth;
                finalHeight *= 2;
                yOffset = 0.0f;
            }
            [writeReviewLabel setFrame:CGRectMake(writeReviewLabelX,
                                                  self.modeSwitch.frame.origin.y + yOffset,
                                                  finalWidth,
                                                  finalHeight)];
            [self.centerView addSubview:writeReviewLabel];
            
        }
        
        currentY += self.modeSwitch.frame.size.height + 50.0f;
    } else {
        // Add space between last form field and send review button
        currentY += 38.0f;
    }
    
    if (!self.sendReviewButton) {
        NSString *imageNameFormat = @"orangeMedium_%@";
        if(isiPad)
        {
            imageNameFormat = @"orangeMediumPortrait_%@";
        }
        UIImage* buttonImageNormal = [UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, @"normal"]];
        UIImage* buttonImageHighlighted = [UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, @"highlighted"]];
        UIImage* buttonImageDisabled = [UIImage imageNamed:[NSString stringWithFormat:imageNameFormat, @"disabled"]];
        self.sendReviewButton = [[UIButton alloc] initWithFrame:CGRectMake(6.0f,
                                                                           currentY,
                                                                           centerViewWidth - 12.f,
                                                                           buttonImageNormal.size.height)];
        [self.sendReviewButton setTitle:STRING_SEND_REVIEW
                               forState:UIControlStateNormal];
        [self.sendReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                    forState:UIControlStateNormal];
        self.sendReviewButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:16.0f];
        [self.sendReviewButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        [self.sendReviewButton setBackgroundImage:buttonImageHighlighted forState:UIControlStateHighlighted];
        [self.sendReviewButton setBackgroundImage:buttonImageHighlighted forState:UIControlStateSelected];
        [self.sendReviewButton setBackgroundImage:buttonImageDisabled forState:UIControlStateDisabled];
        [self.sendReviewButton addTarget:self action:@selector(sendReview:) forControlEvents:UIControlEventTouchUpInside];
        [self.centerView addSubview:self.sendReviewButton];
        
        [self.centerView setFrame:CGRectMake(horizontalMargin,
                                             verticalMargin,
                                             centerViewWidth,
                                             CGRectGetMaxY(self.sendReviewButton.frame) + verticalMargin)];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                                 self.centerView.frame.size.height + self.centerView.frame.origin.y);
    
        [self.scrollView setHidden:NO];
        
        if (RI_IS_RTL) {
            [self.view flipAllSubviews];
        }
        
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Send review

- (void)sendReview:(id)sender
{
    [self showLoading];
    
    [self.ratingsDynamicForm resignResponder];
    [self.reviewsDynamicForm resignResponder];
    
    RIForm* currentForm;
    JADynamicForm* currentDynamicForm;
    if (self.isShowingRating) {
        currentForm = self.ratingsForm;
        currentDynamicForm = self.ratingsDynamicForm;
        if ([[RICountryConfiguration getCurrentConfiguration].ratingRequiresLogin boolValue] && NO == [RICustomer checkIfUserIsLogged]) {
            [self hideLoading];
            NSMutableDictionary* userInfoLogin = [[NSMutableDictionary alloc] init];
            [userInfoLogin setObject:[NSNumber numberWithBool:NO] forKey:@"from_side_menu"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification object:nil userInfo:userInfoLogin];
            return;
        }
    } else {
        currentForm = self.reviewsForm;
        currentDynamicForm = self.reviewsDynamicForm;
        if ([[RICountryConfiguration getCurrentConfiguration].reviewRequiresLogin boolValue] && NO == [RICustomer checkIfUserIsLogged]) {
            [self hideLoading];
            NSMutableDictionary* userInfoLogin = [[NSMutableDictionary alloc] init];
            [userInfoLogin setObject:[NSNumber numberWithBool:NO] forKey:@"from_side_menu"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification object:nil userInfo:userInfoLogin];
            return;
        }
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[currentDynamicForm getValues]];
    
    [parameters addEntriesFromDictionary:@{@"rating-customer": [RICustomer getCustomerId]}];
    NSString* skuKey = [currentDynamicForm getFieldNameForKey:@"sku"];
    [parameters addEntriesFromDictionary:@{skuKey: self.product.sku}];
    
    [RIForm sendForm:currentForm
          parameters:parameters
        successBlock:^(id object) {
            
            NSNumber *price = (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f) ? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
            
            NSMutableDictionary *globalRateDictionary = [[NSMutableDictionary alloc] init];
            [globalRateDictionary setObject:self.product.sku forKey:kRIEventSkuKey];
            [globalRateDictionary setObject:self.product.brand forKey:kRIEventBrandKey];
            [globalRateDictionary setValue:price forKey:kRIEventPriceKey];
            [globalRateDictionary setValue:[RICategory getCategoryName:[self.product.categoryIds firstObject]] forKey:kRIEventCategoryNameKey];
            [globalRateDictionary setValue:[RICategory getCategoryName:[self.product.categoryIds lastObject]] forKey:kRIEventSubCategoryNameKey];
            
            for (UIView *component in currentDynamicForm.formViews)
            {
                if ([component isKindOfClass:[JAAddRatingView class]]) {
                    
                    JAAddRatingView* ratingView = (JAAddRatingView*)component;
                    
                    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                    [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
                    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                    [trackingDictionary setValue:@(ratingView.rating) forKey:kRIEventValueKey];
                    
                    if ([ratingView.fieldRatingStars.type isEqualToString:@"1"])
                    {
                        [globalRateDictionary setValue:[NSNumber numberWithInteger:ratingView.rating] forKey:kRIEventRatingPriceKey];
                        [trackingDictionary setValue:@"RateProductPrice" forKey:kRIEventActionKey];
                    }
                    else if ([ratingView.fieldRatingStars.type isEqualToString:@"2"])
                    {
                        [globalRateDictionary setValue:[NSNumber numberWithInteger:ratingView.rating] forKey:kRIEventRatingAppearanceKey];
                        [trackingDictionary setValue:@"RateProductAppearance" forKey:kRIEventActionKey];
                    }
                    else if ([ratingView.fieldRatingStars.type isEqualToString:@"3"])
                    {
                        [globalRateDictionary setValue:[NSNumber numberWithInteger:ratingView.rating] forKey:kRIEventRatingQualityKey];
                        [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
                    }
                    else
                    {
                        // There is no indication about the default tracking for rating
                        [globalRateDictionary setValue:[NSNumber numberWithInteger:ratingView.rating] forKey:kRIEventRatingKey];
                        [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
                    }
                    
                    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                    [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
                    
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProduct]
                                                              data:[trackingDictionary copy]];
                    
                    float value = [@(ratingView.rating) floatValue];
                    [FBSDKAppEvents logEvent:FBSDKAppEventNameRated
                               valueToSum:value
                               parameters:@{FBSDKAppEventParameterNameContentType: self.product.name,
                                            FBSDKAppEventParameterNameContentID: self.product.sku,
                                            FBSDKAppEventParameterNameMaxRatingValue: @5 }];
                }
            }
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProductGlobal]
                                                      data:[globalRateDictionary copy]];
            
            [self hideLoading];
            
            [self showMessage:STRING_REVIEW_SENT success:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kCloseTopTwoScreensNotification
                                                                object:nil
                                                              userInfo:nil];
        } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
            
            [self hideLoading];
            
            if (RIApiResponseNoInternetConnection == apiResponse)
            {
                [self showMessage:STRING_NO_CONNECTION success:NO];
            }
            else if(VALID_NOTEMPTY(errorObject, NSDictionary))
            {
                [currentDynamicForm validateFields:errorObject];
                
                [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
            }
            else if(VALID_NOTEMPTY(errorObject, NSArray))
            {
                [currentDynamicForm checkErrors];
                
                [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
            }
            else
            {
                [currentDynamicForm checkErrors];
                
                [self showMessage:STRING_ERROR success:NO];
            }
        }];
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark - Keyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat height = kbSize.height;
    if(self.view.frame.size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:CGRectMake(self.scrollViewInitialRect.origin.x,
                                             self.scrollViewInitialRect.origin.y,
                                             self.scrollViewInitialRect.size.width,
                                             self.scrollViewInitialRect.size.height - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:self.scrollViewInitialRect];
    }];
}

#pragma mark - Switch

- (void)switchBetweenModes
{
    [self.reviewsDynamicForm resignResponder];
    [self.ratingsDynamicForm resignResponder];
    
    for (int i = 0; i < self.ratingsDynamicForm.formViews.count; i++) {
        JAAddRatingView* ratingView = [self.ratingsDynamicForm.formViews objectAtIndex:i];
        JAAddRatingView* reviewView = [self.reviewsDynamicForm.formViews objectAtIndex:i];
        
        if (VALID_NOTEMPTY(ratingView, JAAddRatingView) && VALID_NOTEMPTY(reviewView, JAAddRatingView)) {
            if (self.isShowingRating) {
                reviewView.rating = ratingView.rating;
            } else {
                ratingView.rating = reviewView.rating;
            }
        }
    }
    
    self.isShowingRating = !self.isShowingRating;
    
    CGFloat difference = self.ratingsContentView.frame.size.height - self.reviewsContentView.frame.size.height + kDistanceBetweenStarsAndText;
    if (self.isShowingRating) {
        self.ratingsContentView.hidden = NO;
        self.reviewsContentView.hidden = YES;
    } else {
        difference = -difference;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        [self.sendReviewButton setFrame:CGRectMake(self.sendReviewButton.frame.origin.x,
                                                   self.sendReviewButton.frame.origin.y + difference,
                                                   self.sendReviewButton.frame.size.width,
                                                   self.sendReviewButton.frame.size.height)];
        [self.centerView setFrame:CGRectMake(self.centerView.frame.origin.x,
                                             self.centerView.frame.origin.y,
                                             self.centerView.frame.size.width,
                                             self.centerView.frame.size.height + difference)];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                                 self.centerView.frame.size.height + self.centerView.frame.origin.y);
    } completion:^(BOOL finished) {
        //do this only after animation
        if (NO == self.isShowingRating) {
            self.ratingsContentView.hidden = YES;
            self.reviewsContentView.hidden = NO;
        }
    }];
}

-(void)hideKeyboards
{
    [self.reviewsDynamicForm resignResponder];
}
@end
