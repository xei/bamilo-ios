//
//  JASavedListViewController.m
//  Jumia
//
//  Created by Jose Mota on 04/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JASavedListViewController.h"
#import "JAProductCollectionViewFlowLayout.h"
#import "JARecentlyViewedCell.h"
#import "RIProductSimple.h"
#import "RICategory.h"
#import "RICustomer.h"
#import "RIAddress.h"
#import "JAPicker.h"
#import "JAUtils.h"
#import "RICart.h"
#import "CartDataManager.h"
#import "EmptyViewController.h"
#import "EmarsysPredictManager.h"
#import "Bamilo-Swift.h"

#define kMaxProducts 20
#define kMaxProducts_ipad 34

@interface JASavedListViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JAPickerDelegate, UINavigationControllerDelegate>

//@property (strong, nonatomic) UIView *emptyListView;
//@property (strong, nonatomic) UILabel *emptyListLabel;
//@property (strong, nonatomic) UIImageView* emptyListImageView;
//@property (strong, nonatomic) UILabel *emptyTitleLabel;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) JAProductCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *productsArray;
@property (nonatomic, strong) NSMutableDictionary *productsDictionary;
@property (assign, nonatomic) BOOL selectedSizeAndAddToCart;
@property (nonatomic, weak) EmptyViewController *emptyViewController;
@property (nonatomic, weak) IBOutlet UIView *emptyViewContainer;

// size picker view
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (nonatomic, strong) NSMutableDictionary* chosenSimples;
@property (strong, nonatomic) UIButton *backupButton; // for the retry connection, is necessary to store the button
//@property (strong, nonatomic) UIView *bottomView;

// pagination
@property (nonatomic) BOOL lastPage;
@property (nonatomic) NSNumber *currentPage;
@property (nonatomic) NSNumber *maxPerPage;
@property (nonatomic) NSNumber *numberProducts;

@property (strong, nonatomic) RICart *cart;

@end

@implementation JASavedListViewController

- (NSMutableDictionary *)productsDictionary {
    if (!VALID(_productsDictionary, NSMutableDictionary)) {
        _productsDictionary = [NSMutableDictionary new];
    }
    return _productsDictionary;
}

- (NSMutableArray *)productsArray {
    if (!VALID(_productsArray, NSMutableArray)) {
        _productsArray = [NSMutableArray new];
    }
    return _productsArray;
}

- (JAProductCollectionViewFlowLayout *)flowLayout {
    if (!VALID_NOTEMPTY(_flowLayout, JAProductCollectionViewFlowLayout)) {
        
        _flowLayout = [[JAProductCollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 1.0f;
        _flowLayout.minimumInteritemSpacing = 0.f;
        [_flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"horizontalSeparator"];
        [_flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"verticalSeparator"];
        
        //                                              top, left, bottom, right
        [self.flowLayout setSectionInset:UIEdgeInsetsMake(0.f, 0.0, 0.0, 0.0)];
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (NSNumber *)currentPage {
    if (!VALID(_currentPage, NSNumber)) {
        _currentPage = @0;
    }
    return _currentPage;
}

- (NSNumber *)maxPerPage {
    if (!VALID(_maxPerPage, NSNumber)) {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            _maxPerPage = [NSNumber numberWithInt:kMaxProducts_ipad];
        } else {
            _maxPerPage = [NSNumber numberWithInt:kMaxProducts];
        }
    }
    return _maxPerPage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerClass:[JARecentlyViewedCell class] forCellWithReuseIdentifier:@"CellWithLines"];
    
    CGRect frame = self.view.bounds;
    
    self.collectionView.collectionViewLayout = self.flowLayout;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView setFrame:frame];
    [self.emptyViewContainer hide];
    self.navigationController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoggedOut) name:kUserLoggedOutNotification object:nil];
}

// TODO: In some wierd cases! viewWillAppear is not getting called! (Scenario: with logged out user >
// come to SavedListViewController (authneticationViewcontorller will be pushed) > got to profile >
// go to OrderListViewcontroller (authneticationViewcontorller will be pushed) > login >
// Switch to SavedListViewContorller (tab item) > atuhenticationViewController will be poped >
// and comes to SavedListViewController > but !!!! viewWillAppear will not be called!
- (void)navigationController:(UINavigationController *)navigationController  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController viewWillAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([RICustomer checkIfUserIsLogged]) {
        self.currentPage = @0;
        [self loadProducts];
    } else {
        [((JACenterNavigationController *)self.navigationController) requestForcedLogin];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self collectionView];

    
    [self.emptyViewContainer setFrame:self.collectionView.frame];
}

- (void)onOrientationChanged {
    if(VALID(self.picker, JAPicker)) {
        [self closePicker];
    }
}

#pragma mark - Load Data
- (void)loadProducts {
    [LoadingManager showLoading];
    [RIProduct getFavoriteProductsForPage:self.currentPage.integerValue+1 maxItems:self.maxPerPage.integerValue SuccessBlock:^(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages) {
        
        if (favoriteProducts.count > 0) {
            
            if (currentPage == totalPages) {
                self.lastPage = YES;
            }
            [self.productsArray removeAllObjects];
            for (RIProduct *product in favoriteProducts) {
                if ([self.productsArray containsObject:product.sku]) {
                    [self.productsArray removeObject:product.sku];
                }
                [self.productsArray addObject:product.sku];
                [self.productsDictionary setObject:product forKey:product.sku];
            }
            self.chosenSimples = [NSMutableDictionary new];
            [self reloadData];
            self.currentPage = [NSNumber numberWithInteger:self.currentPage.integerValue+1];
            [self publishScreenLoadTime];
        } else {
            self.productsDictionary = nil;
            [self.productsArray removeAllObjects];
            [self reloadData];
        }
        [LoadingManager hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        [self showNotificationBar:error isSuccess:NO];
        [self publishScreenLoadTime];
        [LoadingManager hideLoading];
    }];
}

- (RIProduct *)getProductFromIndex:(NSInteger)index {
    NSString *sku = [self.productsArray objectAtIndex:index];
    if (VALID_NOTEMPTY(sku, NSString)) {
        return [self.productsDictionary objectForKey:sku];
    }
    return nil;
}

- (void)reloadData {
    [LoadingManager showLoading];
    [self.collectionView reloadData];
    if (ISEMPTY(self.productsArray)) {
        
        [self.emptyViewContainer fadeIn:0.15];
        [self.emptyViewController getSuggestions];
        self.collectionView.hidden = YES;
    } else {
        [self.emptyViewContainer hide];
        self.collectionView.hidden = NO;
        [EmarsysPredictManager sendTransactionsOf:self];
    }
    [LoadingManager hideLoading];
}

#pragma mark - collectionView methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.lastPage && indexPath.row == self.productsArray.count-1) {
        [self loadProducts];
    }
    RIProduct *product = [self getProductFromIndex:indexPath.row];
    
    JARecentlyViewedCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellWithLines" forIndexPath:indexPath];
    [cell setHideRating:YES];
    [cell setHideShopFirstLogo:YES];
    [cell setProduct:product];
    
    if (1 < product.productSimples.count) {
        [cell.sizeButton setHidden:NO];
        RIProductSimple* chosenSimple = [self.chosenSimples objectForKey:product.sku];
        if (!VALID_NOTEMPTY(chosenSimple, RIProductSimple)) {
            [cell.sizeButton setTitle:STRING_SIZE forState:UIControlStateNormal];
        } else {
            [cell setSimplePrice:chosenSimple.specialPriceFormatted andOldPrice:chosenSimple.priceFormatted];
            [cell.sizeButton setTitle:[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, chosenSimple.variation] forState:UIControlStateNormal];
        }
        [cell.sizeButton addTarget:self
                            action:@selector(sizeButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.sizeButton setHidden:YES];
    }
    
    [cell.favoriteButton setHidden:NO];
    [cell.favoriteButton addTarget:self action:@selector(removeFromSavedListPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell setTag:indexPath.row];
    [cell.feedbackView addTarget:self
                          action:@selector(clickableViewPressedInCell:)
                forControlEvents:UIControlEventTouchUpInside];
    [cell.addToCartButton addTarget:self action:@selector(addToCartButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.productsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        size = CGSizeMake(self.view.width/2, 154.5f);
    } else {
        size = CGSizeMake(self.view.width, 154.5f);
    }
    
    self.flowLayout.itemSize = size;
    return size;
}

#pragma mark - Actions
- (void)clickableViewPressedInCell:(UIButton *)button {
    RIProduct *product = [self getProductFromIndex:button.tag];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:@{ @"sku" : product.sku,
                                                                  @"previousCategory" : STRING_RECENTLY_VIEWED,
                                                                  @"show_back_button" : [NSNumber numberWithBool:NO],
                                                                  @"fromCatalog" : [NSNumber numberWithBool:YES]}];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:[NSString stringWithFormat:@"Catalog_%@",product.name]];
}

- (void)addToCartButtonPressed:(UIButton *)button {
    self.backupButton = button;
    [self finishAddToCart:button];
}

- (void)finishAddToCart:(UIButton *)button {
    RIProduct* product = [self.productsDictionary objectForKey:[self.productsArray objectAtIndex:button.tag]];
    
    RIProductSimple* productSimple;
    
    if(VALID([self.chosenSimples objectForKey:product.sku], RIProductSimple)) {
        productSimple = [self.chosenSimples objectForKey:product.sku];
    } else if (1 == product.productSimples.count) {
            productSimple = [product.productSimples firstObject];
    } else {
        self.selectedSizeAndAddToCart = YES;
        [self sizeButtonPressed:button];
        return;
    }
    
    [DataAggregator addProductToCart:self simpleSku:productSimple.sku completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            
            //EVENT: ADD TO CART
            [TrackerManager postEventWithSelector:[EventSelectors addToCartEventSelector] attributes:[EventAttributes addToCardWithProduct:product screenName:[self getScreenName] success:YES]];
            
            NSNumber *price = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted longValue] > 0.0f) ? product.specialPriceEuroConverted :product.priceEuroConverted;
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"AddToCart" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
            [trackingDictionary setValue:price forKey:kRIEventValueKey];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
            [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
            [trackingDictionary setValue:product.name forKey:kRIEventProductNameKey];
            
            if(VALID_NOTEMPTY(product.categoryIds, NSArray)) {
                NSArray *categoryIds = product.categoryIds;
                NSInteger subCategoryIndex = [categoryIds count] - 1;
                NSInteger categoryIndex = subCategoryIndex - 1;
                
                if(categoryIndex >= 0) {
                    NSString *categoryId = [categoryIds objectAtIndex:categoryIndex];
                    [trackingDictionary setValue:[RICategory getCategoryName:categoryId] forKey:kRIEventCategoryIdKey];
                    
                    NSString *subCategoryId = [categoryIds objectAtIndex:subCategoryIndex];
                    [trackingDictionary setValue:[RICategory getCategoryName:subCategoryId] forKey:kRIEventSubCategoryIdKey];
                } else {
                    NSString *categoryId = [categoryIds objectAtIndex:subCategoryIndex];
                    [trackingDictionary setValue:[RICategory getCategoryName:categoryId] forKey:kRIEventCategoryIdKey];
                }
            }
            
            // Since we're sending the converted price, we have to send the currency as EUR.
            // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
            [trackingDictionary setValue:price forKey:kRIEventPriceKey];
            [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
            
            NSString *discountPercentage = @"0";
            if(VALID_NOTEMPTY(product.maxSavingPercentage, NSString)) {
                discountPercentage = product.maxSavingPercentage;
            }
            [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
            [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
            [trackingDictionary setValue:product.brand forKey:kRIEventBrandName];
            [trackingDictionary setValue:product.brandUrlKey forKey:kRIEventBrandKey];
            [trackingDictionary setValue:product.name forKey:kRIEventProductNameKey];
            [trackingDictionary setValue:productSimple.sku forKey:kRIEventSkuKey];
            [trackingDictionary setValue:self.cart.cartEntity.cartCount forKey:kRIEventQuantityKey];
            [trackingDictionary setValue:self.cart.cartEntity.cartValueEuroConverted forKey:kRIEventTotalCartKey];
            [trackingDictionary setValue:@"Wishlist" forKey:kRIEventLocationKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart] data:[trackingDictionary copy]];
            
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.cart forKey:kUpdateCartNotificationValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];

            
            NSMutableDictionary *tracking = [NSMutableDictionary new];
            [tracking setValue:product.name forKey:kRIEventProductNameKey];
            [tracking setValue:product.sku forKey:kRIEventSkuKey];
            if(VALID_NOTEMPTY(product.categoryIds, NSArray)) {
                [tracking setValue:[product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
            }
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastAddedToCart] data:tracking];
            
            tracking = [NSMutableDictionary new];
            [tracking setValue:self.cart.cartEntity.cartValueEuroConverted forKey:kRIEventTotalCartKey];
            [tracking setValue:self.cart.cartEntity.cartCount forKey:kRIEventQuantityKey];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart] data:[tracking copy]];
            
            trackingDictionary = [NSMutableDictionary new];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
            [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
            
            [trackingDictionary setValue:[price stringValue] forKey:kRIEventFBValueToSumKey];
            [trackingDictionary setValue:product.sku forKey:kRIEventFBContentIdKey];
            [trackingDictionary setValue:@"product" forKey:kRIEventFBContentTypeKey];
            [trackingDictionary setValue:@"EUR" forKey:kRIEventFBCurrency];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookAddToCart] data:[trackingDictionary copy]];
            
            [self removeFromSavedList:product showMessage:NO];
            //[self hideLoading];
        } else {
            //EVENT: ADD TO CART
            [TrackerManager postEventWithSelector:[EventSelectors addToCartEventSelector] attributes:[EventAttributes addToCardWithProduct:product screenName:[self getScreenName] success:NO]];
            [self showNotificationBar:[error.userInfo objectForKey:kErrorMessages] isSuccess:NO];
            //[self hideLoading];
        }
    }];
}

- (void)sizeButtonPressed:(UIButton*)button {
    self.backupButton = button;
    
    RIProduct *product = [self getProductFromIndex:button.tag];
    RIProductSimple* prevSimple = [self.chosenSimples objectForKey:product.sku];
    
    if(VALID(self.picker, JAPicker)) {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame: self.view.bounds];
    
    [self.picker setTag:button.tag];
    [self.picker setDelegate:self];
    
    self.pickerDataSource = [NSMutableArray new];
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    NSString *simpleSize = @"";
    if (VALID_NOTEMPTY(prevSimple, RIProductSimple)) {
        simpleSize = prevSimple.variation;
    }
    
    for (RIProductSimple* simple in product.productSimples) {
        if (simple.quantity.intValue > 0) {
            [self.pickerDataSource addObject:simple];
            [dataSource addObject:simple.variation];
        }
    }
    
    NSString* sizeGuideTitle = nil;
    if (VALID_NOTEMPTY(product.sizeGuideUrl, NSString)) {
        sizeGuideTitle = STRING_SIZE_GUIDE;
    }
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:simpleSize
                    leftButtonTitle:sizeGuideTitle];
    
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

- (void)removeFromSavedListPressed:(UIButton *)button {
    [self removeFromSavedList:[self getProductFromIndex:button.tag] showMessage:YES];
}

- (void)removeFromSavedList:(RIProduct *)product showMessage:(BOOL)showMessage {
    NSNumber *price = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted longValue] > 0.0f) ? product.specialPriceEuroConverted :product.priceEuroConverted;
    [LoadingManager showLoading];
    [DataAggregator removeFromWishListWithTarget:self sku:product.sku completion:^(id data, NSError *error) {
        if (error == nil) {
            
            [self showNotificationBarMessage:STRING_REMOVED_FROM_WISHLIST isSuccess:YES];
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"RemoveFromWishlist" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
            [trackingDictionary setValue:price forKey:kRIEventValueKey];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
            
            // Since we're sending the converted price, we have to send the currency as EUR.
            // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
            [trackingDictionary setValue:price forKey:kRIEventPriceKey];
            [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
            
            [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
            [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
            
            [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages) {
                
                [trackingDictionary setValue:[NSNumber numberWithInteger:favoriteProducts.count] forKey:kRIEventTotalWishlistKey];
                
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                          data:[trackingDictionary copy]];
            } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                          data:[trackingDictionary copy]];
            }];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInteger:RIEventAddFromWishlistToCart]
                                                      data:[NSDictionary dictionaryWithObject:product.sku forKey:kRIEventProductFavToCartKey]];
            
            [TrackerManager postEventWithSelector:[EventSelectors removeFromWishListSelector] attributes:[EventAttributes removeToWishListWithProduct:product screenName:[self getScreenName]]];
            
            [[NSUserDefaults standardUserDefaults] setObject:product.sku forKey:kRIEventProductFavToCartKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSMutableDictionary *tracking = [NSMutableDictionary new];
            [tracking setValue:product.name forKey:kRIEventProductNameKey];
            [tracking setValue:product.sku forKey:kRIEventSkuKey];
            [tracking setValue:[product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastAddedToCart] data:tracking];
            
            [self.productsArray removeObject:product.sku];
            [self.productsDictionary removeObjectForKey:product.sku];
            [self reloadData];
            [LoadingManager hideLoading];
        } else {
            
        }
    }];
}

#pragma mark JAPickerDelegate
-(void)selectedRow:(NSInteger)selectedRow {
    RIProduct *product = [self getProductFromIndex:self.picker.tag];
    
    RIProductSimple* selectedSimple = [self.pickerDataSource objectAtIndex:selectedRow];
    
    [self.chosenSimples setObject:selectedSimple forKey:product.sku];
    
    [self closePicker];
    [self reloadData];
    
    if (self.selectedSizeAndAddToCart) {
        self.selectedSizeAndAddToCart = NO;
        
        [self addToCartButtonPressed:self.backupButton];
    }
}

- (void)closePicker {
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

- (void)leftButtonPressed {
    RIProduct *product = [self getProductFromIndex:self.picker.tag];
    if (VALID_NOTEMPTY(product.sizeGuideUrl, NSString)) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:product.sizeGuideUrl, @"sizeGuideUrl", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSizeGuideNotification object:nil userInfo:dic];
        [self closePicker];
    }
}

#pragma mark - DataTrackerProtocol
- (NSString *)getScreenName {
    return @"WishList";
}


#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0:
            self.cart = [data objectForKey:kDataContent];
        break;
        default:
            break;
    }
}


#pragma segue preparation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"embedEmptyViewController"]) {
        self.emptyViewController = (EmptyViewController *) [segue destinationViewController];
        [self.emptyViewController updateTitle:STRING_FAVOURITES_NO_SAVED_ITEMS];
        self.emptyViewController.recommendationLogic = @"POPULAR";
        self.emptyViewController.parentScreenName = @"EmptyWishList";
        
        [self.emptyViewController updateImage:[UIImage imageNamed:@"emptyFavoritesIcon"]];
    }
}

- (void)didLoggedOut {
    [self.productsDictionary removeAllObjects];
    [self.productsArray removeAllObjects];
    
    [self.collectionView reloadData];
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_MY_FAVOURITES;
}

@end
