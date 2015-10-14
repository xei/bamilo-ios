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

@interface JAPaymentViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UITextFieldDelegate>
{
    // Bottom view
    JACheckoutBottomView *_bottomView;
}

// Steps
@property (weak, nonatomic) IBOutlet UIImageView *stepBackground;
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

// Payment methods
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UICollectionView *collectionView;

// Coupon
@property (strong, nonatomic) UIView *couponView;
@property (strong, nonatomic) UILabel *couponTitle;
@property (strong, nonatomic) UIView *couponTitleSeparator;
@property (strong, nonatomic) UITextField *couponTextField;
@property (strong, nonatomic) UIButton *useCouponButton;


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
    
    self.navBarLayout.showCartButton = NO;
    
    self.stepBackground.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepView.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepIcon.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepLabel.font = [UIFont fontWithName:kFontBoldName size:self.stepLabel.font.pointSize];
    [self.stepLabel setText:STRING_CHECKOUT_PAYMENT];
    
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
    
    [RICart getPaymentMethodFormWithSuccessBlock:^(RICart *cart)
     {
         self.cart = cart;
         
         self.paymentMethodForm = cart.paymentMethodForm;
         
         // LIST OF AVAILABLE PAYMENT METHODS
         self.paymentMethods = [RIPaymentMethodForm getPaymentMethodsInForm:cart.paymentMethodForm];
         
         self.checkoutFormForPaymentMethod = [[JACheckoutForms alloc] initWithPaymentMethodForm:cart.paymentMethodForm width:(self.view.frame.size.width - 12.0f)];
         [self removeErrorView];
         [self finishedLoadingPaymentMethods];
     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages)
     {
         self.apiResponse = apiResponse;
         if(RIApiResponseMaintenancePage == apiResponse)
         {
             [self showMaintenancePage:@selector(continueLoading) objects:nil];
         }
         else if(RIApiResponseKickoutView == apiResponse)
         {
             [self showKickoutView:@selector(continueLoading) objects:nil];
         }
         else
         {
             BOOL noConnection = NO;
             if (RIApiResponseNoInternetConnection == apiResponse)
             {
                 noConnection = YES;
             }
             
             [self showErrorView:noConnection startingY:0.0f selector:@selector(continueLoading) objects:nil];
         }
         [self hideLoading];
     }];
}

- (void) initViews
{
    [self setupStepView:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.stepBackground.frame.size.height,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - self.stepBackground.frame.size.height - 64.0f)];
    
    UICollectionViewFlowLayout* collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewFlowLayout setMinimumLineSpacing:0.0f];
    [collectionViewFlowLayout setMinimumInteritemSpacing:0.0f];
    [collectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [collectionViewFlowLayout setItemSize:CGSizeZero];
    [collectionViewFlowLayout setHeaderReferenceSize:CGSizeZero];
    
    UINib *paymentListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    UINib *paymentListCellNib = [UINib nibWithNibName:@"JAPaymentCell" bundle:nil];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(6.0f,
                                                                             6.0f,
                                                                             self.scrollView.frame.size.width - 12.0f,
                                                                             27.0f) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.layer.cornerRadius = 5.0f;
    [self.collectionView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.collectionView registerNib:paymentListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"paymentListHeader"];
    [self.collectionView registerNib:paymentListCellNib forCellWithReuseIdentifier:@"paymentListCell"];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setScrollEnabled:NO];
    
    [self.scrollView addSubview:self.collectionView];
    [self.view addSubview:self.scrollView];
    
    self.couponView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                               CGRectGetMaxY(self.collectionView.frame) + 6.0f,
                                                               self.scrollView.frame.size.width - 12.0f,
                                                               86.0f)];
    [self.couponView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.couponView.layer.cornerRadius = 5.0f;
    
    self.couponTitle = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                                 0.0f,
                                                                 self.couponView.frame.size.width - 12.0f,
                                                                 26.0f)];
    [self.couponTitle setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.couponTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.couponTitle setText:STRING_COUPON];
    [self.couponTitle setBackgroundColor:[UIColor clearColor]];
    [self.couponView addSubview:self.couponTitle];
    
    self.couponTitleSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         CGRectGetMaxY(self.couponTitle.frame),
                                                                         self.couponView.frame.size.width,
                                                                         1.0f)];
    [self.couponTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.couponView addSubview:self.couponTitleSeparator];
    
    UIImage *useCouponImageNormal = [UIImage imageNamed:@"useCoupon_normal"];
    
    self.couponTextField = [[UITextField alloc] init];
    [self.couponTextField setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
    [self.couponTextField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    [self.couponTextField setPlaceholder:STRING_ENTER_COUPON];
    [self.couponTextField setDelegate:self];
    [self.couponView addSubview:self.couponTextField];
    
    self.useCouponButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.useCouponButton setTitle:STRING_USE forState:UIControlStateNormal];
    [self.useCouponButton setBackgroundImage:useCouponImageNormal forState:UIControlStateNormal];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_highlighted"] forState:UIControlStateHighlighted];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_highlighted"] forState:UIControlStateSelected];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_disabled"] forState:UIControlStateDisabled];
    [self.useCouponButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.useCouponButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.useCouponButton addTarget:self action:@selector(useCouponButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.useCouponButton setFrame:CGRectMake(CGRectGetMaxX(self.couponTextField.frame) + 5.0f,
                                              CGRectGetMaxY(self.couponTitleSeparator.frame) + 17.0f,
                                              useCouponImageNormal.size.width,
                                              useCouponImageNormal.size.height)];
    
    [self.couponView addSubview:self.useCouponButton];
    [self.scrollView addSubview:self.couponView];
    
    _bottomView = [[JACheckoutBottomView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         self.view.frame.size.height - 64.0f - _bottomView.frame.size.height,
                                                                         self.view.frame.size.width,
                                                                         _bottomView.frame.size.height) orientation:self.interfaceOrientation];
    
    [self.view addSubview:_bottomView];
}

- (void) setupStepView:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat stepViewLeftMargin = 188.0f;
    NSString *stepBackgroundImageName = @"headerCheckoutStep4";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            stepViewLeftMargin =  563.0f;
            stepBackgroundImageName = @"headerCheckoutStep4Landscape";
        }
        else
        {
            stepViewLeftMargin = 435.0f;
            stepBackgroundImageName = @"headerCheckoutStep4Portrait";
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
    [self setupStepView:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
    [self.scrollView setFrame:CGRectMake(0.0f,
                                         self.stepBackground.frame.size.height,
                                         width,
                                         self.view.frame.size.height - self.stepBackground.frame.size.height)];
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
                                                                                 self.stepBackground.frame.size.height,
                                                                                 self.view.frame.size.width - width - orderSummaryRightMargin,
                                                                                 self.view.frame.size.height - self.stepBackground.frame.size.height)];
        [self.orderSummary loadWithCart:self.cart shippingMethod:YES];
        [self.view addSubview:self.orderSummary];
        self.orderSummaryOriginalHeight = self.orderSummary.frame.size.height;
    }
    
    [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                             self.collectionView.frame.origin.y,
                                             self.scrollView.frame.size.width - 12.0f,
                                             self.collectionView.frame.size.height)];
    
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
    
    self.checkoutFormForPaymentMethod = [[JACheckoutForms alloc] initWithPaymentMethodForm:self.cart.paymentMethodForm width:self.collectionView.frame.size.width];
    
    [self.couponView setFrame:CGRectMake(self.couponView.frame.origin.x,
                                         CGRectGetMaxY(self.collectionView.frame) + 6.0f,
                                         self.scrollView.frame.size.width - 12.0f,
                                         self.couponView.frame.size.height)];
    
    self.couponTitle.textAlignment = NSTextAlignmentLeft;
    [self.couponTitle  setFrame:CGRectMake(self.couponTitle.frame.origin.x,
                                           self.couponTitle.frame.origin.y,
                                           self.couponView.frame.size.width - 12.0f,
                                           self.couponTitle.frame.size.height)];
    
    [self.couponTitleSeparator setFrame:CGRectMake(self.couponTitleSeparator.frame.origin.x,
                                                   CGRectGetMaxY(self.couponTitle.frame),
                                                   self.couponView.frame.size.width,
                                                   self.couponTitleSeparator.frame.size.height)];
    
    BOOL saveCouponTextFieldEnabled = self.couponTextField.enabled;
    UIColor* saveCouponTextFieldColor = self.couponTextField.textColor;
    NSString* saveCouponTextFieldText = self.couponTextField.text;
    [self.couponTextField removeFromSuperview];
    self.couponTextField = [[UITextField alloc] init];
    [self.couponTextField setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
    [self.couponTextField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    [self.couponTextField setPlaceholder:STRING_ENTER_COUPON];
    [self.couponTextField setDelegate:self];
    [self.couponView addSubview:self.couponTextField];
    self.couponTextField.textAlignment = NSTextAlignmentLeft;
    self.couponTextField.frame = CGRectMake(6.0f,
                                            CGRectGetMaxY(self.couponTitleSeparator.frame) + 17.0f,
                                            self.couponView.frame.size.width - 12.0f - 5.0f - self.useCouponButton.frame.size.width,
                                            30.0f);
    self.couponTextField.enabled = saveCouponTextFieldEnabled;
    self.couponTextField.textColor = saveCouponTextFieldColor;
    self.couponTextField.text = saveCouponTextFieldText;
    
    [self.useCouponButton setFrame:CGRectMake(CGRectGetMaxX(self.couponTextField.frame) + 5.0f,
                                              CGRectGetMaxY(self.couponTitleSeparator.frame) + 17.0f,
                                              self.useCouponButton.frame.size.width,
                                              self.useCouponButton.frame.size.height)];
    
    if (VALID(self.cart.couponMoneyValue, NSNumber)) {
        self.couponTextField.text = self.cart.couponCode;
        [self.useCouponButton setTitle:STRING_REMOVE forState:UIControlStateNormal];
        [self.couponTextField setEnabled:NO];
        [self.useCouponButton setEnabled:YES];
    }
    
    [_bottomView setFrame:CGRectMake(0.0f,
                                            self.view.frame.size.height - 56,
                                            width,
                                     56)];
    [_bottomView setTotalValue:self.cart.cartValueFormatted];
    [_bottomView setButtonText:STRING_NEXT target:self action:@selector(nextStepButtonPressed)];
    if (! VALID_NOTEMPTY(self.paymentMethods,NSArray)) {
        [_bottomView disableButton];
    }
    
    [self reloadCollectionView];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

-(void)finishedLoadingPaymentMethods
{
    if(VALID_NOTEMPTY(self.cart.discountCouponCode, NSString))
    {
        [self.couponTextField setText:self.cart.discountCouponCode];
        [self.couponTextField setEnabled:NO];
        [self.useCouponButton setTitle:STRING_REMOVE forState:UIControlStateNormal];
    }
    else
    {
        [self.useCouponButton setTitle:STRING_USE forState:UIControlStateNormal];
        if(!VALID_NOTEMPTY([self.couponTextField text], NSString))
        {
            [self.useCouponButton setEnabled:NO];
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

-(void)reloadCollectionView
{
    if (VALID_NOTEMPTY(self.checkoutFormForPaymentMethod.paymentMethodFormViews, NSMutableDictionary) || VALID_NOTEMPTY(self.paymentMethods, NSArray)) {
        CGFloat collectionViewHeight = 27.0f;
        
        if(VALID_NOTEMPTY(self.paymentMethods, NSArray))
        {
            collectionViewHeight += ([self.paymentMethods count] * 44.0f);
            
            if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath))
            {
                RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:self.collectionViewIndexSelected.row];
                collectionViewHeight += [self.checkoutFormForPaymentMethod getPaymentMethodViewHeight:paymentMethod];
            }
            
        } else {
                collectionViewHeight += 44.0f;
            }
            
        [UIView animateWithDuration:0.5f
                         animations:^{
                             [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                                                      self.collectionView.frame.origin.y,
                                                                      self.collectionView.frame.size.width,
                                                                      collectionViewHeight)];
                             
                             [self.couponView setFrame:CGRectMake(self.couponView.frame.origin.x,
                                                                  CGRectGetMaxY(self.collectionView.frame) + 6.0f,
                                                                  self.scrollView.frame.size.width - 12.0f,
                                                                  self.couponView.frame.size.height)];
                         }];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                                   self.collectionView.frame.origin.y + collectionViewHeight + 92.0f + _bottomView.frame.size.height + 6.0f)];
    }
    
    [self.collectionView reloadData];
}

- (void)useCouponButtonPressed
{
    [self.couponTextField resignFirstResponder];
    
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
    
    [self showLoading];
    NSString *voucherCode = [self.couponTextField text];
    
    if(VALID([[self cart] couponMoneyValue], NSNumber))
    {
        [RICart removeVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
            self.cart = cart;
            NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
            [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
            [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                      data:[trackingDictionary copy]];
            
            [self.useCouponButton setTitle:STRING_USE forState:UIControlStateNormal];
            [self.couponTextField setEnabled: YES];
            [self.couponTextField setText:@""];
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self hideLoading];
            
            [self.couponTextField setTextColor:UIColorFromRGB(0xcc0000)];
        }];
    }
    else
    {
        [RICart addVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
            self.cart = cart;
            NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
            [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
            [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                      data:[trackingDictionary copy]];
            
            [self.useCouponButton setTitle:STRING_REMOVE forState:UIControlStateNormal];
            [self.couponTextField setEnabled:NO];
            [self hideLoading];
            
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self hideLoading];
            
            [self.couponTextField setTextColor:UIColorFromRGB(0xcc0000)];
        }];
    }
}

-(void)nextStepButtonPressed
{
    if (!self.selectedPaymentMethod) {
        return;
    }
    [self showLoading];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[RIPaymentMethodForm getParametersForForm:self.paymentMethodForm]];
    
    [parameters setObject:self.selectedPaymentMethod.value forKey:@"paymentMethodForm[payment_method]"];
    
    [parameters addEntriesFromDictionary:[self.checkoutFormForPaymentMethod getValuesForPaymentMethod:self.selectedPaymentMethod]];
    
    [RICart setPaymentMethod:self.paymentMethodForm
                  parameters:parameters
                successBlock:^(RICart *cart) {
                    
                    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                    [trackingDictionary setValue:self.selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentSuccess]
                                                              data:[trackingDictionary copy]];
                    
                    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:@"cart"];
                    [JAUtils goToNextStep:cart.nextStep
                                 userInfo:userInfo];
                    
                    [self hideLoading];
                } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                    
                    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                    [trackingDictionary setValue:self.selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                    [trackingDictionary setValue:self.cart.cartValue forKey:kRIEventTotalTransactionKey];
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentFail]
                                                              data:[trackingDictionary copy]];
                    
                    if (RIApiResponseNoInternetConnection == apiResponse)
                    {
                        [self showMessage:STRING_NO_CONNECTION success:NO];
                    }
                    else
                    {
                        [self showMessage:STRING_ERROR_SETTING_PAYMENT_METHOD success:NO];
                    }
                    
                    [self hideLoading];
                }];
}

#pragma mark UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize sizeForItemAtIndexPath = CGSizeZero;
    
    if(collectionView == self.collectionView)
    {
        // Payment method cell
        if(indexPath.row == self.collectionViewIndexSelected.row)
        {
            RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
            sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 44.0f +[self.checkoutFormForPaymentMethod getPaymentMethodViewHeight:paymentMethod]);
        }
        else
        {
            sizeForItemAtIndexPath = CGSizeMake(self.collectionView.frame.size.width, 44.0f);
        }
    }
    
    return sizeForItemAtIndexPath;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize referenceSizeForHeaderInSection = CGSizeZero;
    if(collectionView == self.collectionView)
    {
        referenceSizeForHeaderInSection = CGSizeMake(self.collectionView.frame.size.width, 27.0f);
    }
    
    return referenceSizeForHeaderInSection;
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    if(collectionView == self.collectionView){
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

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if(collectionView == self.collectionView){
        if(VALID_NOTEMPTY(self.paymentMethods, NSArray)) {
            // Payment method title cell
            
            RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
            if(VALID_NOTEMPTY(paymentMethod, RIPaymentMethodFormOption))
            {
                NSString *cellIdentifier = @"paymentListCell";
                
                JAPaymentCell *paymentListCell = (JAPaymentCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                
                BOOL isSelected = NO;
                if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath) && indexPath.row == self.collectionViewIndexSelected.row)
                {
                    isSelected = YES;
                }
                
                [paymentListCell loadWithPaymentMethod:paymentMethod
                                     paymentMethodView:[self.checkoutFormForPaymentMethod getPaymentMethodView:paymentMethod]
                                            isSelected:isSelected];
                
                paymentListCell.clickableView.tag = indexPath.row;
                [paymentListCell.clickableView addTarget:self action:@selector(clickViewSelected:) forControlEvents:UIControlEventTouchUpInside];
                
                if(indexPath.row == ([self.paymentMethods count] - 1))
                {
                    [paymentListCell.separator setHidden:YES];
                }
                
                cell = paymentListCell;
            }
        } else {
            if (indexPath.row == 0 && VALID_NOTEMPTY(self.checkoutFormForPaymentMethod.paymentMethodFormViews, NSMutableDictionary)) {
                
                NSString *cellIdentifier = @"paymentListCell";
                
                JAPaymentCell *paymentListCell = (JAPaymentCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
                
                RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
                
                NSString * methodName = [(RIPaymentMethodFormField*)[self.paymentMethodForm.fields firstObject] value];
                
                [paymentListCell loadNoPaymentMethod:methodName paymentMethodView:[self.checkoutFormForPaymentMethod getPaymentMethodView:paymentMethod]];

                [paymentListCell.separator setHidden:YES];

                cell = paymentListCell;
            }
        }
    }
    
    return cell;
}

- (void)clickViewSelected:(UIControl*)sender
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"paymentListHeader" forIndexPath:indexPath];
        
        if(collectionView == self.collectionView)
        {
            [headerView loadHeaderWithText:STRING_PAYMENT width:self.collectionView.frame.size.width];
        }
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.couponTextField resignFirstResponder];
    
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.paymentMethods, NSArray))
    {
        if(indexPath.row != self.collectionViewIndexSelected.row && indexPath.row < [self.paymentMethods count])
        {
            // Payment method title cell
            self.selectedPaymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
            
            self.collectionViewIndexSelected = indexPath;
            
            [self reloadCollectionView];
        }
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
    if (NSEqualRanges(range, textFieldRange) && [string length] == 0)
    {
        [self.useCouponButton setEnabled:NO];
    }
    else
    {
        [self.useCouponButton setEnabled:YES];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
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
