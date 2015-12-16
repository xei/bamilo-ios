//
//  JARecentlyViewedViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARecentlyViewedViewController.h"
#import "JACatalogListCell.h"
#import "JAButtonCell.h"
#import "RIProduct.h"
#import "RIProductSimple.h"
#import "RICart.h"
#import "JAUtils.h"
#import "RICustomer.h"
#import "JAProductListFlowLayout.h"
#import "RICategory.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>

@interface JARecentlyViewedViewController ()

@property (strong, nonatomic) UIView *emptyListView;
@property (strong, nonatomic) UILabel *emptyListLabel;
@property (strong, nonatomic) UIImageView* emptyListImageView;
@property (strong, nonatomic) UILabel *emptyTitleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong)JAProductListFlowLayout* flowLayout;
@property (nonatomic, strong)NSString* cellIdentifier;
@property (nonatomic, strong)NSString* buttonCellIdentifier;
@property (nonatomic, strong) NSArray* productsArray;
@property (assign, nonatomic) BOOL selectedSizeAndAddToCart;

// size picker view
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (nonatomic, strong) NSMutableDictionary* chosenSimples;

@property (strong, nonatomic) UIButton *backupButton; // for the retry connection, is necessary to store the button

@end

@implementation JARecentlyViewedViewController

- (void)setProductsArray:(NSArray *)productsArray
{
    _productsArray = productsArray;
    [self.collectionView reloadData];
    if (ISEMPTY(productsArray)) {
        self.emptyListView.hidden = NO;
        self.collectionView.hidden = YES;
    } else {
        self.emptyListView.hidden = YES;
        self.collectionView.hidden = NO;
    }
}


-(UIView *)emptyListView {
    if (!VALID_NOTEMPTY(_emptyListView, UIView)) {
        _emptyListView = [[UIView alloc]initWithFrame:CGRectMake(self.viewBounds.origin.x,
                                                                self.viewBounds.origin.y,
                                                                self.viewBounds.size.width,
                                                                 self.viewBounds.size.height)];
        [_emptyListView setBackgroundColor:[UIColor whiteColor]];
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
        [self.emptyListView addSubview:_emptyTitleLabel];
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
        [self.emptyListView addSubview:_emptyListImageView];
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
        [self.emptyListView addSubview:_emptyListLabel];
    }
    return _emptyListLabel;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"RecentlyViewed";
    
    self.selectedSizeAndAddToCart = NO;
    self.navBarLayout.title = STRING_RECENTLY_VIEWED;
    self.navBarLayout.showBackButton = YES;
    
    self.collectionView.backgroundColor = JABackgroundGrey;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JARecentlyViewedListCell" bundle:nil] forCellWithReuseIdentifier:@"recentlyViewedListCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JARecentlyViewedListCell_ipad_portrait" bundle:nil] forCellWithReuseIdentifier:@"recentlyViewedListCell_ipad_portrait"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JARecentlyViewedListCell_ipad_landscape" bundle:nil] forCellWithReuseIdentifier:@"recentlyViewedListCell_ipad_landscape"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAGrayButtonCell" bundle:nil] forCellWithReuseIdentifier:@"buttonCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAGrayButtonCell_ipad_portrait" bundle:nil] forCellWithReuseIdentifier:@"buttonCell_ipad_portrait"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAGrayButtonCell_ipad_landscape" bundle:nil] forCellWithReuseIdentifier:@"buttonCell_ipad_landscape"];
    
    self.flowLayout = [[JAProductListFlowLayout alloc] init];
    self.flowLayout.manualCellSpacing = 6.0f;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showLoading];
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        
        if (recentlyViewedProducts.count > 0) {
            NSMutableArray* skus = [NSMutableArray new];
            for (RIProduct* product in recentlyViewedProducts) {
                [skus addObject:product.sku];
            }
            
            [RIProduct getUpdatedProductsWithSkus:skus successBlock:^(NSArray *products) {
                
                [self hideLoading];
                self.productsArray = products;
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
                
                [self hideLoading];
                
                if (RIApiResponseMaintenancePage == apiResponse) {
                    [self showMaintenancePage:@selector(viewDidLoad) objects:nil];
                }
                else if(RIApiResponseKickoutView == apiResponse)
                {
                    [self showKickoutView:@selector(viewDidLoad) objects:nil];
                }
                
            }];
        } else {
            [self hideLoading];
            self.productsArray = nil;
        }
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        [self hideLoading];
    }];
    
    [self changeViewToInterfaceOrientation:self.interfaceOrientation];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"RecentlyViewed"];
}

-(void)viewWillLayoutSubviews {
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.picker removeFromSuperview];
    
    self.collectionView.frame = CGRectMake(6.0f,
                                           self.viewBounds.origin.y,
                                           self.viewBounds.size.width - 6.0f*2,
                                           self.viewBounds.size.height);
    
    [self.emptyListView setFrame:CGRectMake(self.viewBounds.origin.x,
                                            self.viewBounds.origin.y,
                                            self.viewBounds.size.width,
                                            self.viewBounds.size.height)];
    
    [self.emptyTitleLabel setFrame:CGRectMake((self.viewBounds.size.width - self.emptyTitleLabel.width)/2,
                                          48.f,
                                          self.emptyTitleLabel.width, self.emptyTitleLabel.height)];
    
    [self.emptyListImageView setFrame:CGRectMake((self.viewBounds.size.width - self.emptyListImageView.frame.size.width)/2,
                                             CGRectGetMaxY(self.emptyTitleLabel.frame) + 28.f,
                                             self.emptyListImageView.frame.size.width, self.emptyListImageView.frame.size.height)];
    
    [self.emptyListLabel setFrame:CGRectMake((self.viewBounds.size.width - self.emptyListLabel.width)/2,
                                         CGRectGetMaxY(self.emptyListImageView.frame) + 28,
                                         self.emptyListLabel.width, self.emptyListLabel.height)];
    
    [self changeViewToInterfaceOrientation:self.interfaceOrientation];
}

- (void)changeViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            self.cellIdentifier = @"recentlyViewedListCell_ipad_landscape";
            self.buttonCellIdentifier = @"buttonCell_ipad_landscape";
        } else {
            self.cellIdentifier = @"recentlyViewedListCell_ipad_portrait";
            self.buttonCellIdentifier = @"buttonCell_ipad_portrait";
        }
    } else {
        self.cellIdentifier = @"recentlyViewedListCell";
        self.buttonCellIdentifier = @"buttonCell";
    }
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productsArray.count + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.productsArray.count == indexPath.row) {
        return [self getButtonLayoutItemSizeForInterfaceOrientation:self.interfaceOrientation];
    } else {
        return [self getLayoutItemSizeForInterfaceOrientation:self.interfaceOrientation];
    }
}

- (CGSize)getLayoutItemSizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            width = 375.0f;
            height = JACatalogViewControllerListCellHeight_ipad;
        } else {
            width = 333.0f;
            height = JACatalogViewControllerListCellHeight_ipad;
        }
    } else {
        width = self.collectionView.frame.size.width;
        height = JACatalogViewControllerListCellHeight;
    }
    
    return CGSizeMake(width, height);
}

- (CGSize)getButtonLayoutItemSizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat width = 0.0f;
    CGFloat height = 55.0f;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            width = 756.0f;
        } else {
            width = 1012.0f;
        }
    } else {
        width = self.collectionView.frame.size.width;
    }
    
    return CGSizeMake(width, height);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.productsArray.count) {
        
        JAButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.buttonCellIdentifier forIndexPath:indexPath];
        
        [cell loadWithButtonName:STRING_CLEAR_RECENTLY_VIEWED];
        
        [cell.button addTarget:self
                        action:@selector(clearAllButtonPressed)
              forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
        
        JACatalogListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
        
        [cell loadWithProduct:product];
        cell.addToCartButton.tag = indexPath.row;
        [cell.addToCartButton addTarget:self
                                 action:@selector(addToCartPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
        
        RIProductSimple* chosenSimple = [self.chosenSimples objectForKey:product.sku];
        if (!VALID_NOTEMPTY(chosenSimple, RIProductSimple)) {
            [cell.sizeButton setTitle:STRING_SIZE forState:UIControlStateNormal];
        } else {
            [cell.priceView loadWithPrice:chosenSimple.priceFormatted
                             specialPrice:chosenSimple.specialPriceFormatted
                                 fontSize:10.f specialPriceOnTheLeft:YES];
            [cell.sizeButton setTitle:[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, chosenSimple.variation] forState:UIControlStateNormal];
        }
        
        cell.sizeButton.tag = indexPath.row;
        [cell.sizeButton addTarget:self
                            action:@selector(sizeButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
        
        cell.feedbackView.tag = indexPath.row;
        [cell.feedbackView addTarget:self
                              action:@selector(clickableViewPressedInCell:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (void)clickableViewPressedInCell:(UIControl*)sender
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.productsArray.count) {
        RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"sku" : product.sku,
                                                                      @"previousCategory" : STRING_RECENTLY_VIEWED,
                                                                      @"show_back_button" : [NSNumber numberWithBool:NO],
                                                                      @"fromCatalog" : [NSNumber numberWithBool:YES]}];
        [[RITrackingWrapper sharedInstance] trackScreenWithName:[NSString stringWithFormat:@"Catalog_%@",product.name]];
    }
}

#pragma mark - Button Actions

- (void)addToCartPressed:(UIButton*)button;
{
    self.backupButton = button;
    
    [self finishAddToCartWithButton:button];
}

- (void)finishAddToCartWithButton:(UIButton *)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    
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
                  withSuccessBlock:^(RICart *cart) {
                      
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
                      
                      [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
                          
                          self.productsArray = recentlyViewedProducts;
                          self.chosenSimples = [NSMutableDictionary new];
                          [self.collectionView reloadData];
                          
                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                          
                      }];
                      
                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      
                      [self hideLoading];
                      
                      [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                      
                  } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                      
                      [self hideLoading];
                      
                       NSString *errorAddToCart = STRING_ERROR_ADDING_TO_CART;
                      NSString *results = [[errorMessages valueForKey:@"description"] componentsJoinedByString:@""];
                      if([results  isEqualToString: @"order_product_sold_out"]){
                          
                          errorAddToCart = STRING_PRODCUTS_OUT_OF_STOCK;
                      }
                      
                      if (RIApiResponseNoInternetConnection == apiResponse)
                      {
                          errorAddToCart = STRING_NO_CONNECTION;
                      }
                      
                      [self showMessage:errorAddToCart success:NO];
                  }];
}

- (void)clearAllButtonPressed
{
    [self showLoading];
    [RIProduct removeAllRecentlyViewedWithSuccessBlock:^{
        [self hideLoading];
        self.productsArray = nil;
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        [self hideLoading];
    }];
}

- (void)sizeButtonPressed:(UIButton*)button
{
    self.backupButton = button;
    
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
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
    RIProduct* product = [self.productsArray objectAtIndex:self.picker.tag];
    
    RIProductSimple* selectedSimple = [self.pickerDataSource objectAtIndex:selectedRow];
    
    [self.chosenSimples setObject:selectedSimple forKey:product.sku];
    
    [self closePicker];
    [self.collectionView reloadData];
    
    if (self.selectedSizeAndAddToCart) {
        self.selectedSizeAndAddToCart = NO;
        
        [self addToCartPressed:self.backupButton];
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
    RIProduct* product = [self.productsArray objectAtIndex:self.picker.tag];
    if (VALID_NOTEMPTY(product.sizeGuideUrl, NSString)) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:product.sizeGuideUrl, @"sizeGuideUrl", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSizeGuideNotification object:nil userInfo:dic];
    }
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    RIProduct* product = [self.productsArray objectAtIndex:pickerView.tag];
    return product.productSimples.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    RIProduct* product = [self.productsArray objectAtIndex:pickerView.tag];
    RIProductSimple* simple = [product.productSimples objectAtIndex:row];
    NSString* simpleName = @"";
    if (VALID_NOTEMPTY(simple.variation, NSString)) {
        simpleName = simple.variation;
    }
    NSString *title = [NSString stringWithFormat:@"%@", simpleName];
    return title;
}


@end
