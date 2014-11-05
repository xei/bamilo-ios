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
#import "RICheckout.h"
#import "RICustomer.h"
#import "RICart.h"

@interface JAPaymentViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UITextFieldDelegate>

// Steps
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepIconLeftConstrain;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLabelWidthConstrain;

// Payment methods
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UICollectionView *collectionView;

// Coupon
@property (strong, nonatomic) UIView *couponView;
@property (strong, nonatomic) UILabel *couponTitle;
@property (strong, nonatomic) UIView *couponTitleSeparator;
@property (strong, nonatomic) UITextField *couponTextField;
@property (strong, nonatomic) UIButton *useCouponButton;

// Bottom view
@property (strong, nonatomic) JAButtonWithBlur *bottomView;

@property (strong, nonatomic) RICheckout *checkout;
@property (strong, nonatomic) RICart *cart;
@property (strong, nonatomic) RIPaymentMethodForm *paymentMethodForm;
@property (strong, nonatomic) JACheckoutForms *checkoutFormForPaymentMethod;
@property (strong, nonatomic) NSArray *paymentMethods;
@property (strong, nonatomic) NSIndexPath *collectionViewIndexSelected;
@property (strong, nonatomic) RIPaymentMethodFormOption* selectedPaymentMethod;

@property (assign, nonatomic) CGRect keyboardFrame;

@end

@implementation JAPaymentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Payment";
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    [center addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"CheckoutPaymentMethods" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];

    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPayment]
                                              data:[trackingDictionary copy]];
    
    self.navBarLayout.title = STRING_CHECKOUT;
    
    self.navBarLayout.showCartButton = NO;
    
    [self setupViews];
    
    [self continueLoading];
}

-(void)continueLoading
{
    [self showLoading];
    [RICheckout getPaymentMethodFormWithSuccessBlock:^(RICheckout *checkout)
     {
         self.checkout = checkout;
         self.cart = checkout.cart;
         
         self.paymentMethodForm = checkout.paymentMethodForm;
         
         // LIST OF AVAILABLE PAYMENT METHODS
         self.paymentMethods = [RIPaymentMethodForm getPaymentMethodsInForm:checkout.paymentMethodForm];
         
         self.checkoutFormForPaymentMethod = [[JACheckoutForms alloc] initWithPaymentMethodForm:checkout.paymentMethodForm];
         
         [self finishedLoadingPaymentMethods];
     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages)
     {
         if(RIApiResponseMaintenancePage == apiResponse)
         {
             [self showMaintenancePage:@selector(continueLoading) objects:nil];
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
     }];
}

-(void)setupViews
{
    CGFloat availableWidth = self.stepView.frame.size.width;
    
    [self.stepLabel setText:STRING_CHECKOUT_PAYMENT];
    [self.stepLabel sizeToFit];
    
    CGFloat realWidth = self.stepIcon.frame.size.width + 6.0f + self.stepLabel.frame.size.width;
    
    if(availableWidth >= realWidth)
    {
        CGFloat xStepIconValue = (availableWidth - realWidth) / 2;
        self.stepIconLeftConstrain.constant = xStepIconValue;
        self.stepLabelWidthConstrain.constant = self.stepLabel.frame.size.width;
    }
    else
    {
        self.stepLabelWidthConstrain.constant = (availableWidth - self.stepIcon.frame.size.width - 6.0f);
        self.stepIconLeftConstrain.constant = 0.0f;
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, self.view.frame.size.width, self.view.frame.size.height - 21.0f - 64.0f)];
    
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
                                                                             26.0f) collectionViewLayout:collectionViewFlowLayout];
    self.collectionView.layer.cornerRadius = 5.0f;
    [self.collectionView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.collectionView registerNib:paymentListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"paymentListHeader"];
    [self.collectionView registerNib:paymentListCellNib forCellWithReuseIdentifier:@"paymentListCell"];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView setScrollEnabled:NO];
    
    [self.scrollView addSubview:self.collectionView];
    [self.view addSubview:self.scrollView];
    
    self.couponView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, CGRectGetMaxY(self.collectionView.frame) + 6.0f, 308.0f, 86.0f)];
    [self.couponView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.couponView.layer.cornerRadius = 5.0f;
    
    self.couponTitle = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 0.0f, 280.0f, 25.0f)];
    [self.couponTitle setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.couponTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.couponTitle setText:STRING_COUPON];
    [self.couponTitle setBackgroundColor:[UIColor clearColor]];
    [self.couponView addSubview:self.couponTitle];
    
    self.couponTitleSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.couponTitle.frame), 308.0f, 1.0f)];
    [self.couponTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.couponView addSubview:self.couponTitleSeparator];
    
    self.couponTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0f, CGRectGetMaxY(self.couponTitleSeparator.frame) + 17.0f, 240.0f, 30.0f)];
    [self.couponTextField setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
    [self.couponTextField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    [self.couponTextField setPlaceholder:STRING_ENTER_COUPON];
    [self.couponTextField setDelegate:self];
    [self.couponView addSubview:self.couponTextField];
    
    self.useCouponButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.useCouponButton setTitle:STRING_USE forState:UIControlStateNormal];
    UIImage *useCouponImageNormal = [UIImage imageNamed:@"useCoupon_normal"];
    [self.useCouponButton setBackgroundImage:useCouponImageNormal forState:UIControlStateNormal];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_highlighted"] forState:UIControlStateHighlighted];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_highlighted"] forState:UIControlStateSelected];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_disabled"] forState:UIControlStateDisabled];
    [self.useCouponButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.useCouponButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.useCouponButton addTarget:self action:@selector(useCouponButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.useCouponButton setFrame:CGRectMake(CGRectGetMaxX(self.couponTextField.frame) + 5.0f, CGRectGetMaxY(self.couponTitleSeparator.frame) + 17.0f, useCouponImageNormal.size.width, useCouponImageNormal.size.height)];
    
    [self.couponView addSubview:self.useCouponButton];
    [self.scrollView addSubview:self.couponView];
    
    self.bottomView = [[JAButtonWithBlur alloc] initWithFrame:CGRectZero orientation:self.interfaceOrientation];    
    
    [self.bottomView setFrame:CGRectMake(0.0f,
                                         self.view.frame.size.height - 64.0f - self.bottomView.frame.size.height,
                                         self.view.frame.size.width,
                                         self.bottomView.frame.size.height)];
    
    [self.bottomView addButton:STRING_NEXT target:self action:@selector(nextStepButtonPressed)];
    
    [self.view addSubview:self.bottomView];
}

-(void)finishedLoadingPaymentMethods
{
    if(VALID_NOTEMPTY([[[self checkout] orderSummary] discountCouponCode], NSString))
    {
        [self.couponTextField setText:[[[self checkout] orderSummary] discountCouponCode]];
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
    
    [self reloadCollectionView];
    
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
    if(VALID_NOTEMPTY(self.paymentMethods, NSArray))
    {
        CGFloat collectionViewHeight = 26.0f + ([self.paymentMethods count] * 44.0f);
        
        if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath))
        {
            RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:self.collectionViewIndexSelected.row];
            collectionViewHeight += [self.checkoutFormForPaymentMethod getPaymentMethodViewHeight:paymentMethod];
        }
        
        [UIView animateWithDuration:0.5f
                         animations:^{
                             [self.collectionView setFrame:CGRectMake(self.collectionView.frame.origin.x,
                                                                      self.collectionView.frame.origin.y,
                                                                      self.collectionView.frame.size.width,
                                                                      collectionViewHeight)];
                             
                             [self.couponView setFrame:CGRectMake(6.0f,
                                                                  self.collectionView.frame.origin.y + collectionViewHeight + 6.0f,
                                                                  308.0f,
                                                                  86.0f)];
                             
                         }];
        
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                                   self.collectionView.frame.origin.y + collectionViewHeight + 92.0f + self.bottomView.frame.size.height + 6.0f)];
        
    }
    
    
    
    [self.collectionView reloadData];
}

- (void)useCouponButtonPressed
{
    [self.couponTextField resignFirstResponder];
    
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
    
    [self showLoading];
    NSString *voucherCode = [self.couponTextField text];
    
    if(VALID_NOTEMPTY([[self cart] couponMoneyValue], NSNumber) && 0.0f < [[[self cart] couponMoneyValue] floatValue])
    {
        [RICart removeVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
            self.cart = cart;
            
            [self.useCouponButton setTitle:STRING_USE forState:UIControlStateNormal];
            
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
            [self.useCouponButton setTitle:STRING_REMOVE forState:UIControlStateNormal];
            
            [self hideLoading];
            
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self hideLoading];
            
            [self.couponTextField setTextColor:UIColorFromRGB(0xcc0000)];
        }];
    }
}

-(void)nextStepButtonPressed
{
    [self showLoading];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:[RIPaymentMethodForm getParametersForForm:self.paymentMethodForm]];
    
    [parameters setObject:self.selectedPaymentMethod.value forKey:@"paymentMethodForm[payment_method]"];
    
    [parameters addEntriesFromDictionary:[self.checkoutFormForPaymentMethod getValuesForPaymentMethod:self.selectedPaymentMethod]];
    
    [RICheckout setPaymentMethod:self.paymentMethodForm
                      parameters:parameters
                    successBlock:^(RICheckout *checkout) {
                        
                        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                        [trackingDictionary setValue:self.selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentSuccess]
                                                                  data:[trackingDictionary copy]];
                        
                        
                        [JAUtils goToCheckout:checkout];
                        
                        [self hideLoading];
                    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                        
                        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                        [trackingDictionary setValue:self.selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                        [trackingDictionary setValue:[[self.checkout orderSummary] grandTotal] forKey:kRIEventTotalTransactionKey];
                        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentFail]
                                                                  data:[trackingDictionary copy]];
                        
                        if (RIApiResponseNoInternetConnection == apiResponse)
                        {
                            [self showMessage:STRING_NO_NEWTORK success:NO];
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
        referenceSizeForHeaderInSection = CGSizeMake(self.collectionView.frame.size.width, 26.0f);
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
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.paymentMethods, NSArray))
    {
        numberOfItemsInSection = [self.paymentMethods count];
    }
    return numberOfItemsInSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = nil;
    
    if(collectionView == self.collectionView && VALID_NOTEMPTY(self.paymentMethods, NSArray))
    {
        // Payment method title cell
        
        RIPaymentMethodFormOption *paymentMethod = [self.paymentMethods objectAtIndex:indexPath.row];
        if(VALID_NOTEMPTY(paymentMethod, RIPaymentMethodFormOption))
        {
            NSString *cellIdentifier = @"paymentListCell";
            
            JAPaymentCell *paymentListCell = (JAPaymentCell*) [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            [paymentListCell loadWithPaymentMethod:paymentMethod paymentMethodView:[self.checkoutFormForPaymentMethod getPaymentMethodView:paymentMethod]];
            
            paymentListCell.clickableView.tag = indexPath.row;
            [paymentListCell.clickableView addTarget:self action:@selector(clickViewSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            [paymentListCell deselectPaymentMethod];
            if(VALID_NOTEMPTY(self.collectionViewIndexSelected, NSIndexPath) && indexPath.row == self.collectionViewIndexSelected.row)
            {
                [paymentListCell selectPaymentMethod];
            }
            
            if(indexPath.row == ([self.paymentMethods count] - 1))
            {
                [paymentListCell.separator setHidden:YES];
            }
            
            cell = paymentListCell;
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
            [headerView loadHeaderWithText:STRING_PAYMENT];
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

- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary *info = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame = [value CGRectValue];
    self.keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x,
                                         self.scrollView.frame.origin.y,
                                         self.scrollView.frame.size.width,
                                         self.scrollView.frame.size.height - self.keyboardFrame.size.height)];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width,
                                               self.scrollView.contentSize.height - 64.0f)];
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    NSDictionary *info = notification.userInfo;
    NSValue *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x,
                                         self.scrollView.frame.origin.y,
                                         self.scrollView.frame.size.width,
                                         self.scrollView.frame.size.height + keyboardFrame.size.height)];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width,
                                               self.scrollView.contentSize.height + 64.0f)];
}

@end
