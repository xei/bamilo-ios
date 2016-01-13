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
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "JAAuthenticationViewController.h"

#define kLateralMargin 16
#define kTopMargin 48
#define kImageTopMargin 28
#define kImageBottomMargin 28
#define kButtonTopMargin 48
#define kButtonWidth 288

@interface JACartViewController () {
    BOOL _emptyImageFlipOnce;
    BOOL _firstLoading;
    UILabel *_shippingFeeLabel;
    UILabel *_shippingFeeValueLabel;
}

@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, strong) JAPicker *picker;
@property (nonatomic, assign) BOOL requestDone;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, assign) CGRect cartScrollViewInitialFrame;
@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JACartViewController

- (UIView *)emptyCartView
{
    if (!VALID_NOTEMPTY(_emptyCartView, UIView)) {
        _emptyCartView = [[UIView alloc] initWithFrame:self.viewBounds];
        [_emptyCartView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:_emptyCartView];
    }
    return _emptyCartView;
}

- (UILabel *)emptyCartLabel
{
    if (!VALID_NOTEMPTY(_emptyCartLabel, UILabel)) {
        _emptyCartLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, self.view.width - 2*kLateralMargin, 17)];
        [_emptyCartLabel setFont:JADisplay2Font];
        [_emptyCartLabel setTextColor:JABlackColor];
        [_emptyCartLabel setTextAlignment:NSTextAlignmentCenter];
        [_emptyCartLabel setNumberOfLines:2];
        [_emptyCartLabel setText:STRING_NO_ITEMS_IN_CART];
        [self.emptyCartView addSubview:_emptyCartLabel];
    }
    return _emptyCartLabel;
}

- (UIImageView *)emptyCartImageView
{
    if (!VALID_NOTEMPTY(_emptyCartImageView, UIImageView)) {
        UIImage *image = [UIImage imageNamed:@"img_emptyCart"];
        _emptyCartImageView = [[UIImageView alloc] initWithImage:image];
        [_emptyCartImageView setFrame:CGRectMake((self.view.width - image.size.width)/2, CGRectGetMaxY(self.emptyCartLabel.frame) + kImageTopMargin, image.size.width, image.size.height)];
        [self.emptyCartView addSubview:_emptyCartImageView];
    }
    return _emptyCartImageView;
}

- (JABottomBar *)continueShoppingButton
{
    if (!VALID_NOTEMPTY(_continueShoppingButton, JABottomBar)) {
        _continueShoppingButton = [[JABottomBar alloc] initWithFrame:CGRectMake((self.view.width - kButtonWidth)/2, CGRectGetMaxY(self.emptyCartImageView.frame) + kImageBottomMargin, kButtonWidth, kBottomDefaultHeight)];
        [_continueShoppingButton addButton:[STRING_CONTINUE_SHOPPING uppercaseString] target:self action:@selector(goToHomeScreen)];
        [self.emptyCartView addSubview:_continueShoppingButton];
    }
    return _continueShoppingButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.apiResponse = RIApiResponseSuccess;
    
    _firstLoading = YES;
    
    self.A4SViewControllerAlias = @"CART";
    
    self.navBarLayout.title = STRING_CART;
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    self.searchBarIsVisible = YES;
    
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
    self.flowLayout.itemSize = CGSizeMake([self viewBounds].size.width, 90.0f);
    [self.flowLayout setHeaderReferenceSize:CGSizeMake([self viewBounds].size.width - 12.0f, 26.0f)];
    
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
    
    [self.emptyCartView setFrame:self.viewBounds];
    [self.continueShoppingButton setX:(self.view.width - self.continueShoppingButton.width)/2];
    [self.emptyCartLabel setWidth:self.view.width - 2*kLateralMargin];
    [self.emptyCartImageView setX:self.view.width/2-self.emptyCartImageView.width/2];
    
    if (!_emptyImageFlipOnce && RI_IS_RTL)
        [self.emptyCartImageView flipViewImage];
    _emptyImageFlipOnce = YES;
    
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

- (void)viewDidLayoutSubviews
{
    [self.emptyCartView setFrame:self.viewBounds];
    [self.continueShoppingButton setX:(self.view.width - self.continueShoppingButton.width)/2];
    [self.emptyCartLabel setWidth:self.view.width - 2*kLateralMargin];
    [self.emptyCartImageView setX:self.view.width/2-self.emptyCartImageView.width/2];
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
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];

        //reset teaserTrackingInfo for items that have been removed somehow (i.e. logout)
        NSDictionary* teaserTrackingInfoDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey];
        NSMutableDictionary* newteaserTrackingInfoDictionary = [NSMutableDictionary new];
        [teaserTrackingInfoDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            BOOL exists = NO;
            for (RICartItem *cartItem in self.cart.cartItems) {
                if ([key isEqualToString:cartItem.sku]) {
                    exists = YES;
                    break;
                }
            }
            if (exists) {
                [newteaserTrackingInfoDictionary setObject:obj forKey:key];
            }
        }];
        [[NSUserDefaults standardUserDefaults] setObject:newteaserTrackingInfoDictionary forKey:kSkusFromTeaserInCartKey];
        
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
            [trackingDictionary setValue:cartData.cartValueEuroConverted forKey:kRIEventTotalCartKey];

            
            if ([RICustomer checkIfUserIsLogged]) {
                [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
                [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
                    RIAddress *shippingAddress = (RIAddress *)[adressList objectForKey:@"shipping"];
                    [trackingDictionary setValue:shippingAddress.city forKey:kRIEventCityKey];
                    [trackingDictionary setValue:shippingAddress.customerAddressRegion forKey:kRIEventRegionKey];
                    
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewCart]
                                                              data:[trackingDictionary copy]];
                    
                } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                    NSLog(@"ERROR: getting customer");
                    
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewCart]
                                                              data:[trackingDictionary copy]];
                }];
            }else{
                
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewCart]
                                                          data:[trackingDictionary copy]];
            }
            
            float value = [cartItem.price floatValue];
            [FBSDKAppEvents logEvent:FBSDKAppEventNameInitiatedCheckout
                        valueToSum:value
                       parameters:@{
                                    FBSDKAppEventParameterNameContentID:cartItem.sku,
                                    FBSDKAppEventParameterNameNumItems:cartItem.quantity,
                                    FBSDKAppEventParameterNameCurrency: @"EUR"}];
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
        [trackingDictionary setValue:cartData.cartValueEuroConverted forKey:kRIEventTotalCartKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewCart]
                                                  data:[trackingDictionary copy]];
        
        [self loadCartInfo];
        [self hideLoading];
        
        if(_firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            _firstLoading = NO;
        }
        
        // notify the InAppNotification SDK that this the active view controller
        [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        self.apiResponse = apiResponse;
        
        if(_firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            _firstLoading = NO;
        }
        
        [self setEmptyCartViewHidden:YES];
        [self setCartViewHidden:YES];
        self.requestDone = NO;
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(continueLoading) objects:nil];
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
    
    [self.emptyCartView setFrame:self.viewBounds];
    [self.continueShoppingButton setX:(self.view.width - self.continueShoppingButton.width)/2];
    
    [self.emptyCartLabel setWidth:self.view.width - 2*kLateralMargin];
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
    
    CGFloat viewsWidth = [self viewBounds].size.width - (2 * horizontalMargin);
    CGFloat originY = 6.0f;
    
    [self.productCollectionView removeFromSuperview];
    [self.productsScrollView removeFromSuperview];
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        viewsWidth = ([self viewBounds].size.width - (3 * horizontalMargin)) / 2;
        
        self.flowLayout.itemSize = CGSizeMake(viewsWidth, itemSize);
        [self.flowLayout setHeaderReferenceSize:CGSizeMake(viewsWidth, headerSize)];
        
        [self.productsScrollView setFrame:CGRectMake(horizontalMargin,
                                                     [self viewBounds].origin.y,
                                                     viewsWidth,
                                                     [self viewBounds].size.height)];
        [self.view addSubview:self.productsScrollView];
        
        [self.cartScrollView setFrame:CGRectMake(CGRectGetMaxX(self.productsScrollView.frame) + 6.0f,
                                                 [self viewBounds].origin.y,
                                                 viewsWidth,
                                                 [self viewBounds].size.height)];
        
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
                                                 [self viewBounds].origin.y,
                                                 viewsWidth,
                                                 [self viewBounds].size.height)];
        
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
    
    if(VALID([[self cart] couponMoneyValue], NSNumber))
    {
        [self.useCouponButton setTitle:STRING_REMOVE forState:UIControlStateNormal];
        
        if (VALID_NOTEMPTY(self.cart.couponCode, NSString)) {
            [self.couponTextField setText:self.cart.couponCode];
            [self.couponTextField setEnabled:NO];
        }
    }
    else
    {
        [self.useCouponButton setTitle:STRING_USE forState:UIControlStateNormal];
    }
    
    if(VALID_NOTEMPTY(self.cart.couponCode, NSString))
    {
        [self.couponTextField setText:self.cart.couponCode];
        [self.couponTextField setEnabled:NO];
    }
    else if(!VALID_NOTEMPTY([self.couponTextField text], NSString))
    {
        [self.useCouponButton setEnabled:NO];
    }
    
    // Remove left and right margins, plus extra 12.0f so that we have a margin between the fields.
    // The division by 2 is because we have 2 fields in each line.
    
    // subtotal
    if (!self.subtotalView) {
        self.subtotalView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.couponView.frame) + 3.0f, self.cartScrollView.frame.size.width, 0.0f)];
        [self.subtotalView setBackgroundColor:UIColorFromRGB(0xffffff)];
        self.subtotalView.layer.cornerRadius = 5.0f;
        [self.cartScrollView addSubview:self.subtotalView];
    }
    [self.subtotalView setFrame:CGRectMake(0.0f,
                                           CGRectGetMaxY(self.couponView.frame) + 3.0f,
                                           self.cartScrollView.frame.size.width,
                                           100)];
    
    if (!self.subtotalTitle) {
        self.subtotalTitle = [[UILabel alloc] initWithFrame:CGRectMake(horizontalMargin, 0.0f, self.cartScrollView.frame.size.width - (2 * horizontalMargin), 26.0f)];
        [self.subtotalTitle setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
        [self.subtotalTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
        [self.subtotalTitle setText:STRING_SUBTOTAL];
        [self.subtotalTitle setBackgroundColor:[UIColor clearColor]];
        [self.subtotalView addSubview:self.subtotalTitle];
    }
    [self.subtotalTitle setTextAlignment:NSTextAlignmentLeft];
    [self.subtotalTitle setFrame:CGRectMake(horizontalMargin, 0.0f, self.cartScrollView.frame.size.width - (2 * horizontalMargin), 26.0f)];
    
    if (!self.subtotalTitleSeparator) {
        self.subtotalTitleSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.subtotalTitle.frame), self.cartScrollView.frame.size.width, 1.0f)];
        [self.subtotalTitleSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
        [self.subtotalView addSubview:self.subtotalTitleSeparator];
    }
    [self.subtotalTitleSeparator setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.subtotalTitle.frame), self.cartScrollView.frame.size.width, 1.0f)];
    
    if (!self.articlesCount) {
        self.articlesCount = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.articlesCount setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
        [self.articlesCount setTextColor:UIColorFromRGB(0x666666)];
        [self.articlesCount setBackgroundColor:[UIColor clearColor]];
        [self.subtotalView addSubview:self.articlesCount];
    }
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
    [self.articlesCount setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.subtotalTitleSeparator.frame) + 10.0f, self.articlesCount.width, self.articlesCount.frame.size.height)];
    
    if (!self.totalPriceView) {
        self.totalPriceView = [[JAPriceView alloc] init];
        [self.subtotalView addSubview:self.totalPriceView];
    }
    
    if(VALID_NOTEMPTY([[self cart] cartUnreducedValueFormatted], NSString))
    {
        [self.totalPriceView loadWithPrice:[[self cart] cartUnreducedValueFormatted]
                              specialPrice:[[self cart] subTotalFormatted]
                                  fontSize:11.0f
                     specialPriceOnTheLeft:NO];
    }
    else
    {
        [self.totalPriceView loadWithPrice:[[self cart] subTotalFormatted]
                              specialPrice:nil
                                  fontSize:11.0f
                     specialPriceOnTheLeft:NO];
    }
    
    self.totalPriceView.frame = CGRectMake(self.subtotalView.frame.size.width - self.totalPriceView.frame.size.width - 4.0f,
                                           CGRectGetMaxY(self.subtotalTitleSeparator.frame) + 10.0f,
                                           self.totalPriceView.frame.size.width,
                                           self.totalPriceView.frame.size.height);
    
    if (!self.cartVatLabel) {
        self.cartVatLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.subtotalView addSubview:self.cartVatLabel];
    }
    
    [self.cartVatLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.cartVatLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.cartVatLabel setText:[self.cart vatLabel]];
    [self.cartVatLabel sizeToFit];
    [self.cartVatLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.cartVatLabel setFrame:CGRectMake(self.articlesCount.x,
                                           CGRectGetMaxY(self.articlesCount.frame) + 4.f,
                                           self.cartVatLabel.frame.size.width,
                                           self.cartVatLabel.frame.size.height)];
    
    if (!self.cartVatValue) {
        self.cartVatValue = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.subtotalView addSubview:self.cartVatValue];
    }
    
    [self.cartVatValue setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.cartVatValue setTextColor:UIColorFromRGB(0x666666)];
    if ([[self.cart vatLabelEnabled] boolValue]) {
        [self.cartVatValue setText:[self.cart vatValueFormatted]];
        [self.cartVatValue setHidden:NO];
    }else{
        [self.cartVatValue setHidden:YES];
    }
    [self.cartVatValue sizeToFit];
    [self.cartVatValue setBackgroundColor:[UIColor clearColor]];
    [self.cartVatValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.cartVatValue.frame.size.width - 4.0f,
                                          CGRectGetMaxY(self.articlesCount.frame) + 4.f,
                                          self.cartVatValue.frame.size.width,
                                           self.cartVatValue.frame.size.height)];
    
    
    CGFloat nextElementPosY = CGRectGetMaxY(self.cartVatLabel.frame);
    
    
    
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
    
    if(VALID_NOTEMPTY(priceRuleKeysString, NSString) && VALID_NOTEMPTY(priceRuleValuesString, NSString))
    {
        if (!self.priceRulesLabel) {
            self.priceRulesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.priceRulesLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
            [self.priceRulesLabel setTextColor:UIColorFromRGB(0x666666)];
            [self.subtotalView addSubview:self.priceRulesLabel];
        }
        [self.priceRulesLabel setNumberOfLines:[[[self cart] priceRules] allKeys].count];
        [self.priceRulesLabel setText:priceRuleKeysString];
        [self.priceRulesLabel sizeToFit];
        [self.priceRulesLabel setFrame:CGRectMake(6.0f,
                                                  CGRectGetMaxY(self.cartVatLabel.frame) + 4.0f,
                                                  self.priceRulesLabel.frame.size.width,
                                                  self.priceRulesLabel.frame.size.height)];
        
        if (!self.priceRulesValue) {
            self.priceRulesValue = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.priceRulesValue setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
            [self.priceRulesValue setTextColor:UIColorFromRGB(0x666666)];
            [self.priceRulesValue setTextAlignment:NSTextAlignmentRight];
            [self.subtotalView addSubview:self.priceRulesValue];
        }
        [self.priceRulesValue setNumberOfLines:[[[self cart] priceRules] allKeys].count];
        [self.priceRulesValue setWidth:self.subtotalView.width];
        [self.priceRulesValue setText:priceRuleValuesString];
        [self.priceRulesValue sizeToFit];
        [self.priceRulesValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.priceRulesValue.frame.size.width - 4.0f,
                                                  CGRectGetMaxY(self.cartVatLabel.frame) + 4.0f,
                                                  self.priceRulesValue.frame.size.width,
                                                  self.priceRulesValue.frame.size.height)];
        
        nextElementPosY = CGRectGetMaxY(self.priceRulesLabel.frame) + 4.f;
        
        [self.priceRulesLabel setHidden:NO];
        [self.priceRulesValue setHidden:NO];
    }
    else
    {
        if(VALID_NOTEMPTY(self.priceRulesLabel, UILabel))
        {
            [self.priceRulesLabel setHidden:YES];
        }
        if(VALID_NOTEMPTY(self.priceRulesValue, UILabel))
        {
            [self.priceRulesValue setHidden:YES];
        }

    }
    
    if (VALID_NOTEMPTY(self.cart.shippingValue, NSNumber) && self.cart.shippingValue.floatValue != 0.f) {
        if (!_shippingFeeLabel) {
            _shippingFeeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [_shippingFeeLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
            [_shippingFeeLabel setTextColor:UIColorFromRGB(0x666666)];
            [_shippingFeeLabel setText:STRING_SHIPPING_FEE];
            [_shippingFeeLabel sizeToFit];
            [self.subtotalView addSubview:_shippingFeeLabel];
        }
        [_shippingFeeLabel setX:6];
        [_shippingFeeLabel setY:nextElementPosY];
        [_shippingFeeLabel setHidden:NO];
        
        if (!_shippingFeeValueLabel) {
            _shippingFeeValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [_shippingFeeValueLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
            [_shippingFeeValueLabel setTextColor:UIColorFromRGB(0x666666)];
            [self.subtotalView addSubview:_shippingFeeValueLabel];
        }
        [_shippingFeeValueLabel setText:self.cart.shippingValueFormatted];
        [_shippingFeeValueLabel sizeToFit];
        [_shippingFeeValueLabel setX:CGRectGetMaxX(self.subtotalView.frame) - _shippingFeeValueLabel.width - 4.f];
        [_shippingFeeValueLabel setY:nextElementPosY];
        nextElementPosY = CGRectGetMaxY(_shippingFeeLabel.frame) + 4.f;
        [_shippingFeeValueLabel setHidden:NO];
    }else{
        if (!_shippingFeeLabel) {
            [_shippingFeeLabel setHidden:YES];
        }
        if (!_shippingFeeValueLabel) {
            [_shippingFeeValueLabel setHidden:YES];
        }
    }

    if (!self.extraCostsLabel) {
        self.extraCostsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.extraCostsLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
        [self.extraCostsLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.extraCostsLabel setText:STRING_EXTRA_COSTS];
        [self.extraCostsLabel sizeToFit];
        [self.subtotalView addSubview:self.extraCostsLabel];
    }
    [self.extraCostsLabel setFrame:CGRectMake(6.0f,
                                              nextElementPosY,
                                              self.extraCostsLabel.frame.size.width,
                                              self.extraCostsLabel.frame.size.height)];
    
    
    if (!self.extraCostsValue) {
        self.extraCostsValue = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.extraCostsValue setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
        [self.extraCostsValue setTextColor:UIColorFromRGB(0x666666)];
        [self.subtotalView addSubview:self.extraCostsValue];
    }
    [self.extraCostsValue setText:[[self cart] extraCostsFormatted]];
    [self.extraCostsValue sizeToFit];
    [self.extraCostsValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.extraCostsValue.frame.size.width - 4.0f,
                                              nextElementPosY,
                                              self.extraCostsValue.frame.size.width,
                                              self.extraCostsValue.frame.size.height)];
    
    if([self.cart.extraCosts integerValue] == 0) {
        [self.extraCostsLabel setHidden:YES];
        [self.extraCostsValue setHidden:YES];
    }else{
        [self.extraCostsLabel setHidden:NO];
        [self.extraCostsValue setHidden:NO];
        nextElementPosY = CGRectGetMaxY(self.extraCostsLabel.frame) + 4.f;
    }
    
    if(VALID([[self cart] couponMoneyValue], NSNumber))
    {
        if (!self.couponLabel) {
            self.couponLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.couponLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
            [self.couponLabel setTextColor:UIColorFromRGB(0x3aaa35)];
            [self.couponLabel setText:STRING_VOUCHER];
            [self.couponLabel sizeToFit];
            [self.subtotalView addSubview:self.couponLabel];
        }
        [self.couponLabel setBackgroundColor:[UIColor clearColor]];
        [self.couponLabel setFrame:CGRectMake(6.0f,
                                              nextElementPosY,
                                              self.couponLabel.frame.size.width,
                                              self.couponLabel.frame.size.height)];
        
        if (!self.couponValue) {
            self.couponValue = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.couponValue setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
            [self.couponValue setTextColor:UIColorFromRGB(0x3aaa35)];
            [self.subtotalView addSubview:self.couponValue];
        }
        [self.couponValue setText:[NSString stringWithFormat:@"- %@", [[self cart] couponMoneyValueFormatted]]];
        [self.couponValue sizeToFit];
        [self.couponValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.couponValue.frame.size.width - 4.0f,
                                              nextElementPosY,
                                              self.couponValue.frame.size.width,
                                              self.couponValue.frame.size.height)];
        
        nextElementPosY = CGRectGetMaxY(self.couponValue.frame) + 4.f;
        [self.couponLabel setHidden:NO];
        [self.couponValue setHidden:NO];
    }
    else
    {
        if(VALID_NOTEMPTY(self.couponLabel, UILabel))
        {
            [self.couponLabel setHidden:YES];
        }
        if(VALID_NOTEMPTY(self.couponValue, UILabel))
        {
            [self.couponValue setHidden:YES];
        }
        
    }
    
    if (!self.totalLabel)
    {
        self.totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.totalLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
        [self.totalLabel setTextColor:UIColorFromRGB(0x666666)];
        [self.totalLabel setText:STRING_TOTAL];
        [self.totalLabel sizeToFit];
        [self.subtotalView addSubview:self.totalLabel];
    }
    
    if (!self.totalValue) {
        self.totalValue = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.totalValue setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
        [self.totalValue setTextColor:UIColorFromRGB(0xcc0000)];
        [self.subtotalView addSubview:self.totalValue];
    }
    [self.totalValue setText:[[self cart] cartValueFormatted]];
    [self.totalValue sizeToFit];
    
    [self.totalLabel setFrame:CGRectMake(6.0f,
                                         nextElementPosY + 8.0f,
                                         self.totalLabel.frame.size.width,
                                         self.totalLabel.frame.size.height)];
    
    [self.totalValue setFrame:CGRectMake(self.subtotalView.frame.size.width - self.totalValue.frame.size.width - 4.0f,
                                         nextElementPosY+ 8.0f,
                                         self.totalValue.frame.size.width,
                                         self.totalValue.frame.size.height)];
    
    [self.subtotalView setHeight:CGRectGetMaxY(self.totalValue.frame) + 10.0f];
    
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
    
    UIImage *checkoutButtonImageNormal = [UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"normal"]];
    if (!self.checkoutButton) {
        self.checkoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.checkoutButton setBackgroundImage:checkoutButtonImageNormal forState:UIControlStateNormal];
        [self.checkoutButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]] forState:UIControlStateHighlighted];
        [self.checkoutButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]] forState:UIControlStateSelected];
        [self.checkoutButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"disabled"]] forState:UIControlStateDisabled];
        [self.checkoutButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
        [self.checkoutButton setTitle:STRING_PROCEED_TO_CHECKOUT forState:UIControlStateNormal];
        [self.checkoutButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
        [self.checkoutButton addTarget:self action:@selector(checkoutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.cartScrollView addSubview:self.checkoutButton];
    }
    
    [self.checkoutButton setFrame:CGRectMake(0.0f,
                                             CGRectGetMaxY(self.subtotalView.frame) + 6.0f,
                                             checkoutButtonImageNormal.size.width,
                                             checkoutButtonImageNormal.size.height)];
    
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
        
        self.cartScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0,0,0,self.cartScrollView.bounds.size.width-7);
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
        [RICart removeProductWithSku:product.simpleSku
                         withSuccessBlock:^(RICart *cart) {
                             
                             NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
                             [skusFromTeaserInCart removeObjectForKey:product.sku];
                             [[NSUserDefaults standardUserDefaults] setObject:[skusFromTeaserInCart copy] forKey:kSkusFromTeaserInCartKey];
                             
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
                             [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                             
                             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromCart]
                                                                       data:[trackingDictionary copy]];
                             
                             NSMutableDictionary *tracking = [NSMutableDictionary new];
                             [tracking setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                             [tracking setValue:cart.cartCount forKey:kRIEventQuantityKey];
                             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                                       data:[tracking copy]];
                             
                             NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                             [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                             
                             [self loadCartInfo];
                             [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                             [self hideLoading];
                         } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                             [self onErrorResponse:apiResponse messages:@[STRING_NO_NETWORK_DETAILS] showAsMessage:YES selector:nil objects:nil];
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
    
    self.picker = [[JAPicker alloc] initWithFrame:[self viewBounds]];
    [self.picker setDelegate:self];
    
    NSMutableArray *dataSource = [NSMutableArray new];
    
    if(VALID_NOTEMPTY([self.currentItem maxQuantity], NSNumber) && 0 < [[self.currentItem maxQuantity] integerValue])
    {
        NSInteger maxQuantity = [[self.currentItem maxQuantity] integerValue];
        if(VALID_NOTEMPTY([self.currentItem maxQuantity], NSNumber))
        {
            maxQuantity = [[self.currentItem maxQuantity] integerValue];
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
    
    CGFloat pickerViewHeight = [self viewBounds].size.height;
    CGFloat pickerViewWidth = [self viewBounds].size.width;
    [self.picker setFrame:CGRectMake(0.0f,
                                     pickerViewHeight,
                                     pickerViewWidth,
                                     pickerViewHeight)];
    [self.view addSubview:self.picker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f,
                                                          [self viewBounds].origin.y,
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
            [self setupCart];
            [self.couponTextField setEnabled:YES];
             [self.couponTextField setText:@""];
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self onErrorResponse:apiResponse messages:@[STRING_NO_NETWORK_DETAILS] showAsMessage:YES selector:nil objects:NO];
            [self hideLoading];
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
            [self setupCart];
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self hideLoading];
            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            if (networkStatus == NotReachable) {
                [self onErrorResponse:RIApiResponseUnknownError messages:@[STRING_NO_NETWORK_DETAILS] showAsMessage:YES selector:nil objects:nil];
            }
            else{
                [self.couponTextField setTextColor:UIColorFromRGB(0xcc0000)];
            }
        }];
    }
}

- (void)checkoutButtonPressed
{
    [JAAuthenticationViewController goToCheckoutWithBlock:^{
        
        [self showLoading];
        [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"Started" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
            
            [trackingDictionary setValue:[NSNumber numberWithInteger:[[self.cart cartItems] count]] forKey:kRIEventQuantityKey];
            [trackingDictionary setValue:[self.cart cartValueEuroConverted] forKey:kRIEventTotalCartKey];
            
            NSMutableString* attributeSetID = [NSMutableString new];
            for( RICartItem* pd in [self.cart cartItems]) {
                [attributeSetID appendFormat:@"%@;",[pd attributeSetID]];
            }
            [trackingDictionary setValue:[attributeSetID copy] forKey:kRIEventAttributeSetIDCartKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutStart]
                                                      data:[trackingDictionary copy]];
            
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
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
            
            [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:nil objects:nil];
        }];
    }];
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
                                                          userInfo:@{ @"sku" : product.sku,
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
        [trackingDictionary setValue:self.cart.cartValueEuroConverted  forKey:kRIEventTotalCartKey];
        
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
        [quantitiesToChange setValue:[NSString stringWithFormat:@"%ld", (long)newQuantity] forKey:@"quantity"];
        [quantitiesToChange setValue:[self.currentItem simpleSku] forKey:@"sku"];
        
        [RICart changeQuantityInProducts:quantitiesToChange
                        withSuccessBlock:^(RICart *cart) {
                            self.cart = cart;
                            
                            NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
                            [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                            [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
                            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                                      data:[trackingDictionary copy]];
                            
                            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                            
                            [self closePicker];
                            [self setupCart];
                            [self hideLoading];
                        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                            [self closePicker];
                            [self hideLoading];
                            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                            if (networkStatus == NotReachable) {
                                [self onErrorResponse:RIApiResponseUnknownError messages:@[STRING_NO_NETWORK_DETAILS] showAsMessage:YES selector:nil objects:nil];
                            }
                            else {
                                [self onErrorResponse:RIApiResponseUnknownError messages:errorMessages showAsMessage:YES selector:nil objects:nil];
                            }
                        }];
    }
    else
    {
        [self closePicker];
    }
    
    CGRect frame = self.picker.frame;
    frame.origin.y = [self viewBounds].size.height;
    
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
    frame.origin.y = [self viewBounds].size.height;
    
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
    if([self viewBounds].size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    
    height -= kTabBarHeight;//compensate for tab bar because keyboard is shown on top
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.cartScrollView setHeight:self.cartScrollViewInitialFrame.size.height - height];
    }];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.cartScrollView setHeight:self.cartScrollViewInitialFrame.size.height];
    }];
}

@end
