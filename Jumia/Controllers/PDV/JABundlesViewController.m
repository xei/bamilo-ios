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
#import "JAProductCollectionViewFlowLayout.h"

#import <FBSDKCoreKit/FBSDKAppEvents.h>

typedef void (^ProcessBundleChangesBlock)(NSMutableDictionary *);

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
@property (nonatomic) JAProductInfoSubLine *totalSubLine;
@property (nonatomic) JAPicker *picker;

@property (nonatomic) NSMutableDictionary* sizeButtonDictionary;
@property (nonatomic) CGRect selectButtonFrame;
@property (nonatomic) JAProductCollectionViewFlowLayout *flowLayout;

@end

@implementation JABundlesViewController

@synthesize bundles = _bundles, totalSubLine = _totalSubLine, selectButtonFrame = _selectButtonFrame;

- (NSArray *)bundles
{
    if (!VALID_NOTEMPTY(_bundles, NSArray)) {
        _bundles = [NSArray new];
    }
    return _bundles;
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

- (void)setBundles:(NSArray *)bundles
{
    _bundles = [bundles copy];
}

- (void)setSelectedItems:(NSMutableDictionary *)selectedItems
{
    _selectedItems = selectedItems;
}

- (UICollectionView *)collectionView
{
    CGRect frame = self.view.bounds;
    frame.size.height-=kBottomDefaultHeight;
    frame.size.height-=kProductInfoSubLineHeight;
    if (!VALID_NOTEMPTY(_collectionView, UICollectionView)) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.height -= 64;
        _collectionView.height -= self.bottomBar.height;
        _collectionView.height -= self.totalSubLine.height;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    else {
        if (!CGRectEqualToRect(frame, _collectionView.frame)) {
            [_collectionView setFrame:frame];
            [_collectionView reloadData];
        }
    }
    return _collectionView;
}

- (JABottomBar *)bottomBar
{
    CGRect frame = CGRectMake(0, CGRectGetMaxY(_collectionView.frame) + kBottomDefaultHeight, self.view.width, kBottomDefaultHeight);
    if ([self isLandscape]) {
        frame.origin.x = self.view.width/2;
        frame.size.width = self.view.width/2;
    }
    if (!VALID_NOTEMPTY(_bottomBar, JABottomBar)) {
        _bottomBar = [[JABottomBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame) - kBottomDefaultHeight, self.view.width, kBottomDefaultHeight)];
        [_bottomBar setBackgroundColor:[UIColor whiteColor]];
        [_bottomBar addButton:@"Buy Combo" target:self action:@selector(addComboToCart)];
        [self.view addSubview:_bottomBar];
    }
    else {
        if (!CGRectEqualToRect(frame, _bottomBar.frame)) {
            [_bottomBar setFrame:frame];
        }
    }
    
    if( RI_IS_RTL && [self isLandscape])
    {
        [_bottomBar flipViewPositionInsideSuperview];
    }
    return _bottomBar;
}

- (JAProductInfoSubLine *)totalSubLine
{
    CGRect frame = CGRectMake(0, CGRectGetMaxY(_collectionView.frame), self.view.width, kProductInfoSubLineHeight);
    if ([self isLandscape]) {
        frame.origin.y = self.view.height - frame.size.height;
        frame.size.width = self.view.width/2;
    }
    if (!VALID_NOTEMPTY(_totalSubLine, JAProductInfoSubLine)) {
        _totalSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame) - kProductInfoSubLineHeight, self.view.width, kProductInfoSubLineHeight)];
        [_totalSubLine setTopSeparatorVisibility:YES];
        [self.view addSubview:_totalSubLine];
    }
    else {
        if (!CGRectEqualToRect(frame, _totalSubLine.frame)) {
            [_totalSubLine setFrame:frame];
        }
    }
    
    if( RI_IS_RTL && [self isLandscape])
    {
        [_totalSubLine flipViewPositionInsideSuperview];
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

#pragma mark - viewcontroller events

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.title = STRING_COMBOS;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.collectionView registerClass:[JACatalogListCollectionViewCell class] forCellWithReuseIdentifier:@"CellWithLines"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self reloadPrice];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self collectionView];
    [self totalSubLine];
    [self bottomBar];
}

- (BOOL)isLandscape
{
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - collectionView methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIProduct *bundleProduct = [self.bundles objectAtIndex:indexPath.row];
    
    JACatalogListCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellWithLines" forIndexPath:indexPath];
    [cell setShowSelector:YES];
    [cell setHideRating:YES];
    [cell setHideShopFirstLogo:YES];
    [cell loadWithProduct:bundleProduct];
    
    if (![self.product.sku isEqualToString:bundleProduct.sku]) {
        [cell.selectorButton addTarget:self action:@selector(itemSelection:) forControlEvents:UIControlEventTouchUpInside ];
    }else{
        [cell.selectorButton removeTarget:self action:@selector(itemSelection:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [cell.selectorButton setSelected:[self.selectedItems objectForKey:bundleProduct.sku]?YES:NO];
    
    [cell setTag:indexPath.row];
    
    [cell.feedbackView addTarget:self
                          action:@selector(clickableViewPressedInCell:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [cell.sizeButton addTarget:self
                    action:@selector(sizeButtonPressed:)
          forControlEvents:UIControlEventTouchUpInside];
    
    if ([bundleProduct.productSimples count] > 1) {
        
        if (VALID_NOTEMPTY(cell.sizeButton, UIButton) && [self.selectedItems objectForKey:bundleProduct.sku]) {
            [cell.sizeButton.titleLabel sizeToFit];
            [self setCellSizeLabel:bundleProduct inCell:cell];
            
            [cell.sizeButton setHidden:NO];
            
        } else {
            [cell.sizeButton setHidden:YES];
            
        }
    } else {
        [cell.sizeButton setHidden:YES];
    }

    return cell;
}

- (void)setCellSizeLabel:(RIProduct*)bundleProduct inCell:(JACatalogCollectionViewCell*)cell{
    if ([self.selectedItems objectForKey:bundleProduct.sku]) {
        RIProductSimple* pds = [self.selectedItems objectForKey:bundleProduct.sku];
        [cell.sizeButton setTitle:[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, pds.variation]
                         forState:UIControlStateNormal];
        
        if (VALID_NOTEMPTY(pds.specialPriceFormatted, NSString)) {
            [cell setSimplePrice:pds.specialPriceFormatted andOldPrice:pds.priceFormatted];
        }else{
            [cell setSimplePrice:pds.priceFormatted andOldPrice:nil];
        }
        
    } else {
        RIProductSimple* simp = [bundleProduct.productSimples firstObject];
        [self.selectedItems setObject:simp forKey:bundleProduct.sku];
        [self setCellSizeLabel:bundleProduct inCell:cell];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bundles.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIDeviceOrientationPortrait == ([UIDevice currentDevice].orientation) || UIDeviceOrientationPortraitUpsideDown == ([UIDevice currentDevice].orientation)) {
            size = CGSizeMake(self.bounds.size.width, JACatalogViewControllerListCellHeight_ipad);
            
        } else {
            size = CGSizeMake((self.bounds.size.width/2), JACatalogViewControllerListCellHeight_ipad);
        }
    } else {
        size = CGSizeMake(self.view.frame.size.width, JACatalogViewControllerListCellHeight);
    }
    
    self.flowLayout.itemSize = size;
    
    return size;
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
    
    if ([bundleProduct.sku isEqualToString:self.product.sku]) {
        return;
    }
    if ([self.selectedItems objectForKey:bundleProduct.sku]) {
        [control setSelected:NO];
        [self.selectedItems removeObjectForKey:bundleProduct.sku];
    }else{
        [control setSelected:YES];
        [self.selectedItems setValue:[bundleProduct.productSimples firstObject] forKey:bundleProduct.sku];
    }
    [self reloadPrice];
    if (changesBlock) {
        changesBlock(self.selectedItems);
    }
}

- (void)setProduct:(RIProduct *)product
{
    _product = product;
}

- (void)addComboToCart
{
    [self showLoading];
    
    NSMutableArray* simpleSku = [NSMutableArray new];
    for (RIProductSimple *simple in [self.selectedItems allValues]) {
        [simpleSku addObject:simple.sku];
    }
    
    [RICart addBundleProductsWithSimpleSkus:simpleSku bundleId:self.bundle.bundleId withSuccessBlock:^(RICart *cart, NSArray *productsNotAdded) {
        
        [self hideLoading];
        
        [self trackingEventAddBundleToCart:cart];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
        
        [self onSuccessResponse:RIApiResponseSuccess messages:@[STRING_ITEM_WAS_ADDED_TO_CART] showMessage:YES];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages, BOOL outOfStock) {
        [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:@selector(addComboToCart) objects:nil];
        [self hideLoading];
    }];
}

- (void)sizeButtonPressed:(UIButton*)button {
    
    RIProduct* prod = [self.bundles objectAtIndex:button.tag];
    _pickerSku = prod.sku;
    [self openPickerForProduct:prod];
}

- (void)reloadPrice
{
    NSInteger totalPrice = 0;
    
    for (RIProductSimple* bundleSimple in [self.selectedItems allValues]) {
        if (VALID_NOTEMPTY(bundleSimple.specialPriceFormatted, NSString))
            totalPrice += bundleSimple.specialPrice.integerValue;
        else
            totalPrice += bundleSimple.price.integerValue;
    }
    [self.totalSubLine setTitle:[NSString stringWithFormat:@"%@: %@",STRING_TOTAL, [RICountryConfiguration formatPrice:[NSNumber numberWithInteger:totalPrice] country:[RICountryConfiguration getCurrentConfiguration]]]];
    [self.totalSubLine.label sizeToFit];
    [self.totalSubLine.label setYCenterAligned];
}

- (void)onBundleSelectionChanged:(void(^)(NSMutableDictionary *selectedSkus))changes
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
    NSMutableArray *simples =[NSMutableArray new];
    for (RIProductSimple *simple in product.productSimples) {
        if ([simple.quantity integerValue] > 0)
        {
            [sizes addObject:simple.variation];
            [simples addObject:simple];
        }
    }
    _pickerDataSource = [simples copy];
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
    [self.selectedItems setObject:simple forKey:_pickerSku];
    
    changesBlock(self.selectedItems);
    
    [self closePicker];
    [self.collectionView reloadData];
    [self reloadPrice];
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

- (void)leftButtonPressed
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
    
    if(VALID_NOTEMPTY(self.product.categoryIds, NSArray))
    {
        NSArray *categoryIds = self.product.categoryIds;
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
    if(VALID_NOTEMPTY(self.product.categoryIds, NSArray)) {
        [tracking setValue:[self.product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
    }
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastAddedToCart] data:tracking];
}

@end
