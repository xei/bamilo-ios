//
//  JAPaymentViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPaymentViewController.h"
#import "JACartListHeaderView.h"
#import "JAButtonWithBlur.h"
#import "JAPaymentCell.h"
#import "JACheckoutForms.h"
#import "JAUtils.h"
#import "JAOrderSummaryView.h"
#import "RICustomer.h"
#import "RICart.h"
#import "UIView+Mirror.h"
#import "UIImage+Mirror.h"
#import "JACheckoutBottomView.h"
#import "RIPaymentMethodForm.h"
#import "JAProductInfoHeaderLine.h"

@interface JAPaymentViewController ()
<UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate>
{
    // Bottom view
    JACheckoutBottomView *_bottomView;
}

// Payment methods
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UITableView *tableView;

// Coupon
@property (strong, nonatomic) UIView *couponView;
@property (strong, nonatomic) JAProductInfoHeaderLine* couponHeader;
@property (strong, nonatomic) UITextField *couponTextField;
@property (strong, nonatomic) JAClickableView *useCouponClickableView;


// Order Summary
@property (strong, nonatomic) JAOrderSummaryView *orderSummary;

@property (strong, nonatomic) RICart *cart;
@property (strong, nonatomic) RIPaymentMethodForm *paymentMethodForm;
@property (strong, nonatomic) JACheckoutForms *checkoutFormForPaymentMethod;
@property (strong, nonatomic) NSArray *paymentMethods;
@property (strong, nonatomic) NSIndexPath *collectionViewIndexSelected;
@property (strong, nonatomic) RIPaymentMethodFormOption* selectedPaymentMethod;

@property (assign, nonatomic) CGFloat contentScrollOriginalHeight;
@property (assign, nonatomic) CGFloat orderSummaryOriginalHeight;

@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAPaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Payment";
    
    self.view.backgroundColor = JAWhiteColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"CheckoutPaymentMethods" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPayment]
                                              data:[trackingDictionary copy]];
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.navBarLayout.title = STRING_CHECKOUT;
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = NO;
    
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self continueLoading];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"CheckoutPayment"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [_bottomView setNoTotal:YES];
    }else{
        [_bottomView setNoTotal:NO];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(void)continueLoading
{
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    [RICart getMultistepPaymentWithSuccessBlock:^(RICart *cart) {
        self.cart = cart;
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
        
        self.paymentMethodForm = cart.paymentMethodForm;
        
        // LIST OF AVAILABLE PAYMENT METHODS
        self.paymentMethods = [RIPaymentMethodForm getPaymentMethodsInForm:cart.paymentMethodForm];
        
        self.checkoutFormForPaymentMethod = [[JACheckoutForms alloc] initWithPaymentMethodForm:cart.paymentMethodForm width:(self.tableView.frame.size.width - [JAPaymentCell xPositionAfterCheckmark] - 6.0f)];
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [self setupViews:self.view.width toInterfaceOrientation:self.interfaceOrientation];
        [self finishedLoadingPaymentMethods];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        self.apiResponse = apiResponse;
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(continueLoading) objects:nil];
        [self hideLoading];
    }];
}

- (void) initViews
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.f,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - 64.0f)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   self.scrollView.frame.size.width,
                                                                   27.0f)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setScrollEnabled:NO];
    
    [self.scrollView addSubview:self.tableView];
    [self.view addSubview:self.scrollView];
    
    self.couponView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                               CGRectGetMaxY(self.tableView.frame),
                                                               self.scrollView.frame.size.width,
                                                               100.0f)];
    [self.couponView setBackgroundColor:JAWhiteColor];
    
    self.couponHeader = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.couponView.frame.size.width, kProductInfoHeaderLineHeight)];
    [self.couponHeader setTitle:STRING_COUPON];
    [self.couponView addSubview:self.couponHeader];
    
    self.couponTextField = [[UITextField alloc] init];
    [self.couponTextField setFont:JABodyFont];
    [self.couponTextField setTextColor:JAGreyColor];
    [self.couponTextField setValue:JATextFieldColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.couponTextField setPlaceholder:STRING_ENTER_COUPON];
    [self.couponTextField setDelegate:self];
    [self.couponView addSubview:self.couponTextField];
    
    self.useCouponClickableView = [[JAClickableView alloc] init];
    [self.useCouponClickableView setTitle:STRING_USE forState:UIControlStateNormal];
    [self.useCouponClickableView setTitleColor:JABlue1Color forState:UIControlStateNormal];
    [self.useCouponClickableView setFont:JABUTTONFont];
    [self.useCouponClickableView addTarget:self action:@selector(useCouponButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.useCouponClickableView setFrame:CGRectMake(self.couponView.frame.size.width - 6.0f - 80.0f,
                                              CGRectGetMaxY(self.couponHeader.frame),
                                              80.0f,
                                              self.couponView.frame.size.height - self.couponHeader.frame.size.height)];
    
    [self.couponView addSubview:self.useCouponClickableView];
    [self.scrollView addSubview:self.couponView];
    
    _bottomView = [[JACheckoutBottomView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         self.view.frame.size.height - 64.0f - _bottomView.frame.size.height,
                                                                         self.view.frame.size.width,
                                                                         _bottomView.frame.size.height) orientation:self.interfaceOrientation];
    
    [self.view addSubview:_bottomView];
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.scrollView setFrame:CGRectMake(0.0f,
                                         0.f,
                                         width,
                                         self.view.frame.size.height)];
    self.contentScrollOriginalHeight = self.scrollView.frame.size.height;
    
    if(VALID_NOTEMPTY(self.orderSummary, JAOrderSummaryView))
    {
        [self.orderSummary removeFromSuperview];
        self.orderSummary = nil;
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)  && (width < self.view.frame.size.width))
    {
        CGFloat orderSummaryRightMargin = 6.0f;
        self.orderSummary = [[JAOrderSummaryView alloc] initWithFrame:CGRectMake(width,
                                                                                 0.f,
                                                                                 self.view.frame.size.width - width - orderSummaryRightMargin,
                                                                                 self.view.frame.size.height)];
        [self.orderSummary loadWithCart:self.cart shippingMethod:YES];
        [self.view addSubview:self.orderSummary];
        self.orderSummaryOriginalHeight = self.orderSummary.frame.size.height;
    }
    
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                        self.tableView.frame.origin.y,
                                        self.scrollView.frame.size.width,
                                        self.tableView.frame.size.height)];
    
    if(VALID_NOTEMPTY(self.checkoutFormForPaymentMethod, JACheckoutForms) && VALID_NOTEMPTY(self.checkoutFormForPaymentMethod.paymentMethodFormViews, NSMutableDictionary))
    {
        NSArray *keys = [self.checkoutFormForPaymentMethod.paymentMethodFormViews allKeys];
        for(NSString *key in keys)
        {
            UIView *view = [self.checkoutFormForPaymentMethod.paymentMethodFormViews objectForKey:key];
            if(VALID_NOTEMPTY(view, UIView))
            {
                [view removeFromSuperview];
            }
        }
    }
    
    self.checkoutFormForPaymentMethod = [[JACheckoutForms alloc] initWithPaymentMethodForm:self.cart.paymentMethodForm width:(self.tableView.frame.size.width - [JAPaymentCell xPositionAfterCheckmark] - 6.0f)];
    
    [self.couponView setFrame:CGRectMake(self.couponView.frame.origin.x,
                                         CGRectGetMaxY(self.tableView.frame),
                                         self.scrollView.frame.size.width,
                                         self.couponView.frame.size.height)];

    [self.couponHeader setFrame:CGRectMake(0.0f, 0.0f, self.couponView.frame.size.width, kProductInfoHeaderLineHeight)];
    
    BOOL saveCouponTextFieldEnabled = self.couponTextField.enabled;
    UIColor* saveCouponTextFieldColor = self.couponTextField.textColor;
    NSString* saveCouponTextFieldText = self.couponTextField.text;
    [self.couponTextField removeFromSuperview];
    self.couponTextField = [[UITextField alloc] init];
    [self.couponTextField setFont:JABodyFont];
    [self.couponTextField setTextColor:JAGreyColor];
    [self.couponTextField setValue:JATextFieldColor forKeyPath:@"_placeholderLabel.textColor"];
    [self.couponTextField setPlaceholder:STRING_ENTER_COUPON];
    [self.couponTextField setDelegate:self];
    [self.couponView addSubview:self.couponTextField];
    self.couponTextField.textAlignment = NSTextAlignmentLeft;
    self.couponTextField.frame = CGRectMake(16.0f,
                                            CGRectGetMaxY(self.couponHeader.frame) + 10.0f,
                                            self.couponView.frame.size.width - 16.0f - 5.0f - self.useCouponClickableView.frame.size.width,
                                            30.0f);
    self.couponTextField.enabled = saveCouponTextFieldEnabled;
    self.couponTextField.textColor = saveCouponTextFieldColor;
    self.couponTextField.text = saveCouponTextFieldText;
    
    [self.useCouponClickableView setFrame:CGRectMake(self.couponView.frame.size.width - 6.0f - self.useCouponClickableView.frame.size.width,
                                                     CGRectGetMaxY(self.couponHeader.frame),
                                                     self.useCouponClickableView.frame.size.width,
                                                     self.useCouponClickableView.frame.size.height)];
    
    if (VALID(self.cart.couponMoneyValue, NSNumber)) {
        self.couponTextField.text = self.cart.couponCode;
        [self.useCouponClickableView setTitle:STRING_REMOVE forState:UIControlStateNormal];
        [self.couponTextField setEnabled:NO];
        [self.useCouponClickableView setEnabled:YES];
    }
    
    [_bottomView setFrame:CGRectMake(0.0f,
                                     self.view.frame.size.height - 56,
                                     width,
                                     56)];
    [_bottomView setTotalValue:self.cart.cartValueFormatted];
    [_bottomView setButtonText:STRING_NEXT target:self action:@selector(nextStepButtonPressed)];
    if (!VALID_NOTEMPTY(self.paymentMethods,NSArray) && self.cart.cartValue.integerValue > 0) {
        [_bottomView disableButton];
    }
    
    [self reloadTableView];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

-(void)finishedLoadingPaymentMethods
{
    if(VALID_NOTEMPTY(self.cart.couponCode, NSString))
    {
        [self.couponTextField setText:self.cart.couponCode];
        [self.couponTextField setEnabled:NO];
        [self.useCouponClickableView setTitle:STRING_REMOVE forState:UIControlStateNormal];
    }
    else
    {
        [self.useCouponClickableView setTitle:STRING_USE forState:UIControlStateNormal];
        if(!VALID_NOTEMPTY([self.couponTextField text], NSString))
        {
            [self.useCouponClickableView setEnabled:NO];
        }
    }
    
    self.collectionViewIndexSelected = [NSIndexPath indexPathForItem:[RIPaymentMethodForm getSelectedPaymentMethodsInForm:self.paymentMethodForm] inSection:0];
    
    self.selectedPaymentMethod = [self.paymentMethods objectAtIndex:self.collectionViewIndexSelected.row];
    
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
    
    [self hideLoading];
}

-(void)reloadTableView
{
    if (VALID_NOTEMPTY(self.checkoutFormForPaymentMethod.paymentMethodFormViews, NSMutableDictionary) || VALID_NOTEMPTY(self.paymentMethods, NSArray)) {
        CGFloat tableViewHeight = [self tableView:self.tableView heightForHeaderInSection:0];
        
        if(VALID_NOTEMPTY(self.paymentMethods, NSArray))
        {
            for (int i = 0; i < self.paymentMethods.count; i++) {
                CGFloat height = [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                tableViewHeight += height;
            }
        } else {
            if ([self.checkoutFormForPaymentMethod getPaymentMethodViewHeight:nil]) {
                tableViewHeight += [self.checkoutFormForPaymentMethod getPaymentMethodViewHeight:nil];
            } else
                tableViewHeight += 44.0f;
        }
            
        [UIView animateWithDuration:0.5f
                         animations:^{
                             [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                                                 self.tableView.frame.origin.y,
                                                                 self.tableView.frame.size.width,
                                                                 tableViewHeight)];
                             
                             [self.couponView setFrame:CGRectMake(self.couponView.frame.origin.x,
                                                                  CGRectGetMaxY(self.tableView.frame),
                                                                  self.scrollView.frame.size.width,
                                                                  self.couponView.frame.size.height)];
                         }];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                                   CGRectGetMaxY(self.couponView.frame) + _bottomView.frame.size.height)];
    }
    
    [self.tableView reloadData];
}

- (void)useCouponButtonPressed
{
    [self.couponTextField resignFirstResponder];
    
    [self.couponTextField setTextColor:JAGreyColor];
    
    [self showLoading];
    NSString *voucherCode = [self.couponTextField text];
    
    if(VALID([[self cart] couponMoneyValue], NSNumber))
    {
        [RICart removeVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
            self.cart = cart;
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
            NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
            [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
            [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                      data:[trackingDictionary copy]];
            
            [self.useCouponClickableView setTitle:STRING_USE forState:UIControlStateNormal];
            [self.couponTextField setEnabled: YES];
            [self.couponTextField setText:@""];
            
            [self continueLoading];
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self hideLoading];
            
            [self.couponTextField setTextColor:JARed1Color];
        }];
    }
    else
    {
        [RICart addVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
            self.cart = cart;
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
            NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
            [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
            [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                      data:[trackingDictionary copy]];
            
            [self.useCouponClickableView setTitle:STRING_REMOVE forState:UIControlStateNormal];
            [self.couponTextField setEnabled:NO];
            
            [self continueLoading];
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self hideLoading];
            
            [self.couponTextField setTextColor:JARed1Color];
        }];
    }
}

-(void)nextStepButtonPressed
{
    if (!self.selectedPaymentMethod && self.cart.cartValue.integerValue > 0) {
        return;
    }
    [self showLoading];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[RIPaymentMethodForm getParametersForForm:self.paymentMethodForm]];
    
    [parameters addEntriesFromDictionary:[self.checkoutFormForPaymentMethod getValuesForPaymentMethod:self.selectedPaymentMethod]];
    
    
    [RICart setMultistepPayment:parameters
                   successBlock:^(NSString *nextStep) {
                       
                       NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                       [trackingDictionary setValue:self.selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                       [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentSuccess]
                                                                 data:[trackingDictionary copy]];
                       
                       [JAUtils goToNextStep:nextStep
                                    userInfo:nil];
                       
                       [self hideLoading];
                   } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                       
                       NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                       [trackingDictionary setValue:self.selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                       [trackingDictionary setValue:self.cart.cartValueEuroConverted forKey:kRIEventTotalTransactionKey];
                       [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentFail]
                                                                 data:[trackingDictionary copy]];
                       
                       [self onErrorResponse:apiResponse messages:@[STRING_ERROR_SETTING_PAYMENT_METHOD] showAsMessage:YES selector:@selector(nextStepButtonPressed) objects:nil];
                       [self hideLoading];
                   }];
}

#pragma mark UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kProductInfoHeaderLineHeight;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = STRING_PAYMENT;
    
    UIView* content = [UIView new];
    [content setFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, kProductInfoHeaderLineHeight)];
    
    JAProductInfoHeaderLine* headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0.0f, 0.0f, content.frame.size.width, kProductInfoHeaderLineHeight)];
    [headerLine setTitle:title];
    
    if (RI_IS_RTL) {
        [headerLine flipAllSubviews];
    }
    
    [content addSubview:headerLine];
    
    return content;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    if(tableView == self.tableView){
        if(VALID_NOTEMPTY(self.paymentMethods, NSArray))
        {
            numberOfItemsInSection = [self.paymentMethods count];
        } else {
            if (VALID_NOTEMPTY(self.checkoutFormForPaymentMethod.paymentMethodFormViews, NSMutableDictionary)) {
                numberOfItemsInSection = 1;
            }
        }
    }
    return numberOfItemsInSection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44.0f;
    if(indexPath.row == self.collectionViewIndexSelected.row)
    {
        RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
        height += [self.checkoutFormForPaymentMethod getPaymentMethodViewHeight:paymentMethod] + 10.0f;
    }
    return height;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (VALID_NOTEMPTY(self.paymentMethods, NSArray)) {
        
        // Payment method title cell
        
        RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
        if(VALID_NOTEMPTY(paymentMethod, RIPaymentMethodFormOption))
        {
            NSString *cellIdentifier = @"paymentListCell";
            JAPaymentCell *paymentListCell = (JAPaymentCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (ISEMPTY(paymentListCell)) {
                paymentListCell = [[JAPaymentCell alloc] init];
                [paymentListCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            BOOL isSelected = NO;
            if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath) && indexPath.row == self.collectionViewIndexSelected.row)
            {
                isSelected = YES;
            }
            
            [paymentListCell loadWithPaymentMethod:paymentMethod
                                 paymentMethodView:[self.checkoutFormForPaymentMethod getPaymentMethodView:paymentMethod]
                                        isSelected:isSelected
                                             width:self.tableView.frame.size.width];
            
            paymentListCell.clickableView.tag = indexPath.row;
            [paymentListCell.clickableView addTarget:self action:@selector(clickViewSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            cell = paymentListCell;
        }

    } else {
    
        if (indexPath.row == 0 && VALID_NOTEMPTY(self.checkoutFormForPaymentMethod.paymentMethodFormViews, NSMutableDictionary)) {
            
            NSString *cellIdentifier = @"paymentListCell_Empty";
            
            JAPaymentCell *paymentListCell = (JAPaymentCell*) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (ISEMPTY(paymentListCell)) {
                paymentListCell = [[JAPaymentCell alloc] init];
                [paymentListCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
            
            RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
            
            NSString * methodName = [(RIPaymentMethodFormField*)[self.paymentMethodForm.fields firstObject] value];
            
            [paymentListCell loadNoPaymentMethod:methodName paymentMethodView:[self.checkoutFormForPaymentMethod getPaymentMethodView:paymentMethod]];
            
            cell = paymentListCell;
        }
    
    }
    
    return cell;
}


- (void)clickViewSelected:(UIControl*)sender
{
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [self.couponTextField resignFirstResponder];
    
    if(tableView == self.tableView && VALID_NOTEMPTY(self.paymentMethods, NSArray))
    {
        if(indexPath.row != self.collectionViewIndexSelected.row && indexPath.row < [self.paymentMethods count])
        {
            // Payment method title cell
            self.selectedPaymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
            
            RIPaymentMethodFormField* field = [self.paymentMethodForm.fields firstObject];
            if (VALID_NOTEMPTY(field, RIPaymentMethodFormField)) {
                field.value = self.selectedPaymentMethod.value;
            }
            
            self.collectionViewIndexSelected = indexPath;
            
            [self reloadTableView];
        }
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
    if (NSEqualRanges(range, textFieldRange) && [string length] == 0)
    {
        [self.useCouponClickableView setEnabled:NO];
    }
    else
    {
        [self.useCouponClickableView setEnabled:YES];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.couponTextField setTextColor:JAGreyColor];
}

#pragma mark Observers
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
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x,
                                             self.scrollView.frame.origin.y,
                                             self.scrollView.frame.size.width,
                                             self.contentScrollOriginalHeight - height)];
        
        [self.orderSummary setFrame:CGRectMake(self.orderSummary.frame.origin.x,
                                               self.orderSummary.frame.origin.y,
                                               self.orderSummary.frame.size.width,
                                               self.orderSummaryOriginalHeight - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x,
                                             self.scrollView.frame.origin.y,
                                             self.scrollView.frame.size.width,
                                             self.contentScrollOriginalHeight)];
        
        [self.orderSummary setFrame:CGRectMake(self.orderSummary.frame.origin.x,
                                               self.orderSummary.frame.origin.y,
                                               self.orderSummary.frame.size.width,
                                               self.orderSummaryOriginalHeight)];
    }];
}

@end
