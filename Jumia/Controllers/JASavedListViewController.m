//
//  JASavedListViewController.m
//  Jumia
//
//  Created by Jose Mota on 04/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JASavedListViewController.h"
#import "JAProductCollectionViewFlowLayout.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "JARecentlyViewedCell.h"
#import "RIProductSimple.h"
#import "RICategory.h"
#import "RICustomer.h"
#import "RIAddress.h"
#import "JAPicker.h"
#import "JAUtils.h"
#import "RICart.h"

#define kMaxProducts 20
#define kMaxProducts_ipad 34

@interface JASavedListViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JAPickerDelegate>

@property (strong, nonatomic) UIView *emptyListView;
@property (strong, nonatomic) UILabel *emptyListLabel;
@property (strong, nonatomic) UIImageView* emptyListImageView;
@property (strong, nonatomic) UILabel *emptyTitleLabel;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) JAProductCollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *productsArray;
@property (nonatomic, strong) NSMutableDictionary *productsDictionary;
@property (assign, nonatomic) BOOL selectedSizeAndAddToCart;

// size picker view
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (nonatomic, strong) NSMutableDictionary* chosenSimples;

@property (strong, nonatomic) UIButton *backupButton; // for the retry connection, is necessary to store the button

@property (strong, nonatomic) UIView *bottomView;

// pagination
@property (nonatomic) BOOL lastPage;
@property (nonatomic) NSNumber *currentPage;
@property (nonatomic) NSNumber *maxPerPage;
@property (nonatomic) NSNumber *numberProducts;

@end

@implementation JASavedListViewController

- (NSMutableDictionary *)productsDictionary
{
    if (!VALID(_productsDictionary, NSMutableDictionary)) {
        _productsDictionary = [NSMutableDictionary new];
    }
    return _productsDictionary;
}

- (NSMutableArray *)productsArray
{
    if (!VALID(_productsArray, NSMutableArray)) {
        _productsArray = [NSMutableArray new];
    }
    return _productsArray;
}

-(UIView *)emptyListView {
    if (!VALID_NOTEMPTY(_emptyListView, UIView)) {
        _emptyListView = [[UIView alloc]initWithFrame:CGRectMake(self.viewBounds.origin.x,
                                                                 self.viewBounds.origin.y,
                                                                 self.viewBounds.size.width,
                                                                 self.viewBounds.size.height)];
        [_emptyListView setBackgroundColor:[UIColor whiteColor]];
        [_emptyListView addSubview:self.emptyTitleLabel];
        [_emptyListView addSubview:self.emptyListImageView];
        [_emptyListView addSubview:self.emptyListLabel];
        [self.view addSubview:_emptyListView];
    }
    return _emptyListView;
}

-(UILabel *)emptyTitleLabel {
    if(!VALID_NOTEMPTY(_emptyTitleLabel, UILabel)) {
        _emptyTitleLabel = [UILabel new];
        [_emptyTitleLabel setFont:JADisplay2Font];
        [_emptyTitleLabel setTextColor:JABlackColor];
        [_emptyTitleLabel setText:STRING_FAVOURITES_NO_SAVED_ITEMS];
        [_emptyTitleLabel sizeToFit];
        [_emptyTitleLabel setFrame:CGRectMake((self.viewBounds.size.width - _emptyTitleLabel.width)/2,
                                              48.f,
                                              _emptyTitleLabel.width, _emptyTitleLabel.height)];
    }
    return _emptyTitleLabel;
}

-(UIImageView *)emptyListImageView {
    if (!VALID_NOTEMPTY(_emptyListImageView, UIImageView)) {
        _emptyListImageView = [UIImageView new];
        UIImage * img = [UIImage imageNamed:@"emptyFavoritesIcon"];
        [_emptyListImageView setImage:img];
        [_emptyListImageView setFrame:CGRectMake((self.viewBounds.size.width - img.size.width)/2,
                                                 CGRectGetMaxY(self.emptyTitleLabel.frame) + 28.f,
                                                 img.size.width, img.size.height)];
    }
    return _emptyListImageView;
}

-(UILabel *)emptyListLabel {
    if (!VALID_NOTEMPTY(_emptyListLabel, UILabel)) {
        _emptyListLabel = [UILabel new];
        _emptyListLabel.font = JABody3Font;
        _emptyListLabel.textColor = JABlack800Color;
        _emptyListLabel.text = STRING_FAVOURITES_NO_SAVED_ITEMS_DESCRIPTION;
        [_emptyListLabel sizeToFit];
        [_emptyListLabel setFrame:CGRectMake((self.viewBounds.size.width - _emptyListLabel.width)/2,
                                             CGRectGetMaxY(self.emptyListImageView.frame) + 28,
                                             _emptyListLabel.width, _emptyListLabel.height)];
    }
    return _emptyListLabel;
}

- (JAProductCollectionViewFlowLayout *)flowLayout
{
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

- (UICollectionView *)collectionView
{
    CGRect frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.viewBounds.size.height - self.bottomView.height);
    if (!VALID_NOTEMPTY(_collectionView, UICollectionView)) {
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    else {
        if (!CGRectEqualToRect(frame, _collectionView.frame)) {
            [_collectionView reloadData];
            [_collectionView setFrame:frame];
        }
    }
    return _collectionView;
}

- (UIView *)bottomView
{
    if (!VALID(_bottomView, UIView)) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.viewBounds.size.height - 49.f, self.viewBounds.size.width, 1.f)];
        [_bottomView setBackgroundColor:JABlack700Color];
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (NSNumber *)currentPage
{
    if (!VALID(_currentPage, NSNumber)) {
        _currentPage = @0;
    }
    return _currentPage;
}

- (NSNumber *)maxPerPage
{
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
    self.navBarLayout.title = STRING_MY_FAVOURITES;
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerClass:[JARecentlyViewedCell class] forCellWithReuseIdentifier:@"CellWithLines"];
    
    [self loadProducts];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatedProduct:)
                                                 name:kProductChangedNotification
                                               object:nil];

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self collectionView];
    [self.emptyListView setFrame:self.viewBounds];
    [self.emptyTitleLabel setXCenterAligned];
    [self.emptyListImageView setXCenterAligned];
    [self.emptyListLabel setXCenterAligned];
    
    [self.bottomView setWidth:self.viewBounds.size.width];
    [self.bottomView setYBottomAligned:48.f];
}

- (void)onOrientationChanged
{
    if(VALID(self.picker, JAPicker))
    {
        [self closePicker];
    }
}

#pragma mark - Load Data

- (void)loadProducts
{
    [self showLoading];
    [RIProduct getFavoriteProductsForPage:self.currentPage.integerValue+1 maxItems:self.maxPerPage.integerValue SuccessBlock:^(NSArray *favoriteProducts, NSInteger currentPage, NSInteger totalPages) {
        
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        if (favoriteProducts.count > 0) {
            
            if (currentPage == totalPages) {
                self.lastPage = YES;
            }
            
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
            
            if(self.firstLoading)
            {
                NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                self.firstLoading = NO;
            }
        } else {
            self.productsDictionary = nil;
            [self reloadData];
        }
        
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        
        [self onErrorResponse:apiResponse messages:error showAsMessage:NO selector:@selector(loadProducts) objects:nil];
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        [self hideLoading];
    }];
}

- (RIProduct *)getProductFromIndex:(NSInteger)index
{
    NSString *sku = [self.productsArray objectAtIndex:index];
    if (VALID_NOTEMPTY(sku, NSString)) {
        return [self.productsDictionary objectForKey:sku];
    }
    return nil;
}

- (void)reloadData
{
    [self showLoading];
    [self.collectionView reloadData];
    if (ISEMPTY(self.productsArray)) {
        self.emptyListView.hidden = NO;
        self.collectionView.hidden = YES;
        [self.bottomView setHidden:YES];
    } else {
        self.emptyListView.hidden = YES;
        self.collectionView.hidden = NO;
        [self.bottomView setHidden:NO];
    }
    [self hideLoading];
}

#pragma mark - kProductChangedNotification

- (void)updatedProduct:(NSNotification *)notification
{
    [self showLoading];
    __block NSString *sku = notification.object;
    [RIProduct getCompleteProductWithSku:sku successBlock:^(RIProduct *product) {
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        if (VALID_NOTEMPTY([product favoriteAddDate], NSDate)) {
            if (![self.productsArray containsObject:product.sku]) {
                [self.productsArray addObject:product.sku];
            }
        }else{
            if ([self.productsArray containsObject:product.sku]) {
                [self.productsArray removeObject:product.sku];
            }
        }
        [self.productsDictionary setObject:product forKey:sku];
        [self reloadData];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        [self onErrorResponse:apiResponse messages:error showAsMessage:NO selector:@selector(updatedProduct:) objects:@[notification]];
        [self hideLoading];
    }];
}

#pragma mark - collectionView methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.lastPage && indexPath.row == self.productsArray.count-1) {
        
        [self loadProducts];
        
    }
    RIProduct *product = [self getProductFromIndex:indexPath.row];
    
    JARecentlyViewedCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellWithLines" forIndexPath:indexPath];
    [cell setHideRating:YES];
    [cell setHideShopFirstLogo:YES];
    [cell loadWithProduct:product];
    
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
    }else{
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productsArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        size = CGSizeMake(self.bounds.size.width/2, 154.5f);
    } else {
        size = CGSizeMake(self.view.frame.size.width, 154.5f);
    }
    
    self.flowLayout.itemSize = size;
    return size;
}

#pragma mark - Actions

- (void)clickableViewPressedInCell:(UIButton *)button
{
    RIProduct *product = [self getProductFromIndex:button.tag];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:@{ @"sku" : product.sku,
                                                                  @"previousCategory" : STRING_RECENTLY_VIEWED,
                                                                  @"show_back_button" : [NSNumber numberWithBool:NO],
                                                                  @"fromCatalog" : [NSNumber numberWithBool:YES]}];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:[NSString stringWithFormat:@"Catalog_%@",product.name]];
}

- (void)addToCartButtonPressed:(UIButton *)button
{
    self.backupButton = button;
    [self finishAddToCart:button];
}

- (void)finishAddToCart:(UIButton *)button
{
    RIProduct* product = [self.productsDictionary objectForKey:[self.productsArray objectAtIndex:button.tag]];
    
    RIProductSimple* productSimple;
    
    if(VALID([self.chosenSimples objectForKey:product.sku], RIProductSimple))
    {
        productSimple = [self.chosenSimples objectForKey:product.sku];
    } else
        if (1 == product.productSimples.count) {
            productSimple = [product.productSimples firstObject];
        } else {
            self.selectedSizeAndAddToCart = YES;
            [self sizeButtonPressed:button];
            return;
        }
    
    [self showLoading];
    [RICart addProductWithQuantity:@"1"
                         simpleSku:productSimple.sku
                  withSuccessBlock:^(RICart *cart, RIApiResponse apiResponse, NSArray *successMessage) {
                      
                      NSNumber *price = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f) ? product.specialPriceEuroConverted :product.priceEuroConverted;
                      
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
                      
                      if(VALID_NOTEMPTY(product.categoryIds, NSArray))
                      {
                          NSArray *categoryIds = product.categoryIds;
                          NSInteger subCategoryIndex = [categoryIds count] - 1;
                          NSInteger categoryIndex = subCategoryIndex - 1;
                          
                          if(categoryIndex >= 0)
                          {
                              NSString *categoryId = [categoryIds objectAtIndex:categoryIndex];
                              [trackingDictionary setValue:[RICategory getCategoryName:categoryId] forKey:kRIEventCategoryIdKey];
                              
                              NSString *subCategoryId = [categoryIds objectAtIndex:subCategoryIndex];
                              [trackingDictionary setValue:[RICategory getCategoryName:subCategoryId] forKey:kRIEventSubCategoryIdKey];
                          }
                          else
                          {
                              NSString *categoryId = [categoryIds objectAtIndex:subCategoryIndex];
                              [trackingDictionary setValue:[RICategory getCategoryName:categoryId] forKey:kRIEventCategoryIdKey];
                          }
                      }
                      
                      // Since we're sending the converted price, we have to send the currency as EUR.
                      // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
                      [trackingDictionary setValue:price forKey:kRIEventPriceKey];
                      [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
                      
                      NSString *discountPercentage = @"0";
                      if(VALID_NOTEMPTY(product.maxSavingPercentage, NSString))
                      {
                          discountPercentage = product.maxSavingPercentage;
                      }
                      [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
                      [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
                      [trackingDictionary setValue:product.brand forKey:kRIEventBrandName];
                      [trackingDictionary setValue:product.brandUrlKey forKey:kRIEventBrandKey];
                      [trackingDictionary setValue:product.name forKey:kRIEventProductNameKey];
                      [trackingDictionary setValue:productSimple.sku forKey:kRIEventSkuKey];
                      [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
                      [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                      [trackingDictionary setValue:@"Wishlist" forKey:kRIEventLocationKey];
                      
                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart]
                                                                data:[trackingDictionary copy]];
                      
                      float value = [price floatValue];
                      [FBSDKAppEvents logEvent:FBSDKAppEventNameAddedToCart
                                    valueToSum:value
                                    parameters:@{ FBSDKAppEventParameterNameCurrency    : @"EUR",
                                                  FBSDKAppEventParameterNameContentType : product.name,
                                                  FBSDKAppEventParameterNameContentID   : product.sku}];
                      
                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      
                      [self onSuccessResponse:RIApiResponseSuccess messages:successMessage showMessage:YES];
                      
                      NSMutableDictionary *tracking = [NSMutableDictionary new];
                      [tracking setValue:product.name forKey:kRIEventProductNameKey];
                      [tracking setValue:product.sku forKey:kRIEventSkuKey];
                      if(VALID_NOTEMPTY(product.categoryIds, NSArray)) {
                          [tracking setValue:[product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
                      }
                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastAddedToCart] data:tracking];
                      
                      
                      tracking = [NSMutableDictionary new];
                      [tracking setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                      [tracking setValue:cart.cartCount forKey:kRIEventQuantityKey];
                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                                data:[tracking copy]];
                      
                      
                      trackingDictionary = [NSMutableDictionary new];
                      [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                      NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
                      [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
                      
                      [trackingDictionary setValue:[price stringValue] forKey:kRIEventFBValueToSumKey];
                      [trackingDictionary setValue:product.sku forKey:kRIEventFBContentIdKey];
                      [trackingDictionary setValue:@"product" forKey:kRIEventFBContentTypeKey];
                      [trackingDictionary setValue:@"EUR" forKey:kRIEventFBCurrency];
                      
                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookAddToCart]
                                                                data:[trackingDictionary copy]];
                      
                      [self removeFromSavedList:product showMessage:NO];
                      [self hideLoading];
                      
                  } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                      
                      [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:@selector(finishAddToCart:) objects:@[button]];
                      [self hideLoading];
                  }];
}

- (void)sizeButtonPressed:(UIButton*)button
{
    self.backupButton = button;
    
    RIProduct *product = [self getProductFromIndex:button.tag];
    RIProductSimple* prevSimple = [self.chosenSimples objectForKey:product.sku];
    
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
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

- (void)removeFromSavedListPressed:(UIButton *)button
{
    [self removeFromSavedList:[self getProductFromIndex:button.tag] showMessage:YES];
}

- (void)removeFromSavedList:(RIProduct *)product showMessage:(BOOL)showMessage
{
    NSNumber *price = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f) ? product.specialPriceEuroConverted :product.priceEuroConverted;
    [self showLoading];
    [RIProduct removeFromFavorites:product successBlock:^(RIApiResponse apiResponse, NSArray *success) {
        
        [self onSuccessResponse:RIApiResponseSuccess messages:@[STRING_REMOVED_FROM_WISHLIST] showMessage:showMessage];
        
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
        [self hideLoading];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        
        [self onErrorResponse:apiResponse messages:error showAsMessage:YES selector:@selector(removeFromSavedList:) objects:@[product]];
        
        [self hideLoading];
    }];
}

#pragma mark JAPickerDelegate
-(void)selectedRow:(NSInteger)selectedRow
{
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

- (void)leftButtonPressed;
{
    RIProduct *product = [self getProductFromIndex:self.picker.tag];
    if (VALID_NOTEMPTY(product.sizeGuideUrl, NSString)) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:product.sizeGuideUrl, @"sizeGuideUrl", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSizeGuideNotification object:nil userInfo:dic];
        [self closePicker];
    }
}

@end
