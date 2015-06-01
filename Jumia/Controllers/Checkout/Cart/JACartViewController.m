//
//  JACartViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACartViewController.h"
#import "JAAddressesViewController.h"
#import "JACatalogListCell.h"
#import "JAConstants.h"
#import "JACartListHeaderView.h"
#import "JAPriceView.h"
#import "JAUtils.h"
#import "RIForm.h"
#import "RIField.h"
#import "RICart.h"
#import "RICartItem.h"
#import "RICustomer.h"
#import "RIAddress.h"
#import <FacebookSDK/FacebookSDK.h>

@interface JACartViewController ()

@property (nonatomic, strong) NSString *voucherCode;
@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, assign) BOOL firstLoading;
@property (nonatomic, strong) JAPicker *picker;
@property (nonatomic, assign) BOOL requestDone;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGRect cartScrollViewInitialFrame;
@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JACartViewController

- (void)showErrorView:(BOOL)isNoInternetConnection startingY:(CGFloat)startingY selector:(SEL)selector objects:(NSArray *)objects
{
    [self setEmptyCartViewHidden:YES];
    [self setCartViewHidden:YES];
    self.requestDone = NO;
    
    [super showErrorView:isNoInternetConnection startingY:startingY selector:selector objects:objects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.firstLoading = YES;
    
    self.A4SViewControllerAlias = @"CART";
    
    self.navBarLayout.title = STRING_CART;
    
    self.view.backgroundColor = JABackgroundGrey;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.requestDone = NO;
    
    self.cartScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.cartScrollView setBackgroundColor:JABackgroundGrey];
    [self.view addSubview:self.cartScrollView];
    
    self.productsScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.productsScrollView setBackgroundColor:JABackgroundGrey];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, 90.0f);
    [self.flowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width - 12.0f, 26.0f)];
    
    self.productCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    [self.productCollectionView setBackgroundColor:JABackgroundGrey];
    self.productCollectionView.layer.cornerRadius = 5.0f;
    
    UINib *cartListCellNib = [UINib nibWithNibName:@"JACartListCell" bundle:nil];
    [self.productCollectionView registerNib:cartListCellNib forCellWithReuseIdentifier:@"cartListCell"];
    
    UINib *cartListHeaderNib = [UINib nibWithNibName:@"JACartListHeaderView" bundle:nil];
    [self.productCollectionView registerNib:cartListHeaderNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader"];
    
    [self.productCollectionView setDataSource:self];
    [self.productCollectionView setDelegate:self];
    
    [self hideAllViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.emptyCartView setWidth:self.view.width-12.f];
    [self.continueShoppingButton setWidth:self.view.width-12.f];
    [self.emptyCartLabel setX:self.view.width/2-self.emptyCartLabel.width/2];
    [self.emptyCartImageView setX:self.view.width/2-self.emptyCartImageView.width/2];
    
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(removeKeyboard)
                                            name:kOpenMenuNotification
                                                object:nil];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"ShoppingCart"];
    [self continueLoading];
}

- (void)setEmptyCartViewHidden:(BOOL)hidden
{
    [self.emptyCartView setHidden:hidden];
    [self.continueShoppingButton setHidden:hidden];
}

- (void)setCartViewHidden:(BOOL)hidden
{
    [self.cartScrollView setHidden:hidden];
    [self.productCollectionView setHidden:hidden];
    [self.productsScrollView setHidden:hidden];
}

- (void)hideAllViews
{
    [self setEmptyCartViewHidden:YES];
    [self setCartViewHidden:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    [self.picker removeFromSuperview];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(self.requestDone)
    {
        [self loadCartInfo];
    }
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)continueLoading
{
    self.requestDone = NO;
    
    if(self.apiResponse==RIApiResponseKickoutView || self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    [RICart getCartWithSuccessBlock:^(RICart *cartData) {
        self.requestDone = YES;
        
        self.cart = cartData;
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cartData forKey:kUpdateCartNotificationValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
        NSMutableDictionary *trackingDictionary = nil;
        NSMutableArray *viewCartTrackingProducts = [[NSMutableArray alloc] init];
        [self removeErrorView];
        
        for (int i = 0; i < self.cart.cartItems.count; i++) {
            RICartItem *cartItem = [[self.cart cartItems] objectAtIndex:i];

            trackingDictionary = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *viewCartTrackingProduct = [[NSMutableDictionary alloc] init];

            NSString *discount = @"false";
            NSNumber *price = cartItem.priceEuroConverted;
            if (VALID_NOTEMPTY(cartItem.specialPriceEuroConverted, NSNumber) && [cartItem.specialPriceEuroConverted floatValue] > 0.0f)
            {
                discount = @"true";
                price = cartItem.specialPriceEuroConverted;
            }
            
            // Since we're sending the converted price, we have to send the currency as EUR.
            // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
            [viewCartTrackingProduct setValue:price forKey:kRIEventPriceKey];
            [viewCartTrackingProduct setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
            [viewCartTrackingProduct setValue:cartItem.sku forKey:kRIEventSkuKey];
            [viewCartTrackingProduct setValue:[cartItem.quantity stringValue] forKey:kRIEventQuantityKey];

            [trackingDictionary setValue:price forKey:kRIEventPriceKey];
            [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
            [trackingDictionary setValue:discount forKey:kRIEventDiscountKey];
            [trackingDictionary setValue:cartItem.sku forKey:kRIEventSkuKey];
            [trackingDictionary setValue:[cartItem.quantity stringValue] forKey:kRIEventQuantityKey];
            
            [viewCartTrackingProducts addObject:viewCartTrackingProduct];
            
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
            if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
            {
                [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
            }
            [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:cartItem.variation forKey:kRIEventSizeKey];
            [trackingDictionary setValue:[cartData.cartValue stringValue] forKey:kRIEventTotalCartKey];

            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewCart]
                                                      data:[trackingDictionary copy]];
            
            float value = [cartItem.price floatValue];
            [FBAppEvents logEvent:FBAppEventNameInitiatedCheckout
                        valueToSum:value
                       parameters:@{
                                    FBAppEventParameterNameContentID:cartItem.sku,
                                    FBAppEventParameterNameNumItems:cartItem.quantity,
                                    FBAppEventParameterNameCurrency: @"EUR"}];
        }
        
        trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
        
        if(VALID_NOTEMPTY(viewCartTrackingProducts, NSMutableArray))
        {
            [trackingDictionary setObject:[viewCartTrackingProducts copy] forKey:kRIEventProductsKey];
        }
        
        [trackingDictionary setValue:[NSNumber numberWithInteger:[[cartData cartItems] count]] forKey:kRIEventQuantityKey];
        [trackingDictionary setValue:[cartData cartValue] forKey:kRIEventTotalCartKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewCart]
                                                  data:[trackingDictionary copy]];
        
        [self loadCartInfo];
        [self hideLoading];
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        // notify the InAppNotification SDK that this the active view controller
        [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        [self removeErrorView];
        self.apiResponse = apiResponse;
        self.requestDone = YES;
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
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

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

- (void)loadCartInfo
{
    if(0 == [[self.cart cartCount] integerValue])
    {
        [self setCartViewHidden:YES];
        [self setupEmptyCart];
        [self setEmptyCartViewHidden:NO];
    }
    else
    {
        [self setEmptyCartViewHidden:YES];
        [self setupCart];
        [self setCartViewHidden:NO];
    }
}


-(void)setupEmptyCart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    
    self.screenName = @"CartEmpty";
    
    self.emptyCartView.layer.cornerRadius = 5.0f;
    self.emptyCartLabel.font = [UIFont fontWithName:kFontRegularName size:self.emptyCartLabel.font.pointSize];
    [self.emptyCartLabel setText:STRING_NO_ITEMS_IN_CART];
    [self.emptyCartLabel setTextColor:JALabelGrey];
    [self.emptyCartLabel setNumberOfLines:1];
    [self.emptyCartLabel sizeToFit];

    self.continueShoppingButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.continueShoppingButton.titleLabel.font.pointSize];
    [self.continueShoppingButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
    [self.continueShoppingButton setTitle:STRING_CONTINUE_SHOPPING forState:UIControlStateNormal];
    
    self.continueShoppingButton.layer.cornerRadius = 5.0f;
    
    [self.continueShoppingButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
    [self.emptyCartView setWidth:self.view.width-12.f];
    [self.continueShoppingButton setWidth:self.view.width-12.f];
    [self.emptyCartLabel setX:self.view.width/2-self.emptyCartLabel.width/2];
    [self.emptyCartImageView setX:self.view.width/2-self.emptyCartImageView.width/2];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CartEmpty"];
}

-(void)setupCart
{
    CGFloat horizontalMargin = 6.0f;
    CGFloat verticalMargin = 6.0f;
    CGFloat headerSize = 26.0f;
    CGFloat itemSize = 90.0f;
    
    self.screenName = @"CartWithItems";
    
    CGFloat viewsWidth = self.view.frame.size.width - (2 * horizontalMargin);
    CGFloat originY = 6.0f;
    
    [self.productCollectionView removeFromSuperview];
    [self.productsScrollView removeFromSuperview];
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        viewsWidth = (self.view.frame.size.width - (3 * horizontalMargin)) / 2;
        
        self.flowLayout.itemSize = CGSizeMake(viewsWidth, itemSize);
        [self.flowLayout setHeaderReferenceSize:CGSizeMake(viewsWidth, headerSize)];
        
        [self.productsScrollView setFrame:CGRectMake(horizontalMargin,
                                                     0.0f,
                                                     viewsWidth,
                                                     self.view.frame.size.height)];
        [self.view addSubview:self.productsScrollView];
        
        [self.cartScrollView setFrame:CGRectMake(CGRectGetMaxX(self.productsScrollView.frame) + 6.0f,
                                                 0.0f,
                                                 viewsWidth,
                                                 self.view.frame.size.height)];
        
        [self.productsScrollView addSubview:self.productCollectionView];
        [self.productCollectionView setFrame:CGRectMake(0.0f,
                                                        verticalMargin,
                                                        self.productsScrollView.frame.size.width,
                                                        ([self.cart.cartItems count] * itemSize) + headerSize)];
        [self.productCollectionView reloadData];
        [self.productsScrollView setContentSize:CGSizeMake(self.productsScrollView.frame.size.width,
                                                           self.productCollectionView.frame.size.height + (2 * verticalMargin))];
        
    }
    else
    {
        self.flowLayout.itemSize = CGSizeMake(viewsWidth, itemSize);
        [self.flowLayout setHeaderReferenceSize:CGSizeMake(viewsWidth, headerSize)];
        
        [self.cartScrollView setFrame:CGRectMake(6.0f,
                                                 0.0f,
                                                 viewsWidth,
                                                 self.view.frame.size.height)];
        
        [self.cartScrollView addSubview:self.productCollectionView];
        [self.productCollectionView setFrame:CGRectMake(0.0f,
                                                        6.0f,
                                                        self.cartScrollView.frame.size.width,
                                                        ([self.cart.cartItems count] * itemSize) + headerSize)];
        [self.productCollectionView reloadData];
        
        originY = CGRectGetMaxY(self.productCollectionView.frame) + 3.0f;
    }
    
    [self.cartScrollView setHidden:NO];
    self.cartScrollViewInitialFrame = self.cartScrollView.frame;
    
    // coupon
    if(VALID_NOTEMPTY(self.couponView, UIView))
    {
        [self.couponView removeFromSuperview];
    }
    
    self.couponView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                               originY,
                                                               self.cartScrollView.frame.size.width,
                                                               86.0f)];
    
    [self.couponView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.couponView.layer.cornerRadius = 5.0f;
    
    self.couponTitle = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, 0.0f, self.cartScrollView.frame.size.width - (2 * horizontalMargin), 26.0f)];
    [self.couponTitle setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.couponTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.couponTitle setText:STRING_COUPON];
    [self.couponTitle setBackgroundColor:[UIColor clearColor]];
    [self.couponView addSubview:self.couponTitle];
    
    self.couponTitleSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.couponTitle.frame), self.cartScrollView.frame.size.width, 1.0f)];
    [self.couponTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.couponView addSubview:self.couponTitleSeparator];
    
    self.useCouponButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *useCouponImageNormal = [UIImage imageNamed:@"useCoupon_normal"];
    [self.useCouponButton setBackgroundImage:useCouponImageNormal forState:UIControlStateNormal];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_highlighted"] forState:UIControlStateHighlighted];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_highlighted"] forState:UIControlStateSelected];
    [self.useCouponButton setBackgroundImage:[UIImage imageNamed:@"useCoupon_disabled"] forState:UIControlStateDisabled];
    [self.useCouponButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.useCouponButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.useCouponButton addTarget:self action:@selector(useCouponButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.useCouponButton setFrame:CGRectMake(self.couponView.frame.size.width - useCouponImageNormal.size.width - 6.0f,
                                              CGRectGetMaxY(self.couponTitleSeparator.frame) + 17.0f,
                                              useCouponImageNormal.size.width,
                                              useCouponImageNormal.size.height)];
    [self.couponView addSubview:self.useCouponButton];
    
    // To the left margin of the coupon button we need to remove the left margin of the textfield (6.0f)
    // and the margin between the text field and the button (6.0f)
    CGFloat textFieldWidth = CGRectGetMinX(self.useCouponButton.frame) - 12.0f;
    self.couponTextField = [[UITextField alloc] initWithFrame:CGRectMake(6.0f,
                                                                         CGRectGetMaxY(self.couponTitleSeparator.frame) + 17.0f,
                                                                         textFieldWidth,
                                                                         30.0f)];
    [self.couponTextField setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
    [self.couponTextField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    [self.couponTextField setPlaceholder:STRING_ENTER_COUPON];
    [self.couponTextField setDelegate:self];
    [self.couponTextField setTextAlignment:NSTextAlignmentLeft];
    [self.couponView addSubview:self.couponTextField];
    
    
    [self.cartScrollView addSubview:self.couponView];
    
    if(VALID_NOTEMPTY([[self cart] couponMoneyValue], NSNumber) && 0.0f < [[[self cart] couponMoneyValue] floatValue])
    {
        [self.useCouponButton setTitle:STRING_REMOVE forState:UIControlStateNormal];
        
        NSString* voucherCode = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsVoucherCode];
        
        if (VALID_NOTEMPTY(voucherCode, NSString)) {
            [self.couponTextField setText:voucherCode];
            [self.couponTextField setEnabled:NO];
        }
    }
    else
    {
        [self.useCouponButton setTitle:STRING_USE forState:UIControlStateNormal];
    }
    
    if(VALID_NOTEMPTY(self.voucherCode, NSString))
    {
        [self.couponTextField setText:self.voucherCode];
        [self.couponTextField setEnabled:NO];
    }
    else if(!VALID_NOTEMPTY([self.couponTextField text], NSString))
    {
        [self.useCouponButton setEnabled:NO];
    }
    
    if(VALID_NOTEMPTY(self.subtotalView, UIView))
    {
        [self.subtotalView removeFromSuperview];
    }
    
    // Remove left and right margins, plus extra 12.0f so that we have a margin between the fields.
    // The division by 2 is because we have 2 fields in each line.
    
    // subtotal
    self.subtotalView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.couponView.frame) + 3.0f, self.cartScrollView.frame.size.width, 0.0f)];
    [self.subtotalView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.subtotalView.layer.cornerRadius = 5.0f;
    
    self.subtotalTitle = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, 0.0f, self.cartScrollView.frame.size.width - (2 * horizontalMargin), 26.0f)];
    [self.subtotalTitle setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.subtotalTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.subtotalTitle setText:STRING_SUBTOTAL];
    [self.subtotalTitle setBackgroundColor:[UIColor clearColor]];
    [self.subtotalView addSubview:self.subtotalTitle];
    
    self.subtotalTitleSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.subtotalTitle.frame), self.cartScrollView.frame.size.width, 1.0f)];
    [self.subtotalTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.subtotalView addSubview:self.subtotalTitleSeparator];
    
    self.articlesCount = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.articlesCount setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.articlesCount setTextColor:UIColorFromRGB(0x666666)];
    [self.articlesCount setBackgroundColor:[UIColor clearColor]];
    NSInteger cartCount = [[[self cart] cartCount] integerValue];
    if(1 == cartCount)
    {
        [self.articlesCount setText:STRING_ITEM_CART];
    }
    else
    {
        [self.articlesCount setText:[NSString stringWithFormat:STRING_ITEMS_CART, cartCount]];
    }
    [self.articlesCount sizeToFit];
    [self.articlesCount setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.subtotalTitleSeparator.frame) + 10.0f, 50.f, self.articlesCount.frame.size.height)];
    [self.subtotalView addSubview:self.articlesCount];
    
    CGRect articleNumberWidth = [self.articlesCount.text boundingRectWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:@{NSFontAttributeName:self.articlesCount.font} context:nil];
    self.totalPriceView = [[JAPriceView alloc] init];
    
    if(VALID_NOTEMPTY([[self cart] cartUnreducedValueFormatted], NSString))
    {
        [self.totalPriceView loadWithPrice:[[self cart] cartUnreducedValueFormatted]
                              specialPrice:[[self cart] subTotalFormatted]
                                  fontSize:11.0f
                     specialPriceOnTheLeft:RI_IS_RTL?NO:YES];
    }
    else
    {
        [self.totalPriceView loadWithPrice:[[self cart] subTotalFormatted]
                              specialPrice:nil
                                  fontSize:11.0f
                     specialPriceOnTheLeft:RI_IS_RTL?NO:YES];
    }
    
    self.totalPriceView.frame = CGRectMake(self.subtotalView.frame.size.width - self.totalPriceView.frame.size.width - 4.0f,
                                           CGRectGetMaxY(self.subtotalTitleSeparator.frame) + 10.0f,
                                           self.totalPriceView.frame.size.width,
                                           self.totalPriceView.frame.size.height);
    [self.subtotalView addSubview:self.totalPriceView];
    
    NSString *priceRuleKeysString = @"";
    NSString *priceRuleValuesString = @"";
    if(VALID_NOTEMPTY([[self cart] priceRules], NSDictionary))
    {
        NSArray *priceRuleKeys = [[[self cart] priceRules] allKeys];
        
        for (NSString *priceRuleKey in priceRuleKeys)
        {
            if(ISEMPTY(priceRuleKeysString))
            {
                priceRuleKeysString = priceRuleKey;
                priceRuleValuesString = [[[self cart] priceRules] objectForKey:priceRuleKey];
            }
            else
            {
                priceRuleKeysString = [NSString stringWithFormat:@"%@\n%@", priceRuleKeysString, priceRuleKey];
                priceRuleValuesString = [NSString stringWithFormat:@"%@\n%@", priceRuleValuesString, [[[self cart] priceRules] objectForKey:priceRuleKey]];
            }
        }
    }
    
    self.cartVatLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.cartVatLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.cartVatLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.cartVatLabel setText:[NSString stringWithFormat:STRING_TAX_INC, STRING_VAT]];
    [self.cartVatLabel sizeToFit];
    [self.cartVatLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.cartVatLabel setFrame:CGRectMake(articleNumberWidth.size.width + 10.0f,
                                           self.articlesCount.frame.origin.y,
                                           self.cartVatLabel.frame.size.width,
                                           self.cartVatLabel.frame.size.height)];
    
    CGFloat extraCostYPos = CGRectGetMaxY(self.articlesCount.frame);
    
    
    if(VALID_NOTEMPTY(priceRuleKeysString, NSString) && VALID_NOTEMPTY(priceRuleValuesString, NSString))
    {
        self.priceRulesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.priceRulesLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
        [self.priceRulesLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.priceRulesLabel setText:priceRuleKeysString];
        [self.priceRulesLabel setNumberOfLines:0];
        [self.priceRulesLabel setBackgroundColor:[UIColor clearColor]];
        [self.priceRulesLabel sizeToFit];
        [self.priceRulesLabel setFrame:CGRectMake(6.0f,
                                                  CGRectGetMaxY(self.articlesCount.frame) + 4.0f,
                                                  self.priceRulesLabel.frame.size.width,
                                                  self.priceRulesLabel.frame.size.height)];
        
        [self.subtotalView addSubview:self.priceRulesLabel];
        
        
        self.priceRulesValue = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.priceRulesValue setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
        [self.priceRulesValue setTextColor:UIColorFromRGB(0x666666)];
        [self.priceRulesValue setText:priceRuleValuesString];
        [self.priceRulesValue setNumberOfLines:0];
        [self.priceRulesValue setBackgroundColor:[UIColor clearColor]];
        [self.priceRulesValue sizeToFit];
        [self.priceRulesValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.priceRulesValue.frame.size.width - 4.0f,
                                                  CGRectGetMaxY(self.articlesCount.frame) + 4.0f,
                                                  self.priceRulesValue.frame.size.width,
                                                  self.priceRulesValue.frame.size.height)];
        
        [self.subtotalView addSubview:self.priceRulesValue];
        
        extraCostYPos = CGRectGetMaxY(self.articlesCount.frame) + self.priceRulesLabel.frame.size.height + 4.0f;
       
    }
    else
    {
        if(VALID_NOTEMPTY(self.priceRulesLabel, UILabel))
        {
            [self.priceRulesLabel removeFromSuperview];
        }
        if(VALID_NOTEMPTY(self.priceRulesValue, UILabel))
        {
            [self.priceRulesValue removeFromSuperview];
        }
        
        extraCostYPos = CGRectGetMaxY(self.articlesCount.frame);

    }
    [self.subtotalView addSubview:self.cartVatLabel];

    
    self.extraCostsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.extraCostsLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.extraCostsLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.extraCostsLabel setText:STRING_EXTRA_COSTS];
    [self.extraCostsLabel sizeToFit];
    [self.extraCostsLabel setBackgroundColor:[UIColor clearColor]];
    [self.extraCostsLabel setFrame:CGRectMake(6.0f,
                                              extraCostYPos,
                                              self.extraCostsLabel.frame.size.width,
                                              self.extraCostsLabel.frame.size.height)];
    [self.subtotalView addSubview:self.extraCostsLabel];
    
    self.extraCostsValue = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.extraCostsValue setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.extraCostsValue setTextColor:UIColorFromRGB(0x666666)];
    [self.extraCostsValue setText:[[self cart] extraCostsFormatted]];
    [self.extraCostsValue sizeToFit];
    [self.extraCostsValue setBackgroundColor:[UIColor clearColor]];
    [self.extraCostsValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.extraCostsValue.frame.size.width - 4.0f,
                                              extraCostYPos,
                                              self.extraCostsValue.frame.size.width,
                                              self.extraCostsValue.frame.size.height)];
    [self.subtotalView addSubview:self.extraCostsValue];
    
    self.totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.totalLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.totalLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.totalLabel setText:STRING_TOTAL];
    [self.totalLabel sizeToFit];
    [self.totalLabel setBackgroundColor:[UIColor clearColor]];
    
    self.totalValue = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.totalValue setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.totalValue setTextColor:UIColorFromRGB(0xcc0000)];
    [self.totalValue setText:[[self cart] cartValueFormatted]];
    [self.totalValue sizeToFit];
    [self.totalValue setBackgroundColor:[UIColor clearColor]];
    
    if(VALID_NOTEMPTY([[self cart] couponMoneyValue], NSNumber) && 0.0f < [[[self cart] couponMoneyValue] floatValue])
    {
        self.couponLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.couponLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
        [self.couponLabel setTextColor:UIColorFromRGB(0x3aaa35)];
        [self.couponLabel setText:STRING_VOUCHER];
        [self.couponLabel sizeToFit];
        [self.couponLabel setBackgroundColor:[UIColor clearColor]];
        [self.couponLabel setFrame:CGRectMake(6.0f,
                                              CGRectGetMaxY(self.extraCostsLabel.frame),
                                              self.couponLabel.frame.size.width,
                                              self.couponLabel.frame.size.height)];
        [self.subtotalView addSubview:self.couponLabel];
        
        self.couponValue = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.couponValue setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
        [self.couponValue setTextColor:UIColorFromRGB(0x3aaa35)];
        [self.couponValue setText:[NSString stringWithFormat:@"- %@", [[self cart] couponMoneyValueFormatted]]];
        [self.couponValue sizeToFit];
        [self.couponValue setBackgroundColor:[UIColor clearColor]];
        [self.couponValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.couponValue.frame.size.width - 4.0f,
                                              CGRectGetMaxY(self.extraCostsLabel.frame),
                                              self.couponValue.frame.size.width,
                                              self.couponValue.frame.size.height)];
        [self.subtotalView addSubview:self.couponValue];
        
        [self.totalLabel setFrame:CGRectMake(6.0f,
                                             CGRectGetMaxY(self.couponLabel.frame) + 4.0f,
                                             self.totalLabel.frame.size.width,
                                             self.totalLabel.frame.size.height)];
        
        [self.totalValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.totalValue.frame.size.width - 4.0f,
                                             CGRectGetMaxY(self.couponLabel.frame) + 4.0f,
                                             self.totalValue.frame.size.width,
                                             self.totalValue.frame.size.height)];
    }
    else
    {
        if(VALID_NOTEMPTY(self.couponLabel, UILabel))
        {
            [self.couponLabel removeFromSuperview];
        }
        if(VALID_NOTEMPTY(self.couponValue, UILabel))
        {
            [self.couponValue removeFromSuperview];
        }
        
        [self.totalLabel setFrame:CGRectMake(6.0f,
                                             CGRectGetMaxY(self.extraCostsLabel.frame) + 4.0f,
                                             self.totalLabel.frame.size.width,
                                             self.totalLabel.frame.size.height)];
        
        [self.totalValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.totalValue.frame.size.width - 4.0f,
                                             CGRectGetMaxY(self.extraCostsLabel.frame) + 4.0f,
                                             self.totalValue.frame.size.width,
                                             self.totalValue.frame.size.height)];
    }
    
    [self.subtotalView addSubview:self.totalLabel];
    [self.subtotalView addSubview:self.totalValue];
    
    [self.subtotalView setFrame:CGRectMake(0.0f,
                                           CGRectGetMaxY(self.couponView.frame) + 3.0f,
                                           self.cartScrollView.frame.size.width,
                                           CGRectGetMaxY(self.totalValue.frame) + 10.0f)];
    [self.cartScrollView addSubview:self.subtotalView];
    
    if(VALID_NOTEMPTY(self.checkoutButton, UIButton))
    {
        [self.checkoutButton removeFromSuperview];
    }
    
    NSString *greyButtonName = @"greyBig_%@";
    NSString *orangeButtonName = @"orangeBig_%@";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
            orangeButtonName = @"orangeHalfLandscape_%@";
            greyButtonName = @"greyHalfLandscape_%@";
        }
        else
        {
            orangeButtonName = @"orangeFullPortrait_%@";
            greyButtonName = @"greyFullPortrait_%@";
        }
    }
    
    self.checkoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *checkoutButtonImageNormal = [UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"normal"]];
    [self.checkoutButton setBackgroundImage:checkoutButtonImageNormal forState:UIControlStateNormal];
    [self.checkoutButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]] forState:UIControlStateHighlighted];
    [self.checkoutButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]] forState:UIControlStateSelected];
    [self.checkoutButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"disabled"]] forState:UIControlStateDisabled];
    [self.checkoutButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
    [self.checkoutButton setTitle:STRING_PROCEED_TO_CHECKOUT forState:UIControlStateNormal];
    [self.checkoutButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.checkoutButton addTarget:self action:@selector(checkoutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.checkoutButton setFrame:CGRectMake(0.0f,
                                             CGRectGetMaxY(self.subtotalView.frame) + 6.0f,
                                             checkoutButtonImageNormal.size.width,
                                             checkoutButtonImageNormal.size.height)];
    [self.cartScrollView addSubview:self.checkoutButton];
    
    [self.cartScrollView setContentSize:CGSizeMake(self.cartScrollView.frame.size.width,
                                                   self.cartScrollView.frame.origin.y + CGRectGetMaxY(self.checkoutButton.frame) + 6.0f)];
    
    UIDevice *device = [UIDevice currentDevice];
    if ([@"iPhone" isEqualToString:[device model]])
    {
        if(VALID_NOTEMPTY(self.callToOrderButton, UIButton))
        {
            [self.callToOrderButton removeFromSuperview];
        }
        self.callToOrderButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *callToOrderButtonImageNormal = [UIImage imageNamed:[NSString stringWithFormat:greyButtonName, @"normal"]];
        [self.callToOrderButton setBackgroundImage:callToOrderButtonImageNormal forState:UIControlStateNormal];
        [self.callToOrderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:greyButtonName, @"highlighted"]] forState:UIControlStateHighlighted];
        [self.callToOrderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:greyButtonName, @"highlighted"]] forState:UIControlStateSelected];
        [self.callToOrderButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:greyButtonName, @"disabled"]] forState:UIControlStateDisabled];
        [self.callToOrderButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
        [self.callToOrderButton setTitle:STRING_CALL_TO_ORDER forState:UIControlStateNormal];
        [self.callToOrderButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
        [self.callToOrderButton addTarget:self action:@selector(callToOrderButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.callToOrderButton setFrame:CGRectMake(0.0f,
                                                    CGRectGetMaxY(self.checkoutButton.frame) + 6.0f,
                                                    callToOrderButtonImageNormal.size.width,
                                                    callToOrderButtonImageNormal.size.height)];
        [self.cartScrollView addSubview:self.callToOrderButton];
        
        [self.cartScrollView setContentSize:CGSizeMake(self.cartScrollView.frame.size.width,
                                                       self.cartScrollView.frame.origin.y + CGRectGetMaxY(self.callToOrderButton.frame) + 6.0f)];
    }
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CartWithItem"];
    
    if([self.cart.extraCosts integerValue] == 0){
        [self.extraCostsLabel setHidden:YES];
        [self.extraCostsValue setHidden:YES];
    }
    
    if (RI_IS_RTL) {
        [self.productsScrollView flipViewPositionInsideSuperview];
        [self.cartScrollView flipViewPositionInsideSuperview];
        
        [self.couponView flipSubviewAlignments];
        [self.couponView flipSubviewPositions];
        [self.subtotalView flipSubviewAlignments];
        [self.subtotalView flipSubviewPositions];
    }
}

-(void)goToHomeScreen
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"ContinueShopping" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutContinueShopping]
                                              data:[trackingDictionary copy]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

- (void)removeFromCartPressed:(UIButton*)button
{
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSArray))
    {
        RICartItem *product = [self.cart.cartItems objectAtIndex:button.tag];
        NSNumber *cartValue = self.cart.cartValue;
        [self showLoading];
        [RICart removeProductWithQuantity:[product.quantity stringValue]
                                      sku:product.simpleSku
                         withSuccessBlock:^(RICart *cart) {
                             self.cart = cart;
                             
                             NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                             [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                             [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                             [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                             NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                             [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                             
                             // Since we're sending the converted price, we have to send the currency as EUR.
                             // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
                             NSNumber *price = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f) ? product.specialPriceEuroConverted : product.priceEuroConverted;
                             [trackingDictionary setValue:price forKey:kRIEventPriceKey];
                             [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
                             
                             [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
                             [trackingDictionary setValue:[product.quantity stringValue] forKey:kRIEventQuantityKey];
                             [trackingDictionary setValue:cartValue forKey:kRIEventTotalCartKey];
                             
                             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromCart]
                                                                       data:[trackingDictionary copy]];
                             
                             NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                             [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                             
                             [self loadCartInfo];
                             
                             [self hideLoading];
                         } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                             [self hideLoading];
                         }];
    }
}

- (void)quantityPressed:(UIButton*)button
{
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSArray))
    {
        self.currentItem = [self.cart.cartItems objectAtIndex:button.tag];
        
        [self setupPickerView];
    }
}

- (void)setupPickerView
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    
    NSMutableArray *dataSource = [NSMutableArray new];
    
    if(VALID_NOTEMPTY([self.currentItem maxQuantity], NSNumber) && 0 < [[self.currentItem maxQuantity] integerValue])
    {
        NSInteger maxQuantity = [[self.currentItem maxQuantity] integerValue];
        if(VALID_NOTEMPTY([self.currentItem stock], NSNumber) && [[self.currentItem stock] integerValue] < [[self.currentItem maxQuantity] integerValue])
        {
            maxQuantity = [[self.currentItem stock] integerValue];
        }
        
        for (int i = 0; i < maxQuantity; i++)
        {
            [dataSource addObject:[NSString stringWithFormat:@"%d", (i + 1)]];
        }
    }
    
    NSString *selectedItem = [NSString stringWithFormat:@"%ld", [[self.currentItem quantity] longValue]];
    
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:selectedItem
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
            self.voucherCode = voucherCode;
            
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kUserDefaultsVoucherCode];
            
            [self setupCart];
            [self.couponTextField setEnabled:YES];
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
            self.voucherCode = voucherCode;

            [[NSUserDefaults standardUserDefaults] setObject:voucherCode forKey:kUserDefaultsVoucherCode];
            
            [self setupCart];
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self hideLoading];
            
            [self.couponTextField setTextColor:UIColorFromRGB(0xcc0000)];
        }];
    }
}

- (void)checkoutButtonPressed
{
    if([RICustomer checkIfUserIsLogged])
    {
        [self showLoading];
        [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"Started" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
            
            [trackingDictionary setValue:[NSNumber numberWithInteger:[[self.cart cartItems] count]] forKey:kRIEventQuantityKey];
            [trackingDictionary setValue:[self.cart cartValue] forKey:kRIEventTotalCartKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutStart]
                                                      data:[trackingDictionary copy]];
            
            [self hideLoading];
            
            if(VALID_NOTEMPTY(adressList, NSDictionary))
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                                    object:nil
                                                                  userInfo:nil];
                [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutAddress"];
            }
            else
            {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button", @"from_checkout"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
                [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutAddress"];
            }
            
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"NativeCheckoutError" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutError]
                                                      data:[trackingDictionary copy]];
            
            [self hideLoading];
            
            [self showMessage:[errorMessages componentsJoinedByString:@","] success:NO];
        }];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutLoginScreenNotification
                                                            object:nil
                                                          userInfo:nil];
    }
}

- (void)callToOrderButtonPressed
{
    [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCallToOrder]
                                                  data:[trackingDictionary copy]];
        
        NSString *phoneNumber = [@"tel://" stringByAppendingString:configuration.phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
    }];
}

#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItemsInSection = 0;
    if(VALID_NOTEMPTY(self.cart, RICart))
    {
        numberOfItemsInSection = self.cart.cartItems.count;
    }
    
    return numberOfItemsInSection;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JACatalogListCell *cell = nil;
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSArray) && indexPath.row < [self.cart.cartCount integerValue])
    {
        RICartItem *product = [self.cart.cartItems objectAtIndex:indexPath.row];
        
        NSString *cellIdentifier = @"cartListCell";
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell setWidth:self.productCollectionView.width];
        
        [cell loadWithCartItem:product];
        
        cell.quantityButton.tag = indexPath.row;
        [cell.quantityButton addTarget:self
                                action:@selector(quantityPressed:)
                      forControlEvents:UIControlEventTouchUpInside];
        
        cell.deleteButton.tag = indexPath.row;
        [cell.deleteButton addTarget:self
                              action:@selector(removeFromCartPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
        [cell.deleteButton addTarget:self
                              action:@selector(removeKeyboard)
                    forControlEvents:UIControlEventTouchUpInside];
        cell.feedbackView.tag = indexPath.row;
        [cell.feedbackView addTarget:self
                              action:@selector(clickableViewPressedInCell:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        [cell.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
        
        if(indexPath.row < ([self.cart.cartCount integerValue] - 1))
        {
            [cell.separator setHidden:NO];
        }
    }
    
    return cell;
}

-(void)removeKeyboard
{
    [self.couponTextField resignFirstResponder];
}

- (void)clickableViewPressedInCell:(UIControl*)sender
{
    [self collectionView:self.productCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
    
    if (kind == UICollectionElementKindSectionHeader) {
        JACartListHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"cartListHeader" forIndexPath:indexPath];
        
        [headerView loadHeaderWithText:STRING_ITEMS width:self.productCollectionView.frame.size.width];
        
        [headerView flipSubviewAlignments];
        [headerView flipSubviewPositions];
        
        reusableview = headerView;
        
    }
    
    return reusableview;
}

#pragma mark UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(VALID_NOTEMPTY(self.cart, RICart) && VALID_NOTEMPTY(self.cart.cartItems, NSArray) && indexPath.row < [self.cart.cartCount integerValue])
    {
        RICartItem *product = [self.cart.cartItems objectAtIndex:indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"url" : product.productUrl,
                                                                      @"previousCategory" : STRING_CART,
                                                                      @"show_back_button" : [NSNumber numberWithBool:NO]}];
        
        [[RITrackingWrapper sharedInstance] trackScreenWithName:[NSString stringWithFormat:@"cart_%@",product.name]];

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
    else if(VALID_NOTEMPTY(textField.text, NSString))
    {
        [self.useCouponButton setEnabled:YES];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.couponTextField setTextColor:UIColorFromRGB(0x666666)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.couponTextField resignFirstResponder];
    
    if(VALID_NOTEMPTY([self.couponTextField text], NSString))
    {
        [self useCouponButtonPressed];
        [self.useCouponButton setEnabled:YES];
    }
    else
    {
        [self.useCouponButton setEnabled:NO];
    }
    
    return YES;
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    NSInteger newQuantity = selectedRow + 1;
    if(newQuantity != [[self.currentItem quantity] integerValue])
    {
        [self showLoading];
        
        NSNumber *event = [NSNumber numberWithInt:RIEventDecreaseQuantity];
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        
        // Since we're sending the converted price, we have to send the currency as EUR.
        // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
        NSNumber *price = (VALID_NOTEMPTY(self.currentItem.specialPriceEuroConverted, NSNumber) && [self.currentItem.specialPriceEuroConverted floatValue] > 0.0f) ? self.currentItem.specialPriceEuroConverted : self.currentItem.priceEuroConverted;
        [trackingDictionary setValue:price forKey:kRIEventPriceKey];
        [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
        
        [trackingDictionary setValue:self.currentItem.sku forKey:kRIEventSkuKey];
        NSString *discountPercentage = @"0";
        if(VALID_NOTEMPTY(self.currentItem.savingPercentage, NSNumber))
        {
            discountPercentage = [self.currentItem.savingPercentage stringValue];
        }
        [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
        [trackingDictionary setValue:@"Cart" forKey:kRIEventLocationKey];
        [trackingDictionary setValue:self.cart.cartValue  forKey:kRIEventTotalCartKey];
        
        NSInteger quantity = 0;
        if(newQuantity > [[self.currentItem quantity] integerValue])
        {
            quantity = newQuantity - [[self.currentItem quantity] integerValue];
            event = [NSNumber numberWithInt:RIEventIncreaseQuantity];
        }
        else
        {
            quantity = [[self.currentItem quantity] integerValue] - newQuantity;
        }
        [trackingDictionary setValue:[NSString stringWithFormat:@"%ld", (long)quantity] forKey:kRIEventQuantityKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:event
                                                  data:[trackingDictionary copy]];
        
        
        NSMutableDictionary *quantitiesToChange = [[NSMutableDictionary alloc] init];
        for (int i = 0; i < self.cart.cartItems.count; i++) {
            RICartItem *cartItem = [[self.cart cartItems] objectAtIndex:i];
            [quantitiesToChange setValue:[NSString stringWithFormat:@"%ld", [[cartItem quantity] longValue]] forKey:[NSString stringWithFormat:@"qty_%@", cartItem.simpleSku]];
        }
        
        [quantitiesToChange setValue:[NSString stringWithFormat:@"%ld", (long)newQuantity] forKey:[NSString stringWithFormat:@"qty_%@", [self.currentItem simpleSku]]];
        
        [RICart changeQuantityInProducts:quantitiesToChange
                        withSuccessBlock:^(RICart *cart) {
                            self.cart = cart;
                            
                            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                            
                            [self closePicker];
                            [self setupCart];
                            [self hideLoading];
                        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                            [self closePicker];
                            [self hideLoading];
                            
                            [self showMessage:STRING_ERROR_CHANGING_QUANTITY success:NO];
                        }];
    }
    else
    {
        [self closePicker];
    }
    
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}

- (void)closePicker
{
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberOfRowsInComponent = 0;
    
    if(VALID_NOTEMPTY(self.currentItem, RICartItem))
    {
        numberOfRowsInComponent = [[self.currentItem maxQuantity] integerValue];
    }
    
    return numberOfRowsInComponent;
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"%ld", (long)(row + 1)];
    return title;
}

#pragma mark Observers

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat height = kbSize.height;
    if(self.view.frame.size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.cartScrollView setFrame:CGRectMake(self.cartScrollViewInitialFrame.origin.x,
                                                 self.cartScrollViewInitialFrame.origin.y,
                                                 self.cartScrollViewInitialFrame.size.width,
                                                 self.cartScrollViewInitialFrame.size.height - height)];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.cartScrollView setFrame:self.cartScrollViewInitialFrame];
    }];
}

@end
