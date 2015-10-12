//
//  JAPDVVariationsViewController.m
//  Jumia
//
//  Created by josemota on 10/5/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JABundlesViewController.h"
#import "JACatalogListCollectionViewCell.h"
#import "JABottomBar.h"
#import "JAProductInfoSubLine.h"
#import "RICart.h"
#import "JAPicker.h"
#import "RIProductSimple.h"
#import "JAUtils.h"
#import "RICustomer.h"

#import <FBSDKCoreKit/FBSDKAppEvents.h>

typedef void (^ProcessBundleChangesBlock)(NSArray *);

@interface JABundlesViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JAPickerDelegate>
{
    id _buyBundlesTarget;
    SEL _buybundlesSelector;
    ProcessBundleChangesBlock changesBlock;
    NSString *_pickerSku;
    NSArray *_pickerDataSource;
    BOOL _pickerInProcess;
}

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) JABottomBar *bottomBar;
@property (nonatomic) NSMutableDictionary *selectedItemsDictionary;
@property (nonatomic) JAProductInfoSubLine *totalSubLine;
@property (nonatomic) JAPicker *picker;
@property (nonatomic) NSMutableDictionary *sizesSelection;

@end

@implementation JABundlesViewController

@synthesize bundles = _bundles, totalSubLine = _totalSubLine;

- (NSArray *)bundles
{
    if (!VALID_NOTEMPTY(_bundles, NSArray)) {
        _bundles = [NSArray new];
    }
    return _bundles;
}

- (void)setBundles:(NSArray *)bundles
{
    _bundles = [bundles copy];
    for (RIProduct *product in _bundles) {
        [self.selectedItemsDictionary setValue:product forKey:product.sku];
    }
}

- (void)setSelectedItems:(NSMutableArray *)selectedItems
{
    _selectedItems = selectedItems;
    for (NSString *itemSkuFromDict in [self.selectedItemsDictionary allKeys]) {
        BOOL isSelected = NO;
        for (NSString *sku in _selectedItems) {
            if ([sku isEqualToString:itemSkuFromDict]) {
                isSelected = YES;
                break;
            }
        }
        if (!isSelected) {
            [self.selectedItemsDictionary removeObjectForKey:itemSkuFromDict];
        }
        
    }
}

- (UICollectionView *)collectionView
{
    if (!VALID_NOTEMPTY(_collectionView, UICollectionView)) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.viewBounds collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.height -= 64;
        _collectionView.height -= self.bottomBar.height;
        _collectionView.height -= self.totalSubLine.height;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (JABottomBar *)bottomBar
{
    if (!VALID_NOTEMPTY(_bottomBar, JABottomBar)) {
        _bottomBar = [[JABottomBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame) - kBottomDefaultHeight, self.view.width, kBottomDefaultHeight)];
        [_bottomBar addButton:@"Buy Combo" target:self action:@selector(addComboToCart)];
        [self.view addSubview:_bottomBar];
    }
    return _bottomBar;
}

- (NSMutableDictionary *)selectedItemsDictionary
{
    if (!VALID_NOTEMPTY(_selectedItemsDictionary, NSMutableDictionary)) {
        _selectedItemsDictionary = [NSMutableDictionary new];
    }
    return _selectedItemsDictionary;
}

- (JAProductInfoSubLine *)totalSubLine
{
    if (!VALID_NOTEMPTY(_totalSubLine, JAProductInfoSubLine)) {
        _totalSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame) - kProductInfoSubLineHeight, self.view.width, kProductInfoSubLineHeight)];
        [_totalSubLine setTopSeparatorVisibility:YES];
        [self.view addSubview:_totalSubLine];
    }
    return _totalSubLine;
}

- (JAPicker *)picker
{
    if (!VALID_NOTEMPTY(_picker, JAPicker)) {
        _picker = [JAPicker new];
    }
    return _picker;
}

- (NSMutableDictionary *)sizesSelection
{
    if (!VALID_NOTEMPTY(_sizesSelection, NSMutableDictionary)) {
        _sizesSelection = [NSMutableDictionary new];
    }
    return _sizesSelection;
}

#pragma mark - viewcontroller events

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navBarLayout.showBackButton = YES;
    
    [self.collectionView registerClass:[JACatalogListCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogListCollectionViewCell"];
    
    [self reloadPrice];
}

#pragma mark - collectionView methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIProduct *bundleProduct = [self.bundles objectAtIndex:indexPath.row];
    
    JACatalogCollectionViewCell *cell = (JACatalogCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogListCollectionViewCell" forIndexPath:indexPath];
    
    [cell loadWithProduct:bundleProduct];
    
    UIButton *select = [UIButton buttonWithType:UIButtonTypeCustom];
    [select setFrame:cell.favoriteButton.frame];
    select.tag = indexPath.row;
    [select setImage:[UIImage imageNamed:@"check_empty"] forState:UIControlStateNormal];
    [select setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    [select setImage:[UIImage imageNamed:@"check"] forState:UIControlStateHighlighted];
    [select setSelected:[self.selectedItemsDictionary objectForKey:bundleProduct.sku]?YES:NO];
    [cell addSubview:select];
    if (indexPath.row != 0) {
        [select addTarget:self action:@selector(itemSelection:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell.favoriteButton setHidden:YES];

    cell.feedbackView.tag = indexPath.row;
    [cell.feedbackView addTarget:self
                          action:@selector(clickableViewPressedInCell:)
                forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bundles.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.width, JACatalogViewControllerListCellHeight);
}

#pragma mark - actions

- (void)clickableViewPressedInCell:(UIControl *)control
{
    RIVariation *bundleProduct = [self.bundles objectAtIndex:control.tag];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"fromCatalog"];
    [userInfo setObject:self forKey:@"delegate"];
    if(VALID_NOTEMPTY(bundleProduct.sku, NSString))
    {
        [userInfo setObject:bundleProduct.sku forKey:@"sku"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)itemSelection:(UIControl *)control
{
    RIProduct *bundleProduct = [self.bundles objectAtIndex:control.tag];
    if ([self.selectedItemsDictionary objectForKey:bundleProduct.sku]) {
        [control setSelected:NO];
        [self.selectedItemsDictionary removeObjectForKey:bundleProduct.sku];
    }else{
        [control setSelected:YES];
        [self.selectedItemsDictionary setValue:bundleProduct forKey:bundleProduct.sku];
    }
    [self reloadPrice];
    if (changesBlock) {
        changesBlock([self.selectedItemsDictionary allKeys]);
    }
}

- (void)addComboToCart
{
    if (![self checkBundlesSizes]) {
        return;
    }
    [self showLoading];
    [RICart addBundleProductsWithSkus:[self.selectedItemsDictionary allKeys] simpleSkus:[self.sizesSelection allValues] bundleId:self.bundle.bundleId withSuccessBlock:^(RICart *cart, NSArray *productsNotAdded) {
        
        [self hideLoading];
        
        [self trackingEventAddBundleToCart:cart];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
        
        [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages, BOOL outOfStock) {
        
        [self hideLoading];
        
        NSString *addToCartError = STRING_ERROR_ADDING_TO_CART;
        if (RIApiResponseNoInternetConnection == apiResponse)
        {
            addToCartError = STRING_NO_CONNECTION;
        }
        
        [self showMessage:addToCartError success:NO];
    }];
}

- (BOOL)checkBundlesSizes
{
    for (RIProduct *product in [self.selectedItemsDictionary allValues])
    {
        if (product.productSimples.count > 1) {
            if (![self.sizesSelection objectForKey:product.sku]) {
                _pickerInProcess = YES;
                _pickerSku = product.sku;
                [self openPickerForProduct:product];
                return NO;
            }
        }else{
            [self.sizesSelection setValue:((RIProductSimple *)[product.productSimples firstObject]).sku forKey:product.sku];
        }
    }
    _pickerInProcess = NO;
    return YES;
}

- (void)reloadPrice
{
    NSInteger totalPrice = 0;
    for (RIProduct *product in [self.selectedItemsDictionary allValues]) {
        if (VALID_NOTEMPTY(product.specialPriceFormatted, NSString))
            totalPrice += product.specialPrice.integerValue;
        else
            totalPrice += product.price.integerValue;
    }
#warning TODO String
    [self.totalSubLine.label setText:[NSString stringWithFormat:@"Total:  %@", [RICountryConfiguration formatPrice:[NSNumber numberWithInteger:totalPrice] country:[RICountryConfiguration getCurrentConfiguration]]]];
    [self.totalSubLine.label sizeToFit];
    [self.totalSubLine.label setYCenterAligned];
}

- (void)onBundleSelectionChanged:(void(^)(NSArray *selectedSkus))changes
{
    changesBlock = changes;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - picker

- (void)openPickerForProduct:(RIProduct *)product
{
    NSMutableArray *sizes = [NSMutableArray new];
    for (RIProductSimple *simple in product.productSimples) {
        [sizes addObject:simple.variation];
    }
    _pickerDataSource = [product.productSimples array];
    [self loadSizePickerWithOptions:sizes title:product.name previousText:@"" leftButtonTitle:nil];
}

- (void)loadSizePickerWithOptions:(NSArray*)options
                            title:(NSString *)title
                     previousText:(NSString*)previousText
                  leftButtonTitle:(NSString*)leftButtonTitle
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    
    [self.picker setDataSourceArray:options
                        pickerTitle:title
                       previousText:previousText
                    leftButtonTitle:leftButtonTitle];
    
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

- (void)selectedRow:(NSInteger)selectedRow
{
    RIProductSimple *simple = [_pickerDataSource objectAtIndex:selectedRow];
    [self.sizesSelection setValue:simple.sku forKey:_pickerSku];
    [self closePicker];
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
                         if (_pickerInProcess) {
                             [self addComboToCart];
                         }
                     }];
}

- (void)leftButtonPressed;
{
    if (VALID_NOTEMPTY(self.product.sizeGuideUrl, NSString)) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.product.sizeGuideUrl, @"sizeGuideUrl", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSizeGuideNotification object:nil userInfo:dic];
    }
}

#pragma mark - tracking

- (NSNumber *)getPrice
{
    return (VALID_NOTEMPTY(self.product.specialPriceEuroConverted, NSNumber) && [self.product.specialPriceEuroConverted floatValue] > 0.0f)? self.product.specialPriceEuroConverted : self.product.priceEuroConverted;
}

- (void)trackingEventAddBundleToCart:(RICart *)cart
{
    NSNumber *price = [self getPrice];
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:((RIProduct *)[self.product.productSimples firstObject]).sku forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"BundleAddToCart" forKey:kRIEventActionKey];
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
    
    [trackingDictionary setValue:self.product.sku forKey:kRIEventSkuKey];
    [trackingDictionary setValue:self.product.name forKey:kRIEventProductNameKey];
    
    if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet))
    {
        NSArray *categoryIds = [self.product.categoryIds array];
        [trackingDictionary setValue:[categoryIds objectAtIndex:0] forKey:kRIEventCategoryIdKey];
    }
    
    [trackingDictionary setValue:self.product.brand forKey:kRIEventBrandKey];
    
    NSString *discountPercentage = @"0";
    if(VALID_NOTEMPTY(self.product.maxSavingPercentage, NSString))
    {
        discountPercentage = self.product.maxSavingPercentage;
    }
    [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
    [trackingDictionary setValue:self.product.avr forKey:kRIEventRatingKey];
    [trackingDictionary setValue:@"1" forKey:kRIEventQuantityKey];
    [trackingDictionary setValue:@"Product Detail screen" forKey:kRIEventLocationKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart]
                                              data:[trackingDictionary copy]];
    
    [self trackingEventCart:cart];
}

- (void)trackingEventCart:(RICart *)cart
{
    float value = [[self getPrice] floatValue];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameAddedToCart
                  valueToSum:value
                  parameters:@{ FBSDKAppEventParameterNameCurrency    : @"EUR",
                                FBSDKAppEventParameterNameContentType : self.product.name,
                                FBSDKAppEventParameterNameContentID   : self.product.sku}];
    
    NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
    [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
    [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                              data:[trackingDictionary copy]];
    
    [self trackingEventLastAddedToCart];
}

- (void)trackingEventLastAddedToCart
{
    NSMutableDictionary *tracking = [NSMutableDictionary new];
    [tracking setValue:self.product.name forKey:kRIEventProductNameKey];
    [tracking setValue:self.product.sku forKey:kRIEventSkuKey];
    if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet)) {
        [tracking setValue:[self.product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
    }
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastAddedToCart] data:tracking];
}

@end
