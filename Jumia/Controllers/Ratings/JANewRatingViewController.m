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
#import "RIRatings.h"
#import "JADynamicForm.h"
#import "JAAddRatingView.h"
#import "RICustomer.h"
#import "JAPriceView.h"
#import "JAUtils.h"
#import "RIProduct.h"

@interface JANewRatingViewController ()
<
UITextFieldDelegate,
UIAlertViewDelegate
>

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
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
    
    self.topView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.brandLabel.text = self.product.brand;
    self.brandLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.nameLabel.text = self.product.name;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self ratingsRequests];
}

- (void)ratingsRequests
{
    self.numberOfRequests = 0;
    
    [self hideViews];
//    if(RIApiResponseSuccess != self.apiResponse)
//    {
//        if(VALID_NOTEMPTY(self.ratingDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.ratingDynamicForm.formViews, NSMutableArray))
//        {
//            [self showLoading];
//        }
//        
//        self.apiResponse = RIApiResponseSuccess;
//    }
//    else
//    {
//        [self showLoading];
//    }

    //$$$ TIMEOUT
    [self showLoading];
    
//    [RIRatings getRatingsWithSuccessBlock:^(NSArray *ratings)
//     {
//         self.ratings = ratings;
//         self.numberOfRequests--;
//     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages)
//     {
//         self.apiResponse = apiResponse;
//         self.numberOfRequests--;
//     }];

    
    if ([[RICountryConfiguration getCurrentConfiguration].ratingIsEnabled boolValue]) {
        self.numberOfRequests++;
        [RIForm getForm:@"rating"
           successBlock:^(RIForm *form)
         {
             self.ratingsForm = form;
             self.numberOfRequests--;
         } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
             self.apiResponse = apiResponse;
             self.numberOfRequests--;
         }];
    }
    
    if ([[RICountryConfiguration getCurrentConfiguration].reviewIsEnabled boolValue]) {
        self.numberOfRequests++;
        [RIForm getForm:@"review"
           successBlock:^(RIForm *form)
         {
             self.reviewsForm = form;
             self.numberOfRequests--;
         } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
             self.apiResponse = apiResponse;
             self.numberOfRequests--;
         }];
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
//$$$ TIMEOUT
//    else if (RIApiResponseNoInternetConnection == self.apiResponse)
//    {
//        if(VALID_NOTEMPTY(self.ratingDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.ratingDynamicForm.formViews, NSMutableArray))
//        {
//            [self showMessage:STRING_NO_CONNECTION success:NO];
//        }
//        else
//        {
//            [self showErrorView:YES startingY:0.0f selector:@selector(ratingsRequests) objects:nil];
//        }
//    }
//    else
//    {
//        if(VALID_NOTEMPTY(self.ratingDynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.ratingDynamicForm.formViews, NSMutableArray))
//        {
//            [self showMessage:STRING_ERROR success:NO];
//        }
//        else
//        {
//            [self showErrorView:NO startingY:0.0f selector:@selector(ratingsRequests) objects:nil];
//        }
//    }
    
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
            specialPriceOnTheLeft:NO];
    
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

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self hideViews];
    
    [self showLoading];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self hideLoading];
    
    if(UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation || UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)
    {
        NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
        [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"animated"];
        
        if(VALID_NOTEMPTY(self.productRatings, RIProductRatings) && VALID_NOTEMPTY(self.productRatings.comments, NSArray))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification object:nil userInfo:userInfo];
        }
        else
        {
            if(VALID_NOTEMPTY(self.product, RIProduct))
            {
                [userInfo setObject:self.product forKey:@"product"];
            }
            
            [userInfo setObject:[NSNumber numberWithBool:self.goToNewRatingButtonPressed] forKey:@"goToNewRatingButtonPressed"];
            
            [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"popLastViewController"];
            [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"animated"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowRatingsScreenNotification object:nil userInfo:userInfo];
        }
    }
    else
    {
        [self.topView setHidden:NO];
        [self.scrollView setHidden:NO];
    }
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
    
    if(VALID(self.centerView, UIView))
    {
        [self.centerView removeFromSuperview];
    }
    self.centerView = [[UIView alloc] init];
    self.centerView.backgroundColor = [UIColor whiteColor];
    self.centerView.layer.cornerRadius = 5.0f;
    
    CGFloat centerViewWidth = scrollViewWidth - (2 * horizontalMargin);
    CGFloat dynamicFormHorizontalMargin = 6.0f;
    if(isiPad)
    {
        dynamicFormHorizontalMargin = 60.0f;
    }
    
    if(VALID_NOTEMPTY(self.fixedLabel, UILabel))
    {
        [self.fixedLabel removeFromSuperview];
    }
    
    self.fixedLabel = [[UILabel alloc] initWithFrame:CGRectMake(dynamicFormHorizontalMargin,
                                                                verticalMargin,
                                                                centerViewWidth - (2 * dynamicFormHorizontalMargin),
                                                                16.0f)];
    self.fixedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    self.fixedLabel.text = STRING_RATE_PRODUCT;
    self.fixedLabel.textColor = UIColorFromRGB(0x666666);
    
    [self.centerView addSubview:self.fixedLabel];

    CGFloat currentY = CGRectGetMaxY(self.fixedLabel.frame) + 12.0f;
    CGFloat spaceBetweenFormFields = 6.0f;
    
    if (self.ratingsForm) {
        NSInteger count = 0;
        CGFloat initialContentY = 0;
        self.ratingsDynamicForm = [[JADynamicForm alloc] initWithForm:self.ratingsForm
                                                             delegate:nil
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
                frame.size.width = centerViewWidth - (2 * dynamicFormHorizontalMargin);
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
    
    if (self.reviewsForm) {
        CGFloat initialContentY = 0;
        self.reviewsDynamicForm = [[JADynamicForm alloc] initWithForm:self.reviewsForm
                                                             delegate:nil
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
                frame.size.width = centerViewWidth - (2 * dynamicFormHorizontalMargin);
            }
            else
            {
                frame.size.width = centerViewWidth;
            }
            view.frame = frame;
            
            [self.reviewsContentView addSubview:view];

            initialContentY += view.frame.size.height + spaceBetweenFormFields;
        }
        initialContentY += kDistanceBetweenStarsAndText;
        [self.reviewsContentView setFrame:CGRectMake(0.0,
                                                     currentY,
                                                     centerViewWidth,
                                                     initialContentY)];
        [self.centerView addSubview:self.reviewsContentView];
    }


    if (self.isShowingRating && VALID_NOTEMPTY(self.ratingsContentView, UIView)) {
        self.reviewsContentView.hidden = YES;
        currentY += self.ratingsContentView.frame.size.height;
    } else if (NO != self.isShowingRating && VALID_NOTEMPTY(self.reviewsContentView, UIView)){
        self.ratingsContentView.hidden = NO;
        currentY += self.reviewsContentView.frame.size.height;
    }
    
    if (VALID_NOTEMPTY(self.ratingsForm, RIForm) && VALID_NOTEMPTY(self.reviewsForm, RIForm)) {
        //show the switch
        self.modeSwitch = [UISwitch new];
        [self.modeSwitch addTarget:self action:@selector(switchBetweenModes) forControlEvents:UIControlEventTouchUpInside];
        [self.modeSwitch setFrame:CGRectMake(10.0f, currentY, self.modeSwitch.frame.size.width, self.modeSwitch.frame.size.height)];
        [self.centerView addSubview:self.modeSwitch];
        currentY += self.modeSwitch.frame.size.height + 10.0f;
    } else {
        // Add space between last form field and send review button
        currentY += 38.0f;
    }
    
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
                                                                       buttonImageNormal.size.width,
                                                                       buttonImageNormal.size.height)];
    [self.sendReviewButton setTitle:STRING_SEND_REVIEW
                           forState:UIControlStateNormal];
    [self.sendReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                forState:UIControlStateNormal];
    self.sendReviewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0f];
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
    [self.scrollView addSubview:self.centerView];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             self.centerView.frame.size.height + self.centerView.frame.origin.y);
    
    [self.scrollView setHidden:NO];
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
    [self continueSendingReview];
}

- (void)continueSendingReview
{
//    [self showLoading];
//    
//    [self.ratingDynamicForm resignResponder];
//    
//    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[self.ratingDynamicForm getValues]];
//    
//    for (JAAddRatingView *component in self.ratingStarsArray)
//    {
//        RIRatingsOptions *option = [component.ratingOptions objectAtIndex:(component.rating - 1)];
//        NSString *key = [NSString stringWithFormat:@"rating-option--%@", option.fkRatingType];
//        
//        [parameters addEntriesFromDictionary:@{key: option.value}];
//    }
//    
//    [parameters addEntriesFromDictionary:@{@"rating-customer": [RICustomer getCustomerId]}];
//    [parameters addEntriesFromDictionary:@{@"rating-catalog-sku": self.product.sku}];
//    
//    [RIForm sendForm:self.ratingDynamicForm.form
//          parameters:parameters
//        successBlock:^(id object) {
//            
//            NSNumber *price = (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f) ? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
//            
//            NSMutableDictionary *globalRateDictionary = [[NSMutableDictionary alloc] init];
//            [globalRateDictionary setObject:self.product.sku forKey:kRIEventSkuKey];
//            [globalRateDictionary setObject:self.product.brand forKey:kRIEventBrandKey];
//            [globalRateDictionary setValue:price forKey:kRIEventPriceKey];
//            
//            for (JAAddRatingView *component in self.ratingStarsArray)
//            {
//                NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
//                [trackingDictionary setValue:self.product.sku forKey:kRIEventLabelKey];
//                [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
//                [trackingDictionary setValue:@(component.rating) forKey:kRIEventValueKey];
//                
//                if ([component.idRatingType isEqualToString:@"1"])
//                {
//                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.rating] forKey:kRIEventRatingPriceKey];
//                    [trackingDictionary setValue:@"RateProductPrice" forKey:kRIEventActionKey];
//                }
//                else if ([component.idRatingType isEqualToString:@"2"])
//                {
//                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.rating] forKey:kRIEventRatingAppearanceKey];
//                    [trackingDictionary setValue:@"RateProductAppearance" forKey:kRIEventActionKey];
//                }
//                else if ([component.idRatingType isEqualToString:@"3"])
//                {
//                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.rating] forKey:kRIEventRatingQualityKey];
//                    [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
//                }
//                else
//                {
//                    // There is no indication about the default tracking for rating
//                    [globalRateDictionary setValue:[NSNumber numberWithInt:component.rating] forKey:kRIEventRatingKey];
//                    [trackingDictionary setValue:@"RateProductQuality" forKey:kRIEventActionKey];
//                }
//                
//                [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
//                [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
//                [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
//                NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//                [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
//                [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
//                
//                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProduct]
//                                                          data:[trackingDictionary copy]];
//            }
//            
//            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRateProductGlobal]
//                                                      data:[globalRateDictionary copy]];
//            
//            [self hideLoading];
//            
//            [self showMessage:STRING_REVIEW_SENT success:YES];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
//                                                                object:nil
//                                                              userInfo:nil];
//        } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
//            
//            [self hideLoading];
//            
//            if (RIApiResponseNoInternetConnection == apiResponse)
//            {
//                [self showMessage:STRING_NO_CONNECTION success:NO];
//            }
//            else if(VALID_NOTEMPTY(errorObject, NSDictionary))
//            {
//                [self.ratingDynamicForm validateFields:errorObject];
//                
//                [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
//            }
//            else if(VALID_NOTEMPTY(errorObject, NSArray))
//            {
//                [self.ratingDynamicForm checkErrors];
//                
//                [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
//            }
//            else
//            {
//                [self.ratingDynamicForm checkErrors];
//                
//                [self showMessage:STRING_ERROR success:NO];
//            }
//        }];
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

@end
