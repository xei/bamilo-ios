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
#import "RIRegion.h"
#import "RICity.h"
#import "RICheckout.h"
#import "RICustomer.h"

@interface JAAddNewAddressViewController ()
<JADynamicFormDelegate,
JAPickerDelegate>

// Steps
@property (weak, nonatomic) IBOutlet UIImageView *stepBackground;
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

// Add Address
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (assign, nonatomic) CGRect originalFrame;
@property (assign, nonatomic) CGRect orderSummaryOriginalFrame;

// Shipping Address
@property (strong, nonatomic) UIView *shippingContentView;
@property (strong, nonatomic) UILabel *shippingHeaderLabel;
@property (strong, nonatomic) UIView *shippingHeaderSeparator;
@property (strong, nonatomic) JADynamicForm *shippingDynamicForm;
@property (assign, nonatomic) CGFloat shippingAddressViewCurrentY;
@property (strong, nonatomic) RIRegion *shippingSelectedRegion;
@property (strong, nonatomic) RICity *shippingSelectedCity;
@property (strong, nonatomic) NSArray *shippingCitiesDataset;

// Billing Address
@property (strong, nonatomic) UIView *billingContentView;
@property (strong, nonatomic) UILabel *billingHeaderLabel;
@property (strong, nonatomic) UIView *billingHeaderSeparator;
@property (strong, nonatomic) JADynamicForm *billingDynamicForm;
@property (assign, nonatomic) CGFloat billingAddressViewCurrentY;
@property (strong, nonatomic) RIRegion *billingSelectedRegion;
@property (strong, nonatomic) RICity *billingSelectedCity;
@property (strong, nonatomic) NSArray *billingCitiesDataset;

// Picker view
@property (strong, nonatomic) JARadioComponent *radioComponent;
@property (strong, nonatomic) NSArray *regionsDataset;
@property (strong, nonatomic) NSArray *radioComponentDataset;
@property (strong, nonatomic) JAPicker *picker;

// Create Address Button
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@property (assign, nonatomic) NSInteger numberOfRequests;
@property (assign, nonatomic) NSInteger numberOfGetFormRequests;
@property (assign, nonatomic) BOOL hasErrors;
@property (strong, nonatomic) RICheckout *checkout;

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
    
    self.hasErrors = NO;
    
    self.extraParameters = nil;
    if([RICustomer wasSignup])
    {
        self.extraParameters = [NSDictionary dictionaryWithObject:@"true" forKey:@"showGender"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showLoading];
    
    [self initViews];
    
    self.numberOfGetFormRequests = 2;
    
    [RIForm getForm:@"addresscreate"
     extraArguments:self.extraParameters
       successBlock:^(RIForm *form)
     {
         self.shippingDynamicForm = [[JADynamicForm alloc] initWithForm:form delegate:self startingPosition:self.shippingAddressViewCurrentY widthSize:self.shippingContentView.frame.size.width];
         
         for(UIView *view in self.shippingDynamicForm.formViews)
         {
             [self.shippingContentView addSubview:view];
         }
         
         self.numberOfGetFormRequests--;
     }
       failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
     {
         if(!self.loadFailed)
         {
             self.apiResponse = apiResponse;
         }
         
         self.loadFailed = YES;
         self.numberOfGetFormRequests--;
     }];
    
    [RIForm getForm:@"addresscreate"
       successBlock:^(RIForm *form)
     {
         self.billingDynamicForm = [[JADynamicForm alloc] initWithForm:form delegate:self startingPosition:self.billingAddressViewCurrentY widthSize:self.billingContentView.frame.size.width];
         
         for(UIView *view in self.billingDynamicForm.formViews)
         {
             [self.billingContentView addSubview:view];
         }
         self.numberOfGetFormRequests--;
     }
       failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
     {
         if(!self.loadFailed)
         {
             self.apiResponse = apiResponse;
         }
         
         self.loadFailed = YES;
         self.numberOfGetFormRequests--;
     }];
}

- (void)finishedGetFromRequests
{
    if(self.loadFailed)
    {
    if (RIApiResponseNoInternetConnection == self.apiResponse)
    {
        [self showMessage:STRING_NO_NEWTORK success:NO];
    }
    else
    {
        [self showMessage:STRING_ERROR success:NO];
    }
    }
    else
    {
    [self finishedFormLoading];
    
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
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && self.fromCheckout)
    {
        newWidth = self.view.frame.size.width;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:toInterfaceOrientation];
    
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
    self.shippingContentView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.contentScrollView.frame.size.height)];
    [self.shippingContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.shippingContentView setHidden:YES];
    self.shippingContentView.layer.cornerRadius = 5.0f;
    
    self.shippingHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 0.0f, self.shippingContentView.frame.size.width, 26.0f)];
    [self.shippingHeaderLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.shippingHeaderLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.shippingHeaderLabel setText:STRING_ADD_NEW_ADDRESS];
    [self.shippingHeaderLabel setBackgroundColor:[UIColor clearColor]];
    [self.shippingContentView addSubview:self.shippingHeaderLabel];
    
    self.shippingHeaderSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.shippingHeaderLabel.frame), self.shippingContentView.frame.size.width - 12.0f, 1.0f)];
    [self.shippingHeaderSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.shippingContentView addSubview:self.shippingHeaderSeparator];
    
    [self.contentScrollView addSubview:self.shippingContentView];
    self.shippingAddressViewCurrentY = CGRectGetMaxY(self.shippingHeaderSeparator.frame) + 6.0f;
}

-(void)initBillingAddressView
{
    self.billingContentView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height)];
    [self.billingContentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.billingContentView.layer.cornerRadius = 5.0f;
    [self.billingContentView setHidden:YES];
    
    self.billingHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 0.0f, self.billingContentView.frame.size.width - 12.0f, 26.0f)];
    [self.billingHeaderLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.billingHeaderLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.billingHeaderLabel setText:STRING_BILLING_ADDRESSES];
    [self.billingHeaderLabel setBackgroundColor:[UIColor clearColor]];
    [self.billingContentView addSubview:self.billingHeaderLabel];
    
    self.billingHeaderSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.billingHeaderLabel.frame), self.billingContentView.frame.size.width - 12.0f, 1.0f)];
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

- (void) setupStepView:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
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
        self.orderSummaryOriginalFrame = self.orderSummary.frame;
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
                                                 self.billingContentView.frame.size.height)];
    
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
    
    [self.shippingHeaderLabel setFrame:CGRectMake(6.0f,
                                                  0.0f,
                                                  self.shippingContentView.frame.size.width,
                                                  26.0f)];
    
    [self.shippingHeaderSeparator setFrame:CGRectMake(0.0f,
                                                      CGRectGetMaxY(self.shippingHeaderLabel.frame),
                                                      self.shippingContentView.frame.size.width,
                                                      1.0f)];
    
    self.originalFrame = self.contentScrollView.frame;
    
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
                                                 self.billingAddressViewCurrentY + 12.0f)];
    
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
    
    if(VALID_NOTEMPTY(self.checkBoxComponent, JACheckBoxComponent) && [self.checkBoxComponent isCheckBoxOn])
    {
        [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width,
                                                          self.shippingContentView.frame.origin.y + self.shippingContentView.frame.size.height + self.bottomView.frame.size.height)];
    }
    else
    {
        [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width,
                                                          self.shippingContentView.frame.origin.y + self.shippingContentView.frame.size.height + 6.0f + self.billingContentView.frame.size.height + self.bottomView.frame.size.height)];
    }
}

-(void)showBillingAddressForm
{
    [self.shippingHeaderLabel setText:STRING_SHIPPING_ADDRESSES];
    
    [self.billingContentView setHidden:NO];
    [self.billingContentView setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.shippingContentView.frame) + 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.billingAddressViewCurrentY + 12.0f)];
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
             
             self.checkout = object;
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
                 [self.billingDynamicForm validateFields:errorObject];
             }
             else if(VALID_NOTEMPTY(errorObject, NSArray))
             {
                 [self.billingDynamicForm checkErrors];
             }
         }];
    }
    
    [RIForm sendForm:[self.shippingDynamicForm form]
      extraArguments:self.extraParameters
          parameters:shippingParameters
        successBlock:^(id object)
     {
         self.checkout = object;
         [self.shippingDynamicForm resetValues];
         self.numberOfRequests--;
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         self.hasErrors = YES;
         self.numberOfRequests--;
         
         if (RIApiResponseNoInternetConnection == apiResponse)
         {
             [self showMessage:STRING_NO_NEWTORK success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.shippingDynamicForm validateFields:errorObject];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.shippingDynamicForm checkErrors];
         }
         else
         {
             [self showMessage:STRING_ERROR success:NO];
         }
     }];
}

-(void)finishedRequests
{
    [self hideLoading];
    
    if(self.hasErrors)
    {
        [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
        
        self.hasErrors = NO;
    }
    else
    {
        if(self.fromCheckout)
        {
            [JAUtils goToCheckout:self.checkout];
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

- (void)openPicker:(JARadioComponent *)radioComponent
{
    [self removePickerView];
    
    self.radioComponent = radioComponent;
    
    if([radioComponent isComponentWithKey:@"fk_customer_address_region"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
    {
        self.radioComponentDataset = self.regionsDataset;
        
        [self setupPickerView];
    }
    else if([radioComponent isComponentWithKey:@"fk_customer_address_city"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
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
                NSString *url = [radioComponent getApiCallUrl];
                [self showLoading];
                [RICity getCitiesForUrl:url region:[self.shippingSelectedRegion uid] successBlock:^(NSArray *regions)
                 {
                     self.shippingCitiesDataset = [regions copy];
                     self.radioComponentDataset = [regions copy];
                     
                     [self hideLoading];
                     [self setupPickerView];
                 } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error)
                 {
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
                NSString *url = [radioComponent getApiCallUrl];
                [self showLoading];
                [RICity getCitiesForUrl:url region:[self.billingSelectedRegion uid] successBlock:^(NSArray *regions)
                 {
                     self.billingCitiesDataset = [regions copy];
                     self.radioComponentDataset = [regions copy];
                     
                     [self hideLoading];
                     [self setupPickerView];
                 } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error)
                 {
                     [self hideLoading];
                 }];
            }
        }
    }
    else if([radioComponent isComponentWithKey:@"gender"])
    {
        if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY([self.radioComponent dataset], NSArray))
        {
            self.radioComponentDataset  = [[self.radioComponent dataset] copy];
            
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
                id selectedObject = [self.radioComponentDataset objectAtIndex:i];
                if(VALID_NOTEMPTY(selectedObject, RIRegion))
                {
                    if([selectedValue isEqualToString:[selectedObject uid]])
                    {
                        selectedRow = ((RIRegion*)selectedObject).name;
                        break;
                    }
                }
                else if(VALID_NOTEMPTY(selectedObject, RICity))
                {
                    if([selectedValue isEqualToString:[selectedObject uid]])
                    {
                        selectedRow = ((RICity*)selectedObject).value;
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
            if(VALID_NOTEMPTY(currentObject, RIRegion))
            {
                title = ((RIRegion*) currentObject).name;
            }
            else if(VALID_NOTEMPTY(currentObject, RICity))
            {
                title = ((RICity*) currentObject).value;
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

- (void)downloadRegions:(JARadioComponent *)regionComponent cities:(JARadioComponent*) citiesComponent
{
    if(VALID_NOTEMPTY(regionComponent, JARadioComponent))
    {
        if(!VALID_NOTEMPTY(self.regionsDataset, NSArray))
        {
            [self showLoading];
            [RIRegion getRegionsForUrl:[regionComponent getApiCallUrl] successBlock:^(NSArray *regions)
             {
                 self.regionsDataset = [regions copy];
                 
                 NSString *selectedValue = [regionComponent getSelectedValue];
                 
                 if(VALID_NOTEMPTY(selectedValue, NSString) && VALID_NOTEMPTY(regions, NSArray))
                 {
                     for(RIRegion *region in regions)
                     {
                         if([selectedValue isEqualToString:[region uid]])
                         {
                             self.shippingSelectedRegion = region;
                             self.billingSelectedRegion = region;
                             
                             [self.shippingDynamicForm setRegionValue:region];
                             [self.billingDynamicForm setRegionValue:region];
                             
                             break;
                         }
                         
                     }
                 }
                 else if(VALID_NOTEMPTY(regions, NSArray))
                 {
                     self.shippingSelectedRegion = [regions objectAtIndex:0];
                     self.billingSelectedRegion = [regions objectAtIndex:0];
                     [regionComponent setRegionValue:self.shippingSelectedRegion];
                 }
                 
                 if(VALID_NOTEMPTY(self.shippingSelectedRegion, RIRegion) && VALID_NOTEMPTY(citiesComponent, JARadioComponent))
                 {
                     [RICity getCitiesForUrl:[citiesComponent getApiCallUrl] region:[self.shippingSelectedRegion uid] successBlock:^(NSArray *cities) {
                         self.shippingCitiesDataset = [cities copy];
                         self.billingCitiesDataset = [cities copy];
                         
                         if(VALID_NOTEMPTY(cities, NSArray))
                         {
                             RICity *city = [cities objectAtIndex:0];
                             
                             self.shippingSelectedCity = city;
                             self.billingSelectedCity = city;
                             
                             [self.shippingDynamicForm setCityValue:city];
                             [self.billingDynamicForm setCityValue:city];
                         }
                         
                         [self hideLoading];
                         
                     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                         [self hideLoading];
                     }];
                 }
                 else
                 {
                     [self hideLoading];
                 }
             } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error)
             {
                 [self hideLoading];
             }];
        }
    }
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent))
    {
        if(VALID_NOTEMPTY(self.radioComponentDataset, NSArray) && selectedRow < [self.radioComponentDataset count])
        {
            id selectedObject = [self.radioComponentDataset objectAtIndex:selectedRow];
            
            if(self.shippingContentView == [self.radioComponent superview])
            {
                if(VALID_NOTEMPTY(selectedObject, RIRegion) && ![[selectedObject uid] isEqualToString:[self.shippingSelectedRegion uid]])
                {
                    self.shippingSelectedRegion = selectedObject;
                    self.shippingSelectedCity = nil;
                    self.shippingCitiesDataset = nil;
                    
                    [self.shippingDynamicForm setRegionValue:selectedObject];
                }
                else if(VALID_NOTEMPTY(selectedObject, RICity))
                {
                    self.shippingSelectedCity = selectedObject;
                    
                    [self.shippingDynamicForm setCityValue:selectedObject];
                }
                else if(VALID_NOTEMPTY(selectedObject, NSString))
                {
                    [self.radioComponent setValue:selectedObject];
                }
            }
            else if(self.billingContentView == [self.radioComponent superview])
            {
                if(VALID_NOTEMPTY(selectedObject, RIRegion) && ![[selectedObject uid] isEqualToString:[self.billingSelectedRegion uid]])
                {
                    self.billingSelectedRegion = selectedObject;
                    self.billingSelectedCity = nil;
                    self.billingCitiesDataset = nil;
                    
                    [self.billingDynamicForm setRegionValue:selectedObject];
                }
                else if(VALID_NOTEMPTY(selectedObject, RICity))
                {
                    self.billingSelectedCity = selectedObject;
                    
                    [self.billingDynamicForm setCityValue:selectedObject];
                }
                else if(VALID_NOTEMPTY(selectedObject, NSString))
                {
                    [self.radioComponent setValue:selectedObject];
                }
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
        [self.contentScrollView setFrame:CGRectMake(self.originalFrame.origin.x,
                                                    self.originalFrame.origin.y,
                                                    self.originalFrame.size.width,
                                                    self.originalFrame.size.height - height)];
        
        if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
        {
            [self.orderSummary setFrame:CGRectMake(self.orderSummaryOriginalFrame.origin.x,
                                                   self.orderSummaryOriginalFrame.origin.y,
                                                   self.orderSummaryOriginalFrame.size.width,
                                                   self.orderSummaryOriginalFrame.size.height - height)];
        }
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView setFrame:self.originalFrame];
        
        if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
        {
            [self.orderSummary setFrame:self.orderSummaryOriginalFrame];
        }
    }];
}

@end
