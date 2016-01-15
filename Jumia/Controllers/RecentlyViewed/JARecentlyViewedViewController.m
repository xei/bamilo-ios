//
//  JARecentlyViewedViewController.m
//  Jumia
//
//  Created by Jose Mota on 21/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JARecentlyViewedViewController.h"
#import "JAProductCollectionViewFlowLayout.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "JARecentlyViewedCell.h"
#import "RIProductSimple.h"
#import "RICategory.h"
#import "RICustomer.h"
#import "JAPicker.h"
#import "JAUtils.h"
#import "RICart.h"

@interface JARecentlyViewedViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JAPickerDelegate>

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
@property (strong, nonatomic) UIButton *clearAllButton;

@end

@implementation JARecentlyViewedViewController

- (void)setProductsDictionary:(NSMutableDictionary *)productsDictionary
{
    _productsDictionary = productsDictionary;
    [self.collectionView reloadData];
    if (ISEMPTY(productsDictionary)) {
        self.emptyListView.hidden = NO;
        self.collectionView.hidden = YES;
        [self.bottomView setHidden:YES];
        [self.clearAllButton setHidden:YES];
    } else {
        self.emptyListView.hidden = YES;
        self.collectionView.hidden = NO;
        [self.bottomView setHidden:NO];
        [self.clearAllButton setHidden:NO];
    }
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
        [_emptyTitleLabel setText:STRING_NO_RECENTLY_VIEWED_PRODUCTS_TITLE];
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
        UIImage * img = [UIImage imageNamed:@"emptyRecentlyViewedIcon"];
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
        _emptyListLabel.text = STRING_NO_RECENTLY_VIEWED_PRODUCTS;
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
    CGRect frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.viewBounds.size.height - self.bottomView.height-self.clearAllButton.height);
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

- (UIButton *)clearAllButton
{
    if (!VALID(_clearAllButton, UIButton)) {
        _clearAllButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_clearAllButton setFrame:CGRectMake(0, self.viewBounds.size.height - 48.f, self.viewBounds.size.width, 48.f)];
        [_clearAllButton setBackgroundColor:[UIColor whiteColor]];
        [_clearAllButton setTitle:STRING_CLEAR_ALL forState:UIControlStateNormal];
        [_clearAllButton addTarget:self action:@selector(clearAllButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_clearAllButton];
    }
    return _clearAllButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.navBarLayout.showBackButton = YES;
    [self.collectionView registerClass:[JARecentlyViewedCell class] forCellWithReuseIdentifier:@"CellWithLines"];
    self.navBarLayout.title = STRING_RECENTLY_VIEWED;
    
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
    [self.clearAllButton setWidth:self.viewBounds.size.width];
    [self.clearAllButton setYBottomAligned:0.f];
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
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        
        if (recentlyViewedProducts.count > 0) {
            NSMutableArray* skus = [NSMutableArray new];
            for (RIProduct* product in recentlyViewedProducts) {
                [skus addObject:product.sku];
            }
            
            [RIProduct getUpdatedProductsWithSkus:skus successBlock:^(NSArray *products) {
                
                [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                [self hideLoading];
                
                self.productsArray = [NSMutableArray new];
                NSMutableDictionary *temp = [NSMutableDictionary new];
                for (RIProduct *product in products) {
                    [self.productsArray addObject:product.sku];
                    [temp setObject:product forKey:product.sku];
                }
                self.productsDictionary = [temp mutableCopy];
                
                self.chosenSimples = [NSMutableDictionary new];
                
                [self.collectionView reloadData];
                
                if(self.firstLoading)
                {
                    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                    self.firstLoading = NO;
                }
                
            } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
                
                if(self.firstLoading)
                {
                    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                    self.firstLoading = NO;
                }
                
                [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadProducts) objects:nil];
                [self hideLoading];
            }];
        } else {
            [self hideLoading];
            self.productsDictionary = nil;
        }
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadProducts) objects:nil];
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

#pragma mark - kProductChangedNotification

- (void)updatedProduct:(NSNotification *)notification
{
    __block NSString *sku = notification.object;
    [RIProduct getCompleteProductWithSku:sku successBlock:^(id product) {
        if (![self.productsArray containsObject:sku]) {
            [self.productsArray addObject:sku];
        }
        [self.productsDictionary setObject:product forKey:sku];
        
        [RIProduct updateRecentlyViewedProduct:product withSku:sku];
        
        [self.collectionView reloadData];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        
        [self hideLoading];
        if (RIApiResponseMaintenancePage == apiResponse || RIApiResponseKickoutView == apiResponse)
        {
            [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(updatedProduct:) objects:@[notification]];
        }
    }];
}

#pragma mark - collectionView methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIProduct *product = [self getProductFromIndex:indexPath.row];
    
    JARecentlyViewedCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellWithLines" forIndexPath:indexPath];
    [cell setHideRating:YES];
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
    
    [cell.favoriteButton setHidden:YES];
    [cell setTag:indexPath.row];
    [cell.feedbackView addTarget:self
                          action:@selector(clickableViewPressedInCell:)
                forControlEvents:UIControlEventTouchUpInside];
    [cell.addToCartButton addTarget:self action:@selector(addToCartButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productsDictionary.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeZero;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        size = CGSizeMake((self.bounds.size.width/2)-1, 154.5f);
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
    [self finishAddToCartWithButton:button];
}

- (void)finishAddToCartWithButton:(UIButton *)button
{
    RIProduct *product = [self getProductFromIndex:button.tag];
    
    RIProductSimple* productSimple;
    
    if (1 == product.productSimples.count) {
        productSimple = [product.productSimples firstObject];
    } else {
        RIProductSimple* simple = [self.chosenSimples objectForKey:product.sku];
        if (!VALID_NOTEMPTY(simple, RIProductSimple)) {
            //NOTHING SELECTED
            
            self.selectedSizeAndAddToCart = YES;
            [self sizeButtonPressed:button];
            
            return;
        } else {
            productSimple = simple;
            
        }
    }
    
    [self showLoading];
    [RICart addProductWithQuantity:@"1"
                         simpleSku:productSimple.sku
                  withSuccessBlock:^(RICart *cart, RIApiResponse apiResponse, NSArray *successMessage){
                      
                      NSNumber *price = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f) ? product.specialPriceEuroConverted : product.priceEuroConverted;
                      
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
                      
                      // Since we're sending the converted price, we have to send the currency as EUR.
                      // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
                      [trackingDictionary setValue:price forKey:kRIEventPriceKey];
                      [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
                      
                      [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
                      [trackingDictionary setValue:product.name forKey:kRIEventProductNameKey];
                      
                      if(VALID_NOTEMPTY(product.categoryIds, NSOrderedSet))
                      {
                          NSArray *categoryIds = [product.categoryIds array];
                          NSInteger subCategoryIndex = [categoryIds count] - 1;
                          NSInteger categoryIndex = subCategoryIndex - 1;
                          
                          if(categoryIndex >= 0)
                          {
                              NSString *categoryId = [categoryIds objectAtIndex:categoryIndex];
                              [trackingDictionary setValue:[RICategory getCategoryName:categoryId] forKey:kRIEventCategoryNameKey];
                              
                              NSString *subCategoryId = [categoryIds objectAtIndex:subCategoryIndex];
                              [trackingDictionary setValue:[RICategory getCategoryName:subCategoryId] forKey:kRIEventSubCategoryNameKey];
                          }
                          else
                          {
                              NSString *categoryId = [categoryIds objectAtIndex:subCategoryIndex];
                              [trackingDictionary setValue:[RICategory getCategoryName:categoryId] forKey:kRIEventCategoryNameKey];
                          }
                      }
                      
                      [trackingDictionary setValue:product.brand forKey:kRIEventBrandKey];
                      
                      NSString *discountPercentage = @"0";
                      if(VALID_NOTEMPTY(product.maxSavingPercentage, NSString))
                      {
                          discountPercentage = product.maxSavingPercentage;
                      }
                      [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
                      [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
                      [trackingDictionary setValue:@"1" forKey:kRIEventQuantityKey];
                      [trackingDictionary setValue:@"Recently Viewed" forKey:kRIEventLocationKey];
                      
                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart]
                                                                data:[trackingDictionary copy]];
                      
                      
                      NSMutableDictionary *tracking = [NSMutableDictionary new];
                      [tracking setValue:product.name forKey:kRIEventProductNameKey];
                      [tracking setValue:product.sku forKey:kRIEventSkuKey];
                      if(VALID_NOTEMPTY(product.categoryIds, NSOrderedSet)) {
                          [tracking setValue:[product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
                      }
                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastAddedToCart] data:tracking];
                      
                      tracking = [NSMutableDictionary new];
                      [tracking setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                      [tracking setValue:cart.cartCount forKey:kRIEventQuantityKey];
                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                                data:[tracking copy]];
                      
                      float value = [price floatValue];
                      [FBSDKAppEvents logEvent:FBSDKAppEventNameAddedToCart
                                    valueToSum:value
                                    parameters:@{ FBSDKAppEventParameterNameCurrency    : @"EUR",
                                                  FBSDKAppEventParameterNameContentType : product.name,
                                                  FBSDKAppEventParameterNameContentID   : product.sku}];
                      
                      [RIProduct removeFromRecentlyViewed:product];
                      
                      [self loadProducts];
                      
                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      
                      [self onSuccessResponse:RIApiResponseSuccess messages:successMessage showMessage:YES];
                      [self hideLoading];
                      
                  } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                      
                      [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:nil objects:nil];
                      [self hideLoading];
                  }];
}

- (void)clearAllButtonPressed
{
    [self showLoading];
    [RIProduct removeAllRecentlyViewedWithSuccessBlock:^{
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [self hideLoading];
        self.productsDictionary = nil;
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:nil objects:nil];
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

#pragma mark JAPickerDelegate
-(void)selectedRow:(NSInteger)selectedRow
{
    RIProduct *product = [self getProductFromIndex:self.picker.tag];
    
    RIProductSimple* selectedSimple = [self.pickerDataSource objectAtIndex:selectedRow];
    
    [self.chosenSimples setObject:selectedSimple forKey:product.sku];
    
    [self closePicker];
    [self.collectionView reloadData];
    
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
    }
}

@end
