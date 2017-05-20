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
#import "JAProductInfoPriceLine.h"
#import "JAUtils.h"
#import "RIProduct.h"
#import "RICategory.h"

#define kDistanceBetweenStarsAndText 70.0f

@interface JANewRatingViewController ()
<
UITextFieldDelegate,
UIAlertViewDelegate
>{
    BOOL _didAppeared;
    BOOL _didSubViews;
    BOOL _didPressSendReviewOrKeyboard;
    
    NSMutableArray *_dynamicRatingsViewsFrames;
    NSMutableArray *_dynamicReviewsViewsFrames;
}

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) CGRect scrollViewInitialRect;
@property (strong, nonatomic) UIView *centerView;
@property (strong, nonatomic) UILabel *fixedLabel;
@property (strong, nonatomic) UILabel *writeReviewLabel;
@property (strong, nonatomic) UIButton *sendReviewButton;
@property (nonatomic, strong) UISwitch *modeSwitch;
@property (nonatomic, assign) BOOL isShowingRating;

@property (nonatomic, strong) RIForm* ratingsForm;
@property (nonatomic, strong) JADynamicForm* ratingsDynamicForm;
@property (nonatomic, strong) UIView* ratingsContentView;
@property (nonatomic, strong) RIForm* reviewsForm;
@property (nonatomic, strong) JADynamicForm* reviewsDynamicForm;
@property (nonatomic, strong) UIView* reviewsContentView;

@property (nonatomic, strong) JAProductInfoPriceLine *priceLine;
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
        [self setupViews];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _didSubViews = YES;
    if(_didAppeared)
       [self setupViews];
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

-(void)finishedRequests {
    [self publishScreenLoadTime];
    
    if(RIApiResponseSuccess == self.apiResponse) {
        if (VALID_NOTEMPTY(self.ratingsForm, RIForm)) {
            self.isShowingRating = YES;
        } else {
            self.isShowingRating = NO;
        }
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
    } else {
        if(VALID_NOTEMPTY(self.ratingsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.ratingsDynamicForm.formViews, NSMutableArray) &&
           VALID_NOTEMPTY(self.reviewsDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.reviewsDynamicForm.formViews, NSMutableArray)) {
            [self onErrorResponse:self.apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(ratingsRequests) objects:nil];
        } else {
            [self onErrorResponse:self.apiResponse messages:nil showAsMessage:NO selector:@selector(ratingsRequests) objects:nil];
        }
    }
    
    [self hideLoading];
}

-(void)setupTopView {
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
    
    
    if(VALID(self.priceLine, JAProductInfoPriceLine)) {
        [self.priceLine removeFromSuperview];
    }
    
    self.priceLine = [[JAProductInfoPriceLine alloc] initWithFrame:CGRectMake(12.0f,
                                                                              CGRectGetMaxY(self.nameLabel.frame) + 4.0f,
                                                                              self.topView.frame.size.width - 24.0f,
                                                                              15)];
    [self.priceLine setPriceSize:JAPriceSizeSmall];
    [self.priceLine setLineContentXOffset:0.f];
    
    [self.topView addSubview:self.priceLine];
    
    if (VALID_NOTEMPTY(self.product.specialPriceFormatted, NSString)) {
        [self.priceLine setPrice:self.product.specialPriceFormatted];
        [self.priceLine setOldPrice:self.product.priceFormatted];
    } else {
        [self.priceLine setPrice:self.product.priceFormatted];
        [self.priceLine setOldPrice:nil];
    }
    
    CGFloat topViewMinHeight = CGRectGetMaxY(self.priceLine.frame);
    if(topViewMinHeight < 38.0f) {
        topViewMinHeight = 38.0f;
    }
    topViewMinHeight += 6.0f;
    
    [self.topView setFrame:CGRectMake(0.0f,
                                      0.0f,
                                      self.view.frame.size.width,
                                      topViewMinHeight)];
    [self.topView setHidden:NO];
}

-(void)setupViews {
    [self setupTopView];
    
    CGFloat verticalMargin = 6.0f;
    CGFloat horizontalMargin = 6.0f;
    
    BOOL isiPad = NO;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
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
    if(isiPad) {
        dynamicFormHorizontalMargin = 200.0f;
    }
    
    if(!VALID_NOTEMPTY(self.fixedLabel, UILabel)) {
        self.fixedLabel = [[UILabel alloc] initWithFrame:CGRectMake(dynamicFormHorizontalMargin,
                                                                    verticalMargin,
                                                                    centerViewWidth - (2 * dynamicFormHorizontalMargin),
                                                                    16.0f)];
        self.fixedLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
        self.fixedLabel.text = STRING_RATE_PRODUCT;
        self.fixedLabel.textColor = JAGreyColor;
        [self.centerView addSubview:self.fixedLabel];
    } else {
        [self.fixedLabel setFrame:CGRectMake(dynamicFormHorizontalMargin,
                                            verticalMargin,
                                            centerViewWidth - (2 * dynamicFormHorizontalMargin),
                                            16.0f)];
    }
    [self.fixedLabel setTextAlignment:NSTextAlignmentLeft];

    CGFloat currentY = CGRectGetMaxY(self.fixedLabel.frame) + 12.0f;
    CGFloat spaceBetweenFormFields = 6.0f;
    
    if (self.ratingsForm) {
        NSInteger count = 0;
        CGFloat initialContentY = 0;
        
        if (!self.ratingsContentView) {
            
            self.ratingsDynamicForm = [[JADynamicForm alloc] initWithForm:self.ratingsForm
                                                         startingPosition:initialContentY
                                                                widthSize:centerViewWidth
                                                       hasFieldNavigation:YES];
            
            self.ratingsContentView = [UIView new];
            [self.centerView addSubview:self.ratingsContentView];
            
            _dynamicRatingsViewsFrames = [NSMutableArray new];
        }
        
        for (UIView *view in self.ratingsDynamicForm.formViews) {
            view.tag = count;
            
            CGRect frame = view.frame;
            if(isiPad)
            {
                frame.origin.x = dynamicFormHorizontalMargin;
            }
            view.frame = frame;
            
            if (!view.superview) {
                [self.ratingsContentView addSubview:view];
            }
            initialContentY += view.frame.size.height + spaceBetweenFormFields;
            count++;
        }
        
        [self.ratingsContentView setFrame:CGRectMake(0.0,
                                                     currentY,
                                                     centerViewWidth,
                                                     initialContentY)];
    }
    
    if (self.reviewsForm) {
        CGFloat initialContentY = 0;
        BOOL isNew = NO;
        if (!self.reviewsContentView)
        {
            self.reviewsDynamicForm = [[JADynamicForm alloc] initWithForm:self.reviewsForm
                                                         startingPosition:initialContentY
                                                                widthSize:centerViewWidth
                                                       hasFieldNavigation:YES];
            self.reviewsContentView = [UIView new];
            [self.reviewsContentView setHidden:YES];
            [self.centerView addSubview:self.reviewsContentView];
            isNew = YES;
            _dynamicReviewsViewsFrames = [NSMutableArray new];
        }
        
        for (int i = 0; i < self.reviewsDynamicForm.formViews.count; i++)
        {
            UIView* view = [self.reviewsDynamicForm.formViews objectAtIndex:i];

            view.tag = i;
            CGRect frame = view.frame;
            if(isiPad)
            {
                frame.origin.x = dynamicFormHorizontalMargin;
                frame.size.width = centerViewWidth - (2 * dynamicFormHorizontalMargin);
            }
            else
            {
                frame.size.width = centerViewWidth;
            }
            
            if (NO == [view isKindOfClass:[JAAddRatingView class]]) {
                    if (isNew) {
                        //has switch
                        frame.origin.y = frame.origin.y + kDistanceBetweenStarsAndText;
                    }
            }
            frame.size.width = centerViewWidth - (2 * dynamicFormHorizontalMargin);
            view.frame = frame;
            
            if (!view.superview) {
                [self.reviewsContentView addSubview:view];
            }

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
    }

    CGFloat modeSwitchY = currentY + self.ratingsContentView.frame.size.height;
    
    if (VALID_NOTEMPTY(self.ratingsForm, RIForm) && VALID_NOTEMPTY(self.reviewsForm, RIForm)) {
        
        if (!self.modeSwitch) {
            //show the switch
            self.modeSwitch = [UISwitch new];
            [self.modeSwitch addTarget:self action:@selector(switchBetweenModes) forControlEvents:UIControlEventTouchUpInside];
            [self.modeSwitch setY:modeSwitchY];
            [self.centerView addSubview:self.modeSwitch];
        }
        
        if (!VALID_NOTEMPTY(self.writeReviewLabel, UILabel)) {
            self.writeReviewLabel = [UILabel new];
            self.writeReviewLabel.textColor = JAGreyColor;
            self.writeReviewLabel.font = [UIFont fontWithName:kFontRegularName size:13.0f];
            self.writeReviewLabel.numberOfLines = 2;
            self.writeReviewLabel.text = STRING_WRITE_FULL_REVIEW;
            [self.writeReviewLabel sizeToFit];
            [self.centerView addSubview:self.writeReviewLabel];
        }
        
        CGFloat modeSwitchX = 10.0f;
        if (isiPad) {
            modeSwitchX = 260.0f;
        }
        [self.modeSwitch setX:modeSwitchX];
        
        CGFloat writeReviewLabelX = CGRectGetMaxX(self.modeSwitch.frame) + 15.0f;
        CGFloat maxWriteReviewWidth = centerViewWidth - writeReviewLabelX;
        
        CGFloat finalWidth = self.writeReviewLabel.frame.size.width;
        CGFloat finalHeight = self.writeReviewLabel.frame.size.height;
        CGFloat yOffset = 5.0f;
        if (maxWriteReviewWidth < self.writeReviewLabel.frame.size.width) {
            finalWidth = maxWriteReviewWidth;
            finalHeight *= 2;
            yOffset = 0.0f;
        }
        
        [self.writeReviewLabel setFrame:CGRectMake(writeReviewLabelX,
                                                   self.modeSwitch.frame.origin.y + yOffset,
                                                   finalWidth,
                                                   finalHeight)];
        
        
        
        
        //CHECK
        if (_didPressSendReviewOrKeyboard) {
            currentY -= 70.0f;
        }
        currentY += self.modeSwitch.frame.size.height + 50.0f;
    } else {
        // Add space between last form field and send review button
        currentY += 38.0f;
        [self onErrorResponse:self.apiResponse messages:nil showAsMessage:NO selector:@selector(ratingsRequests) objects:nil];
    }
    
    if (self.isShowingRating) {
        currentY = CGRectGetMaxY(self.modeSwitch.frame) + 20.f;
    } else {
        currentY = CGRectGetMaxY(self.reviewsContentView.frame) + 20.f;
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
        [self.sendReviewButton setTitleColor:JAButtonTextOrange
                                    forState:UIControlStateNormal];
        self.sendReviewButton.titleLabel.font = JADisplay3Font;
        [self.sendReviewButton setBackgroundImage:buttonImageNormal forState:UIControlStateNormal];
        [self.sendReviewButton setBackgroundImage:buttonImageHighlighted forState:UIControlStateHighlighted];
        [self.sendReviewButton setBackgroundImage:buttonImageHighlighted forState:UIControlStateSelected];
        [self.sendReviewButton setBackgroundImage:buttonImageDisabled forState:UIControlStateDisabled];
        [self.sendReviewButton addTarget:self action:@selector(sendReview:) forControlEvents:UIControlEventTouchUpInside];
        [self.centerView addSubview:self.sendReviewButton];
        
        
    }
    [self.sendReviewButton setFrame:CGRectMake(6.0f,
                                              currentY,
                                              centerViewWidth - 12.f,
                                              self.sendReviewButton.height)];
    [self.centerView setFrame:CGRectMake(horizontalMargin,
                                         verticalMargin,
                                         centerViewWidth,
                                         CGRectGetMaxY(self.sendReviewButton.frame) + verticalMargin)];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             self.centerView.frame.size.height + self.centerView.frame.origin.y);
    
    [self.scrollView setHidden:NO];
    
    if (RI_IS_RTL) {
        [self.topView flipAllSubviews];
        [self.modeSwitch flipViewPositionInsideSuperview];
        [self.writeReviewLabel flipViewPositionInsideSuperview];
        [self.fixedLabel setTextAlignment:NSTextAlignmentRight];
        CGFloat x = -200;
        for (UIView* component in self.ratingsDynamicForm.formViews) {
            if ([component isKindOfClass:[JAAddRatingView class]]) {
                [component setFrame:CGRectMake(CGRectGetMaxX(self.fixedLabel.frame) - component.frame.size.width, component.frame.origin.y, component.frame.size.width, component.frame.size.height)];
                x = component.frame.origin.x;
                break;
            }
        }
        for (UIView* component in self.reviewsDynamicForm.formViews) {
            if ([component isKindOfClass:[JAAddRatingView class]]) {
                [component setFrame:CGRectMake(x, component.frame.origin.y, component.frame.size.width, component.frame.size.height)];
                break;
            }
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
    _didPressSendReviewOrKeyboard = TRUE;
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
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:nil userInfo:userInfoLogin];
            return;
        }
    } else {
        currentForm = self.reviewsForm;
        currentDynamicForm = self.reviewsDynamicForm;
        if ([[RICountryConfiguration getCurrentConfiguration].reviewRequiresLogin boolValue] && NO == [RICustomer checkIfUserIsLogged]) {
            [self hideLoading];
            NSMutableDictionary* userInfoLogin = [[NSMutableDictionary alloc] init];
            [userInfoLogin setObject:[NSNumber numberWithBool:NO] forKey:@"from_side_menu"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:nil userInfo:userInfoLogin];
            return;
        }
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[currentDynamicForm getValues]];
    
    [parameters addEntriesFromDictionary:@{@"rating-customer": [RICustomer getCustomerId]}];
    NSString* skuKey = [currentDynamicForm getFieldNameForKey:@"sku"];
    [parameters addEntriesFromDictionary:@{skuKey: self.product.sku}];
    
    if ([currentDynamicForm checkErrors]) {
        [self onErrorResponse:RIApiResponseSuccess
                     messages:@[currentDynamicForm.firstErrorInFields]
                showAsMessage:YES
                     selector:@selector(sendReview:)
                      objects:@[sender]];
        [self hideLoading];
        return;
    }
    
    [RIForm sendForm:currentForm
          parameters:parameters
        successBlock:^(id object, NSArray* successMessages) {
            
            NSNumber *price = (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted longValue] > 0.0f) ? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
            
            NSMutableDictionary *globalRateDictionary = [[NSMutableDictionary alloc] init];
            [globalRateDictionary setObject:self.product.sku forKey:kRIEventSkuKey];
            [globalRateDictionary setObject:self.product.brand forKey:kRIEventBrandName];
            [globalRateDictionary setObject:self.product.brandUrlKey forKey:kRIEventBrandKey];
            [globalRateDictionary setValue:price forKey:kRIEventPriceKey];
            [globalRateDictionary setValue:[RICategory getCategoryName:[self.product.categoryIds firstObject]] forKey:kRIEventCategoryIdKey];
            [globalRateDictionary setValue:[RICategory getCategoryName:[self.product.categoryIds lastObject]] forKey:kRIEventSubCategoryIdKey];
            
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
                }
            }
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProductGlobal]
                                                      data:[globalRateDictionary copy]];
            
            
            [self onSuccessResponse:RIApiResponseSuccess messages:@[STRING_REVIEW_SENT] showMessage:YES];
            [self hideLoading];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kCloseTopTwoScreensNotification
                                                                object:nil
                                                              userInfo:nil];
        } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
            
            if(VALID_NOTEMPTY(errorObject, NSDictionary))
            {
                [currentDynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                    [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(sendReview:) objects:@[sender]];
                }];
            }
            else if(VALID_NOTEMPTY(errorObject, NSArray))
            {
                [currentDynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                    [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(sendReview:) objects:@[sender]];
                }];
            }
            else
            {
                [currentDynamicForm checkErrors];
                [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(sendReview:) objects:@[sender]];
            }
            
            [self hideLoading];
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
    _didPressSendReviewOrKeyboard = TRUE;
    
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:self.scrollViewInitialRect];
        [self.scrollView setContentOffset:CGPointMake(0, 0)
                                 animated:YES];
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

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    if(VALID_NOTEMPTY(self.product.sku, NSString)) {
        return [NSString stringWithFormat:@"WriteRatingScreen / %@", self.product.sku];
    } else {
        return @"WriteRatingScreen";
    }
}

@end
