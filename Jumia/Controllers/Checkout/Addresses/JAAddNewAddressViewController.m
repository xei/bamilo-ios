//
//  JAAddNewAddressViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 02/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddNewAddressViewController.h"
#import "JADynamicForm.h"
#import "JAUtils.h"
#import "JAButtonWithBlur.h"
#import "JAOrderSummaryView.h"
#import "JAPicker.h"
#import "RIForm.h"
#import "RILocale.h"
#import "RICustomer.h"
#import "UIView+Mirror.h"
#import "UIImage+Mirror.h"
#import "RIFieldOption.h"

@interface JAAddNewAddressViewController ()
<JADynamicFormDelegate,
JAPickerDelegate>
{
    CGFloat _genderRadioHeight;
}

// Steps
@property (weak, nonatomic) IBOutlet UIImageView *stepBackground;
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

// Add Address
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (assign, nonatomic) CGFloat contentScrollOriginalHeight;
@property (assign, nonatomic) CGFloat orderSummaryOriginalHeight;

// Shipping Address
@property (strong, nonatomic) UIView *shippingContentView;
@property (strong, nonatomic) UILabel *shippingHeaderLabel;
@property (strong, nonatomic) UIView *shippingHeaderSeparator;
@property (strong, nonatomic) JADynamicForm *shippingDynamicForm;
@property (assign, nonatomic) CGFloat shippingAddressViewCurrentY;
@property (strong, nonatomic) RILocale *shippingSelectedRegion;
@property (strong, nonatomic) RILocale *shippingSelectedCity;
@property (strong, nonatomic) NSArray *shippingCitiesDataset;
@property (strong, nonatomic) RILocale *shippingSelectedPostcode;
@property (strong, nonatomic) NSArray *shippingPostcodesDataset;

// Billing Address
@property (strong, nonatomic) UIView *billingContentView;
@property (strong, nonatomic) UILabel *billingHeaderLabel;
@property (strong, nonatomic) UIView *billingHeaderSeparator;
@property (strong, nonatomic) JADynamicForm *billingDynamicForm;
@property (assign, nonatomic) CGFloat billingAddressViewCurrentY;
@property (strong, nonatomic) RILocale *billingSelectedRegion;
@property (strong, nonatomic) RILocale *billingSelectedCity;
@property (strong, nonatomic) NSArray *billingCitiesDataset;
@property (strong, nonatomic) RILocale *billingSelectedPostcode;
@property (strong, nonatomic) NSArray *billingPostcodesDataset;

@property (strong, nonatomic) NSArray *regionsDataset; //the same for billing and shipping

// Picker view
@property (strong, nonatomic) JARadioComponent *radioComponent;
@property (strong, nonatomic) NSArray *radioComponentDataset;
@property (strong, nonatomic) JAPicker *picker;

// Create Address Button
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@property (assign, nonatomic) NSInteger numberOfRequests;
@property (assign, nonatomic) NSInteger numberOfGetFormRequests;
@property (assign, nonatomic) BOOL hasErrors;

@property (strong, nonatomic) JACheckBoxComponent *checkBoxComponent;

// Order summary
@property (strong, nonatomic) JAOrderSummaryView *orderSummary;

@property (strong, nonatomic) NSDictionary *extraParameters;

@property (assign, nonatomic) BOOL loadFailed;
@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAAddNewAddressViewController

@synthesize numberOfRequests=_numberOfRequests;
-(void)setNumberOfRequests:(NSInteger)numberOfRequests
{
    _numberOfRequests = numberOfRequests;
    if (0 == numberOfRequests) {
        [self finishedRequests];
    }
}

@synthesize numberOfGetFormRequests=_numberOfGetFormRequests;
-(void)setNumberOfGetFormRequests:(NSInteger)numberOfGetFormRequests
{
    _numberOfGetFormRequests = numberOfGetFormRequests;
    if (0 == numberOfGetFormRequests) {
        [self finishedGetFromRequests];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"NewAddress";
    
    self.navBarLayout.showBackButton = YES;
    
    self.hasErrors = NO;
    
    self.extraParameters = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard)
                                                 name:kOpenMenuNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initViews];
    
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    
    [self getForms];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"NewAddress"];
}

- (void)getForms
{
    if(RIApiResponseSuccess == self.apiResponse)
    {
        [self showLoading];
    }
    
    self.apiResponse = RIApiResponseSuccess;
    self.numberOfGetFormRequests = 2;
    self.loadFailed = NO;
    
    
    typedef void (^GetBillingDynamicFormBlock)(void);
    GetBillingDynamicFormBlock getBillingDynamicFormBlock = ^void{
        [RIForm getForm:@"addresscreate"
           forceRequest:YES
           successBlock:^(RIForm *form)
         {
             self.billingDynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.billingAddressViewCurrentY widthSize:self.billingContentView.frame.size.width hasFieldNavigation:NO];
             
             [self.billingDynamicForm setDelegate:self];
             
             [self getBillingLocales];
             
             _genderRadioHeight = 0;
             CGFloat offset = 0;
             for(UIView *view in self.billingDynamicForm.formViews)
             {
                 if ([view isKindOfClass:[JARadioComponent class]]) {
                     if([(JARadioComponent *)view isComponentWithKey:@"gender"])
                     {
                         _genderRadioHeight += offset;
                         continue;
                     }
                 }
                 offset = view.height;
                 [self.billingContentView addSubview:view];
             }
             self.numberOfGetFormRequests--;
             
         }failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
         {
             if(!self.loadFailed)
             {
                 self.apiResponse = apiResponse;
             }
             
             self.loadFailed = YES;
             self.numberOfGetFormRequests--;
         }];
    };
    
    [RIForm getForm:@"addresscreate"
       forceRequest:YES
       successBlock:^(RIForm *form)
    {
         self.shippingDynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.shippingAddressViewCurrentY widthSize:self.shippingContentView.frame.size.width hasFieldNavigation:NO];
        
        [self.shippingDynamicForm setDelegate:self];
        
         getBillingDynamicFormBlock();
        [self getShippingLocales];
         
         for(UIView *view in self.shippingDynamicForm.formViews)
         {
             [self.shippingContentView addSubview:view];
         }
         
         self.numberOfGetFormRequests--;
     }
       failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
     {
         getBillingDynamicFormBlock();
         if(!self.loadFailed)
         {
             self.apiResponse = apiResponse;
         }
         
         self.loadFailed = YES;
         self.numberOfGetFormRequests--;
     }];
}

- (void)getShippingLocales
{
    
    for (JADynamicField* field in self.shippingDynamicForm.formViews) {
        if ([field isKindOfClass:[JARadioComponent class]]) {
            JARadioComponent* radioComponent = (JARadioComponent*)field;
            
            if([radioComponent isComponentWithKey:@"region"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl] parameters:nil successBlock:^(NSArray *regions) {
                    self.regionsDataset = [regions copy];
                    
                    for (RILocale* region in self.regionsDataset) {
                        if ([region.value isEqualToString:[radioComponent getSelectedValue]]) {
                            [self.shippingDynamicForm setRegionValue:region];
                            self.shippingSelectedRegion = region;
                            break;
                        }
                    }
                } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                }];
            }
            else if([radioComponent isComponentWithKey:@"city"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.shippingDynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *cities) {
                                  self.shippingCitiesDataset = [cities copy];
                                  
                                  for (RILocale* city in self.shippingCitiesDataset) {
                                      if ([city.value isEqualToString:[radioComponent getSelectedValue]]) {
                                          [self.shippingDynamicForm setCityValue:city];
                                          self.shippingSelectedCity = city;
                                          break;
                                      }
                                  }
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                              }];
            }
            else if([radioComponent isComponentWithKey:@"postcode"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.shippingDynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *postcodes) {
                                  self.shippingPostcodesDataset = [postcodes copy];
                                  
                                  for (RILocale* postcode in self.shippingPostcodesDataset) {
                                      if ([postcode.value isEqualToString:[radioComponent getSelectedValue]]) {
                                          [self.shippingDynamicForm setPostcodeValue:postcode];
                                          self.shippingSelectedPostcode = postcode;
                                          break;
                                      }
                                  }
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        }
    }
}

- (void)getBillingLocales
{
    for (JADynamicField* field in self.shippingDynamicForm.formViews) {
        if ([field isKindOfClass:[JARadioComponent class]]) {
            JARadioComponent* radioComponent = (JARadioComponent*)field;
            
            if([radioComponent isComponentWithKey:@"region"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                if (VALID_NOTEMPTY(self.regionsDataset, NSArray)) {
                    for (RILocale* region in self.regionsDataset) {
                        if ([region.value isEqualToString:[radioComponent getSelectedValue]]) {
                            [self.billingDynamicForm setRegionValue:region];
                            self.billingSelectedRegion = region;
                            break;
                        }
                    }
                } else
                    [RILocale getLocalesForUrl:[radioComponent getApiCallUrl] parameters:nil successBlock:^(NSArray *regions) {
                        self.regionsDataset = [regions copy];
                        
                        for (RILocale* region in self.regionsDataset) {
                            if ([region.value isEqualToString:[radioComponent getSelectedValue]]) {
                                [self.billingDynamicForm setRegionValue:region];
                                self.billingSelectedRegion = region;
                                break;
                            }
                        }
                    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                    }];
            }
            else if([radioComponent isComponentWithKey:@"city"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.billingDynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *cities) {
                                  self.billingCitiesDataset = [cities copy];
                                  
                                  for (RILocale* city in self.billingCitiesDataset) {
                                      if ([city.value isEqualToString:[radioComponent getSelectedValue]]) {
                                          [self.billingDynamicForm setCityValue:city];
                                          self.billingSelectedCity = city;
                                          break;
                                      }
                                  }
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
            else if([radioComponent isComponentWithKey:@"postcode"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.billingDynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *postcodes) {
                                  self.billingPostcodesDataset = [postcodes copy];
                                  
                                  for (RILocale* postcode in self.billingPostcodesDataset) {
                                      if ([postcode.value isEqualToString:[radioComponent getSelectedValue]]) {
                                          [self.billingDynamicForm setPostcodeValue:postcode];
                                          self.billingSelectedPostcode = postcode;
                                          break;
                                      }
                                  }
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        }
    }
}

- (void)hideKeyboard
{
    [self.shippingDynamicForm resignResponder];
    [self.billingDynamicForm resignResponder];
}

- (void)finishedGetFromRequests
{
    if(self.loadFailed)
    {
        [self onErrorResponse:self.apiResponse messages:nil showAsMessage:NO selector:@selector(getForms) objects:nil];
        [self hideLoading];
    }
    else
    {
        [self finishedFormLoading];
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];

        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"CheckoutMyAddress" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutAddresses]
                                                  data:[trackingDictionary copy]];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    [self showLoading];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && self.fromCheckout)
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
    
    [self.shippingDynamicForm resignResponder];
    [self.billingDynamicForm resignResponder];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(void)initViews
{
    if(self.fromCheckout)
    {
        self.stepBackground.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepView.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepIcon.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepLabel.translatesAutoresizingMaskIntoConstraints = YES;
        self.stepLabel.font = [UIFont fontWithName:kFontBoldName size:self.stepLabel.font.pointSize];
        [self.stepLabel setText:STRING_CHECKOUT_ADDRESS];
        [self setupStepView:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];        
    }
    else
    {
        [self.stepBackground removeFromSuperview];
        [self.stepView removeFromSuperview];
        [self.stepIcon removeFromSuperview];
        [self.stepLabel removeFromSuperview];
    }
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentScrollView setShowsVerticalScrollIndicator:NO];
    
    [self initShippingAddressView];
    [self initBillingAddressView];
    
    [self.view addSubview:self.contentScrollView];
    
    self.bottomView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero orientation:UIInterfaceOrientationPortrait];
    [self.bottomView setFrame:CGRectMake(0.0f, self.view.frame.size.height - self.bottomView.frame.size.height, self.view.frame.size.width, self.bottomView.frame.size.height)];
    [self.view addSubview:self.bottomView];
}

-(void)initShippingAddressView
{
    self.shippingContentView = [[UIView alloc] init];
    self.shippingContentView.frame = CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.contentScrollView.frame.size.height);
    [self.shippingContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.shippingContentView setHidden:YES];
    self.shippingContentView.layer.cornerRadius = 5.0f;
    
    self.shippingHeaderLabel = [[UILabel alloc] init];
    self.shippingHeaderLabel.frame = CGRectMake(6.0f, 0.0f, self.shippingContentView.frame.size.width, 26.0f);
    [self.shippingHeaderLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.shippingHeaderLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.shippingHeaderLabel setText:STRING_ADD_NEW_ADDRESS];
    [self.shippingHeaderLabel setBackgroundColor:[UIColor clearColor]];
    [self.shippingContentView addSubview:self.shippingHeaderLabel];
    
    self.shippingHeaderSeparator = [[UIView alloc] init];
    self.shippingHeaderSeparator.frame = CGRectMake(0.0f, CGRectGetMaxY(self.shippingHeaderLabel.frame), self.shippingContentView.frame.size.width - 12.0f, 1.0f);
    [self.shippingHeaderSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.shippingContentView addSubview:self.shippingHeaderSeparator];
    
    [self.contentScrollView addSubview:self.shippingContentView];
    self.shippingAddressViewCurrentY = CGRectGetMaxY(self.shippingHeaderSeparator.frame) + 6.0f;
}

-(void)initBillingAddressView
{
    self.billingContentView = [[UIView alloc] init];
    self.billingContentView.frame = CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height - _genderRadioHeight);
    [self.billingContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.billingContentView.layer.cornerRadius = 5.0f;
    [self.billingContentView setHidden:YES];
    
    self.billingHeaderLabel = [[UILabel alloc] init];
    self.billingHeaderLabel.frame = CGRectMake(6.0f, 0.0f, self.billingContentView.frame.size.width - 12.0f, 26.0f);
    [self.billingHeaderLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.billingHeaderLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.billingHeaderLabel setText:STRING_BILLING_ADDRESSES];
    [self.billingHeaderLabel setBackgroundColor:[UIColor clearColor]];
    [self.billingContentView addSubview:self.billingHeaderLabel];
    
    self.billingHeaderSeparator = [[UIView alloc] init];
    self.billingHeaderSeparator.frame = CGRectMake(0.0f, CGRectGetMaxY(self.billingHeaderLabel.frame), self.billingContentView.frame.size.width - 12.0f, 1.0f);
    [self.billingHeaderSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.billingContentView addSubview:self.billingHeaderSeparator];
    
    [self.contentScrollView addSubview:self.billingContentView];
    self.billingAddressViewCurrentY = CGRectGetMaxY(self.billingHeaderSeparator.frame) + 6.0f;
}

-(void)finishedFormLoading
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && self.fromCheckout)
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    if(self.isBillingAddress && self.isShippingAddress)
    {
        self.checkBoxComponent = [JACheckBoxComponent getNewJACheckBoxComponent];
        [self.checkBoxComponent setup];
        [self.checkBoxComponent.labelText setText:STRING_BILLING_SAME_ADDRESSES];
        [self.checkBoxComponent.switchComponent setOn:YES];
        [self.checkBoxComponent.switchComponent addTarget:self action:@selector(changedAddressState:) forControlEvents:UIControlEventValueChanged];
        [self.checkBoxComponent.switchComponent setAccessibilityLabel:STRING_BILLING_SAME_ADDRESSES];
        [self.shippingContentView addSubview:self.checkBoxComponent];
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
    
    [self hideLoading];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
}

- (void)setupStepView:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat stepViewLeftMargin = 73.0f;
    NSString *stepBackgroundImageName = @"headerCheckoutStep2";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            stepViewLeftMargin =  389.0f;
            stepBackgroundImageName = @"headerCheckoutStep2Landscape";
        }
        else
        {
            stepViewLeftMargin = 261.0f;
            stepBackgroundImageName = @"headerCheckoutStep2Portrait";
        }
    }
    UIImage *stepBackgroundImage = [UIImage imageNamed:stepBackgroundImageName];
    
    [self.stepBackground setImage:stepBackgroundImage];
    [self.stepBackground setFrame:CGRectMake(self.stepBackground.frame.origin.x,
                                             self.stepBackground.frame.origin.y,
                                             stepBackgroundImage.size.width,
                                             stepBackgroundImage.size.height)];
    
    [self.stepView setFrame:CGRectMake(stepViewLeftMargin,
                                       (stepBackgroundImage.size.height - self.stepView.frame.size.height) / 2,
                                       self.stepView.frame.size.width,
                                       stepBackgroundImage.size.height)];
    [self.stepLabel sizeToFit];
    
    CGFloat horizontalMargin = 6.0f;
    CGFloat marginBetweenIconAndLabel = 5.0f;
    CGFloat realWidth = self.stepIcon.frame.size.width + marginBetweenIconAndLabel + self.stepLabel.frame.size.width - (2 * horizontalMargin);
    
    if(self.stepView.frame.size.width >= realWidth)
    {
        CGFloat xStepIconValue = ((self.stepView.frame.size.width - realWidth) / 2) - horizontalMargin;
        [self.stepIcon setFrame:CGRectMake(xStepIconValue,
                                           ceilf(((self.stepView.frame.size.height - self.stepIcon.frame.size.height) / 2) - 1.0f),
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            4.0f,
                                            self.stepLabel.frame.size.width,
                                            12.0f)];
    }
    else
    {
        [self.stepIcon setFrame:CGRectMake(horizontalMargin,
                                           ceilf(((self.stepView.frame.size.height - self.stepIcon.frame.size.height) / 2) - 1.0f),
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            4.0f,
                                            (self.stepView.frame.size.width - self.stepIcon.frame.size.width - marginBetweenIconAndLabel - (2 * horizontalMargin)),
                                            12.0f)];
    }
    
    if(RI_IS_RTL){
        [self.stepBackground setImage:[stepBackgroundImage flipImageWithOrientation:UIImageOrientationUpMirrored]];
    }
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    self.shippingAddressViewCurrentY = CGRectGetMaxY(self.shippingHeaderSeparator.frame) + 6.0f;
    
    CGFloat scrollViewStartY = 0.0f;
    if(self.fromCheckout)
    {
        [self setupStepView:width toInterfaceOrientation:toInterfaceOrientation];
        scrollViewStartY = self.stepBackground.frame.size.height;
    }
    
    if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
    {
        [self.orderSummary removeFromSuperview];
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && (width < self.view.frame.size.width) && self.fromCheckout)
    {
        CGFloat orderSummaryRightMargin = 6.0f;
        self.orderSummary = [[JAOrderSummaryView alloc] initWithFrame:CGRectMake(width,
                                                                                 scrollViewStartY,
                                                                                 self.view.frame.size.width - width - orderSummaryRightMargin,
                                                                                 self.view.frame.size.height - scrollViewStartY)];
        [self.orderSummary loadWithCart:self.cart];
        [self.view addSubview:self.orderSummary];
        self.orderSummaryOriginalHeight = self.orderSummary.frame.size.height;
    }
    
    
    [self.contentScrollView setFrame:CGRectMake(0.0f,
                                                scrollViewStartY,
                                                width,
                                                self.view.frame.size.height - scrollViewStartY)];
    
    [self.shippingContentView setFrame:CGRectMake(6.0f,
                                                  6.0f,
                                                  self.contentScrollView.frame.size.width - 12.0f,
                                                  self.shippingContentView.frame.size.height)];
    
    [self.billingContentView setFrame:CGRectMake(6.0f,
                                                 6.0f,
                                                 self.contentScrollView.frame.size.width - 12.0f,
                                                 self.billingContentView.frame.size.height - _genderRadioHeight)];
    
    for(UIView *view in self.shippingDynamicForm.formViews)
    {
        [view setFrame:CGRectMake(view.frame.origin.x,
                                  self.shippingAddressViewCurrentY,
                                  self.shippingContentView.frame.size.width,
                                  view.frame.size.height)];
        self.shippingAddressViewCurrentY += view.frame.size.height;
    }
    
    [self.checkBoxComponent setFrame:CGRectMake(self.checkBoxComponent.frame.origin.x,
                                                self.shippingAddressViewCurrentY,
                                                self.shippingContentView.frame.size.width - 12.0f,
                                                self.checkBoxComponent.frame.size.height)];
    
    self.shippingAddressViewCurrentY += self.checkBoxComponent.frame.size.height;
    
    if(!self.isBillingAddress || !self.isShippingAddress)
    {
        self.shippingAddressViewCurrentY += 12.0f;
    }
    else
    {
        self.shippingAddressViewCurrentY += 6.0f;
    }
    
    [self.shippingContentView setFrame:CGRectMake(6.0f,
                                                  6.0f,
                                                  self.contentScrollView.frame.size.width - 12.0f,
                                                  self.shippingAddressViewCurrentY)];
    [self.shippingContentView setHidden:NO];
    
    self.shippingHeaderLabel.textAlignment = NSTextAlignmentLeft;
    [self.shippingHeaderLabel setFrame:CGRectMake(6.0f,
                                                  0.0f,
                                                  self.shippingContentView.frame.size.width,
                                                  26.0f)];
    
    [self.shippingHeaderSeparator setFrame:CGRectMake(0.0f,
                                                      CGRectGetMaxY(self.shippingHeaderLabel.frame),
                                                      self.shippingContentView.frame.size.width,
                                                      1.0f)];
    
    self.contentScrollOriginalHeight = self.contentScrollView.frame.size.height;
    
    self.billingAddressViewCurrentY = CGRectGetMaxY(self.billingHeaderSeparator.frame) + 6.0f;
    for(UIView *view in self.billingDynamicForm.formViews)
    {
        [view setFrame:CGRectMake(view.frame.origin.x,
                                  self.billingAddressViewCurrentY,
                                  self.billingContentView.frame.size.width,
                                  view.frame.size.height)];
        self.billingAddressViewCurrentY += view.frame.size.height;
    }
    
    [self.billingContentView setFrame:CGRectMake(6.0f,
                                                 CGRectGetMaxY(self.shippingContentView.frame) + 6.0f,
                                                 self.contentScrollView.frame.size.width - 12.0f,
                                                 self.billingAddressViewCurrentY + 12.0f - _genderRadioHeight)];
    
    self.billingHeaderLabel.textAlignment = NSTextAlignmentLeft;
    [self.billingHeaderLabel setFrame:CGRectMake(6.0f,
                                                 0.0f,
                                                 self.billingContentView.frame.size.width,
                                                 26.0f)];
    
    [self.billingHeaderSeparator setFrame:CGRectMake(0.0f,
                                                     CGRectGetMaxY(self.billingHeaderLabel.frame),
                                                     self.billingContentView.frame.size.width,
                                                     1.0f)];
    
    [self.bottomView reloadFrame:CGRectMake(0.0f,
                                            self.view.frame.size.height - self.bottomView.frame.size.height,
                                            width,
                                            self.bottomView.frame.size.height)];
    
    if(self.fromCheckout)
    {
        [self.bottomView addButton:STRING_NEXT target:self action:@selector(createAddressButtonPressed)];
    }
    else
    {
        [self.bottomView addButton:STRING_SAVE_LABEL target:self action:@selector(createAddressButtonPressed)];
    }
    
    if(!VALID_NOTEMPTY(self.checkBoxComponent, JACheckBoxComponent) || [self.checkBoxComponent isCheckBoxOn])
    {
        [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width,
                                                          self.shippingContentView.frame.origin.y + self.shippingContentView.frame.size.height + self.bottomView.frame.size.height)];
    }
    else
    {
        [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width,
                                                          self.shippingContentView.frame.origin.y + self.shippingContentView.frame.size.height + 6.0f + self.billingContentView.frame.size.height + self.bottomView.frame.size.height)];
    }
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

-(void)showBillingAddressForm
{
    [self.shippingHeaderLabel setText:STRING_SHIPPING_ADDRESSES];
    
    [self.billingContentView setHidden:NO];
    [self.billingContentView setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.shippingContentView.frame) + 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.billingAddressViewCurrentY + 12.0f - _genderRadioHeight)];
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.shippingContentView.frame.origin.y + self.shippingContentView.frame.size.height + 6.0f + self.billingContentView.frame.size.height + self.bottomView.frame.size.height)];
}

-(void)hideBillingAddressForm
{
    [self.shippingHeaderLabel setText:STRING_ADD_NEW_ADDRESS];
    [self.billingDynamicForm resetValues];
    
    [self.billingContentView setHidden:YES];
    [self.shippingContentView setFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.shippingAddressViewCurrentY)];
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.shippingContentView.frame.origin.y + self.shippingContentView.frame.size.height + self.bottomView.frame.size.height)];
}

-(void)changedAddressState:(id)sender
{
    UISwitch *switchView = sender;
    if([switchView isOn])
    {
        [self hideBillingAddressForm];
    }
    else
    {
        [self showBillingAddressForm];
    }
}

-(void)removePickerView
{
    if(VALID_NOTEMPTY(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }
    
    self.radioComponent = nil;
    self.radioComponentDataset = nil;
}

-(void)createAddressButtonPressed
{
    [self showLoading];
    if ([self.shippingDynamicForm checkErrors]) {
        [self onErrorResponse:RIApiResponseSuccess messages:@[self.shippingDynamicForm.firstErrorInFields] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
        [self hideLoading];
        return;
    }
    
    if (![self.billingContentView isHidden] && [self.billingDynamicForm checkErrors]) {
        [self onErrorResponse:RIApiResponseSuccess messages:@[self.shippingDynamicForm.firstErrorInFields] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
        [self hideLoading];
        return;
    }
    
    self.numberOfRequests = 1;
    
    NSMutableDictionary *shippingParameters = [[NSMutableDictionary alloc] initWithDictionary:[self.shippingDynamicForm getValues]];
    
    if(self.isBillingAddress && self.isShippingAddress)
    {
        [shippingParameters setValue:@"1" forKey:[self.shippingDynamicForm getFieldNameForKey:@"is_default_billing"]];
        [shippingParameters setValue:@"1" forKey:[self.shippingDynamicForm getFieldNameForKey:@"is_default_shipping"]];
    }
    else if(self.isBillingAddress)
    {
        [shippingParameters setValue:@"1" forKey:[self.shippingDynamicForm getFieldNameForKey:@"is_default_billing"]];
        [shippingParameters setValue:@"0" forKey:[self.shippingDynamicForm getFieldNameForKey:@"is_default_shipping"]];
    }
    else if(self.isShippingAddress)
    {
        [shippingParameters setValue:@"0" forKey:[self.shippingDynamicForm getFieldNameForKey:@"is_default_billing"]];
        [shippingParameters setValue:@"1" forKey:[self.shippingDynamicForm getFieldNameForKey:@"is_default_shipping"]];
    }
    
    if(![self.billingContentView isHidden])
    {
        self.numberOfRequests = 2;
        
        [shippingParameters setValue:@"0" forKey:[self.shippingDynamicForm getFieldNameForKey:@"is_default_billing"]];
        
        NSMutableDictionary *billingParameters = [[NSMutableDictionary alloc] initWithDictionary:[self.billingDynamicForm getValues]];
        
        [billingParameters setValue:@"0" forKey:[self.shippingDynamicForm getFieldNameForKey:@"is_default_shipping"]];
        [billingParameters setValue:@"1" forKey:[self.shippingDynamicForm getFieldNameForKey:@"is_default_billing"]];
        
        NSString* shippingGenderFieldName = [self.shippingDynamicForm getFieldNameForKey:@"gender"];
        NSString* shippingGenderValue = [shippingParameters objectForKey:shippingGenderFieldName];
        [billingParameters setValue:shippingGenderValue forKey:shippingGenderFieldName];
        
        [RIForm sendForm:[self.billingDynamicForm form]
              parameters:billingParameters
            successBlock:^(id object)
         {
             NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
             [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
             [trackingDictionary setValue:@"CheckoutCreateAddress" forKey:kRIEventActionKey];
             [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
             
             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutAddresses]
                                                       data:[trackingDictionary copy]];
             
             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutAddAddressSuccess]
                                                       data:nil];
             
             [self.billingDynamicForm resetValues];
             self.numberOfRequests--;
         } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
         {
             NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
             [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
             [trackingDictionary setValue:@"NativeCheckoutError" forKey:kRIEventActionKey];
             [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
             
             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutError]
                                                       data:[trackingDictionary copy]];
             
             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutAddAddressFail]
                                                       data:nil];
             self.hasErrors = YES;
             self.numberOfRequests--;
             
             if(VALID_NOTEMPTY(errorObject, NSDictionary))
             {
                 [self.billingDynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                     [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
                 }];
             }
             else if(VALID_NOTEMPTY(errorObject, NSArray))
             {
                 [self.billingDynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                     [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
                 }];
             }
         }];
    }
    
    [RIForm sendForm:[self.shippingDynamicForm form]
      extraArguments:self.extraParameters
          parameters:shippingParameters
        successBlock:^(id object)
     {
         
         [self.shippingDynamicForm resetValues];
         self.numberOfRequests--;
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         self.hasErrors = YES;
         self.numberOfRequests--;
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.shippingDynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
             }];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.shippingDynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
             }];
         }
         else
         {
             [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
         }
     }];
}

-(void)finishedRequests
{
    [self hideLoading];
    
    if(self.hasErrors)
    {
        [self onErrorResponse:RIApiResponseSuccess messages:@[STRING_ERROR_INVALID_FIELDS] showAsMessage:YES selector:@selector(createAddressButtonPressed) objects:nil];
        
        self.hasErrors = NO;
    }
    else
    {
        if(self.fromCheckout)
        {
            [self.navigationController popViewControllerAnimated:NO];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.cart forKey:@"cart"];
            [JAUtils goToNextStep:self.cart.nextStep
                         userInfo:userInfo];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCloseCurrentScreenNotification
                                                                object:nil
                                                              userInfo:nil];
        }
    }
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    //    CGPoint scrollPoint = CGPointMake(0.0, view.frame.origin.y);
    //
    //    if(self.billingContentView == [view superview])
    //    {
    //        scrollPoint = CGPointMake(0.0, 6.0f + CGRectGetMaxY(self.shippingContentView.frame) + 6.0f + view.frame.origin.y);
    //    }
    //
    //    [self.contentScrollView setContentOffset:scrollPoint
    //                                    animated:YES];
}

- (void) lostFocus
{
    //    [UIView animateWithDuration:0.5f
    //                     animations:^{
    //                         self.contentScrollView.frame = self.originalFrame;
    //                     }];
}

- (NSDictionary*)getRequestParametersForRadioComponent:(JARadioComponent*)component
                                               andForm:(JADynamicForm*)dynamicForm
{
    NSMutableDictionary* requestParameters = [NSMutableDictionary new];
    
    NSDictionary* parameterMap = [component getApiCallParameters];
    
    if (VALID_NOTEMPTY(parameterMap, NSDictionary)) {
        [parameterMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //look for value of field corresponding to key
            for (JADynamicField* field in dynamicForm.formViews) {
                if ([field isKindOfClass:[JARadioComponent class]]) {
                    //found the right class, so cast it
                    JARadioComponent* relatedComponent = (JARadioComponent*)field;
                    
                    //check for key
                    if ([relatedComponent isComponentWithKey:key]) {
                        //found the component, so look for value and add it to the request parameters
                        // using the object from the parameter map as the key
                        [requestParameters setValue:[relatedComponent getSelectedValue] forKey:obj];
                        break;
                    }
                }
            }
            //use the obj as the key in the request parameters
        }];
    }
    
    return [requestParameters copy];
}

- (void)openPicker:(JARadioComponent *)radioComponent
{
    [self.shippingDynamicForm resignResponder];
    [self.billingDynamicForm resignResponder];

    [self removePickerView];
    
    self.radioComponent = radioComponent;
    
    if([radioComponent isComponentWithKey:@"region"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
    {
        [self showLoading];
        [RILocale getLocalesForUrl:[radioComponent getApiCallUrl] parameters:nil successBlock:^(NSArray *regions) {
            self.regionsDataset = [regions copy];
            self.radioComponentDataset = [regions copy];
            
            [self hideLoading];
            [self setupPickerView];
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
            [self hideLoading];
        }];
    }
    else if([radioComponent isComponentWithKey:@"city"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
    {
        if(self.shippingContentView == [radioComponent superview])
        {
            if(VALID_NOTEMPTY(self.shippingCitiesDataset, NSArray))
            {
                self.radioComponentDataset = self.shippingCitiesDataset;
                
                [self setupPickerView];
            }
            else
            {
                [self showLoading];
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.shippingDynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *cities) {
                                  self.shippingCitiesDataset = [cities copy];
                                  self.radioComponentDataset = [cities copy];
                                  
                                  [self hideLoading];
                                  [self setupPickerView];
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        }
        else if(self.billingContentView == [radioComponent superview])
        {
            if(VALID_NOTEMPTY(self.billingCitiesDataset, NSArray))
            {
                self.radioComponentDataset = self.billingCitiesDataset;
                
                [self setupPickerView];
            }
            else
            {
                [self showLoading];
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.billingDynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *cities) {
                                  self.billingCitiesDataset = [cities copy];
                                  self.radioComponentDataset = [cities copy];
                                  
                                  [self hideLoading];
                                  [self setupPickerView];
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        }
    }
    else if([radioComponent isComponentWithKey:@"postcode"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
    {
        if(self.shippingContentView == [radioComponent superview])
        {
            if(VALID_NOTEMPTY(self.shippingPostcodesDataset, NSArray))
            {
                self.radioComponentDataset = self.shippingPostcodesDataset;
                
                [self setupPickerView];
            }
            else
            {
                [self showLoading];
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.shippingDynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *postcodes) {
                                  self.shippingPostcodesDataset = [postcodes copy];
                                  self.radioComponentDataset = [postcodes copy];
                                  
                                  [self hideLoading];
                                  [self setupPickerView];
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        }
        else if(self.billingContentView == [radioComponent superview])
        {
            if(VALID_NOTEMPTY(self.billingPostcodesDataset, NSArray))
            {
                self.radioComponentDataset = self.billingPostcodesDataset;
                
                [self setupPickerView];
            }
            else
            {
                [self showLoading];
                NSDictionary* requestParameters = [self getRequestParametersForRadioComponent:radioComponent andForm:self.billingDynamicForm];
                [RILocale getLocalesForUrl:[radioComponent getApiCallUrl]
                                parameters:requestParameters
                              successBlock:^(NSArray *postcodes) {
                                  self.billingPostcodesDataset = [postcodes copy];
                                  self.radioComponentDataset = [postcodes copy];
                                  
                                  [self hideLoading];
                                  [self setupPickerView];
                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                                  [self hideLoading];
                              }];
            }
        }
    }
    else if([radioComponent isComponentWithKey:@"gender"])
    {
        if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY([self.radioComponent options], NSArray))
        {
            self.radioComponentDataset  = [[self.radioComponent options] copy];
            
            [self setupPickerView];
        }
    }
}

-(NSString*)getPickerSelectedRow
{
    NSString *selectedValue = [self.radioComponent getSelectedValue];
    NSString *selectedRow = @"";
    if(VALID_NOTEMPTY(selectedValue, NSString))
    {
        if(VALID_NOTEMPTY(self.radioComponentDataset, NSArray))
        {
            for (int i = 0; i < [self.radioComponentDataset count]; i++)
            {
                RILocale* selectedObject = [self.radioComponentDataset objectAtIndex:i];
                if(VALID_NOTEMPTY(selectedObject, RILocale))
                {
                    if([selectedValue isEqualToString:selectedObject.value])
                    {
                        selectedRow = selectedObject.label;
                        break;
                    }
                }
            }
        }
    }
    return selectedRow;
}

-(void) setupPickerView
{
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY(self.radioComponentDataset, NSArray))
    {
        for(id currentObject in self.radioComponentDataset)
        {
            NSString *title = @"";
            if(VALID_NOTEMPTY(currentObject, RILocale))
            {
                title = ((RILocale*) currentObject).label;
            }
            else if(VALID_NOTEMPTY(currentObject, NSString))
            {
                title = currentObject;
            }
            [dataSource addObject:title];
        }
    }
    
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:[self getPickerSelectedRow]
                    leftButtonTitle:nil];
    
    CGFloat pickerViewHeight = self.view.frame.size.height;
    CGFloat pickerViewWidth = self.view.frame.size.width;
    [self.picker setFrame:CGRectMake(0.0f,
                                     pickerViewHeight,
                                     pickerViewWidth,
                                     pickerViewHeight)];
    [self.view addSubview:self.picker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f,
                                                          0.0f,
                                                          pickerViewWidth,
                                                          pickerViewHeight)];
                     }];
}

- (IBAction)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    if (VALID_NOTEMPTY(self.radioComponent, JARadioComponent)
        && VALID_NOTEMPTY(self.radioComponentDataset, NSArray)
        && selectedRow < [self.radioComponentDataset count]) {
        
        id selectedObject = [self.radioComponentDataset objectAtIndex:selectedRow];
        
        if (self.shippingContentView == [self.radioComponent superview]) {
            if (VALID_NOTEMPTY(selectedObject, RILocale)
                && [self.radioComponent isComponentWithKey:@"region"]
                && ![[(RILocale*)selectedObject value] isEqualToString:[self.shippingSelectedRegion value]]) {
                
                self.shippingSelectedRegion = selectedObject;
                self.shippingSelectedCity = nil;
                self.shippingCitiesDataset = nil;
                self.shippingSelectedPostcode = nil;
                self.shippingPostcodesDataset = nil;
                
                [self.shippingDynamicForm setRegionValue:selectedObject];
                [self.shippingDynamicForm setCityValue:nil];
                [self.shippingDynamicForm setPostcodeValue:nil];
            } else if (VALID_NOTEMPTY(selectedObject, RILocale) && [self.radioComponent isComponentWithKey:@"city"]) {
                self.shippingSelectedCity = selectedObject;
                self.shippingSelectedPostcode = nil;
                self.shippingPostcodesDataset = nil;
                
                [self.shippingDynamicForm setCityValue:selectedObject];
                [self.shippingDynamicForm setPostcodeValue:nil];
            } else if (VALID_NOTEMPTY(selectedObject, RILocale) && [self.radioComponent isComponentWithKey:@"postcode"]) {
                self.shippingSelectedPostcode = selectedObject;
                
                [self.shippingDynamicForm setPostcodeValue:selectedObject];
            } else if (VALID_NOTEMPTY(selectedObject, NSString)) {
                [self.radioComponent setValue:selectedObject];
            }
        } else if (self.billingContentView == [self.radioComponent superview]) {
            if (VALID_NOTEMPTY(selectedObject, RILocale)
                && [self.radioComponent isComponentWithKey:@"region"]
                && ![[(RILocale*) selectedObject value] isEqualToString:[self.billingSelectedRegion value]]) {
                self.billingSelectedRegion = selectedObject;
                self.billingSelectedCity = nil;
                self.billingCitiesDataset = nil;
                self.billingSelectedPostcode = nil;
                self.billingPostcodesDataset = nil;
                
                [self.billingDynamicForm setRegionValue:selectedObject];
                [self.billingDynamicForm setCityValue:nil];
                [self.billingDynamicForm setPostcodeValue:nil];
            } else if(VALID_NOTEMPTY(selectedObject, RILocale) && [self.radioComponent isComponentWithKey:@"city"]) {
                self.billingSelectedCity = selectedObject;
                self.billingSelectedPostcode = nil;
                self.billingPostcodesDataset = nil;
                
                [self.billingDynamicForm setCityValue:selectedObject];
                [self.billingDynamicForm setPostcodeValue:nil];
            } else if(VALID_NOTEMPTY(selectedObject, RILocale) && [self.radioComponent isComponentWithKey:@"postcode"]) {
                self.billingSelectedPostcode = selectedObject;
                
                [self.billingDynamicForm setPostcodeValue:selectedObject];
            } else if(VALID_NOTEMPTY(selectedObject, NSString)) {
                [self.radioComponent setValue:selectedObject];
            }
        }
    }
    
    [self removePickerView];
}

#pragma mark - Keyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    
    if(self.view.frame.size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView setFrame:CGRectMake(self.contentScrollView.frame.origin.x,
                                                    self.contentScrollView.frame.origin.y,
                                                    self.contentScrollView.frame.size.width,
                                                    self.contentScrollOriginalHeight - height)];
        
        if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
        {
            [self.orderSummary setFrame:CGRectMake(self.orderSummary.frame.origin.x,
                                                   self.orderSummary.frame.origin.y,
                                                   self.orderSummary.frame.size.width,
                                                   self.orderSummaryOriginalHeight - height)];
        }
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView setFrame:CGRectMake(self.contentScrollView.frame.origin.x,
                                                    self.contentScrollView.frame.origin.y,
                                                    self.contentScrollView.frame.size.width,
                                                    self.contentScrollOriginalHeight)];
        
        if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
        {
            [self.orderSummary setFrame:CGRectMake(self.orderSummary.frame.origin.x,
                                                   self.orderSummary.frame.origin.y,
                                                   self.orderSummary.frame.size.width,
                                                   self.orderSummaryOriginalHeight)];
        }
    }];
}

@end
