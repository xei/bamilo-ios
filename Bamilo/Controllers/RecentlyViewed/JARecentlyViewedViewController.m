//
//  JARecentlyViewedViewController.m
//  Jumia
//
//  Created by Jose Mota on 21/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JARecentlyViewedViewController.h"
#import "JAProductCollectionViewFlowLayout.h"
#import "JARecentlyViewedCell.h"
#import "RIProductSimple.h"
#import "RICategory.h"
#import "JAPicker.h"
#import "JAUtils.h"
#import "RICart.h"
#import "Bamilo-Swift.h"

@interface JARecentlyViewedViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, JAPickerDelegate, DataServiceProtocol>

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
@property (strong, nonatomic) RICart *cart;

@end

@implementation JARecentlyViewedViewController

- (void)setProductsDictionary:(NSMutableDictionary *)productsDictionary {
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
        _emptyListView = [[UIView alloc]initWithFrame:[self viewBounds]];
        [_emptyListView setBackgroundColor:[UIColor whiteColor]];
        [_emptyListView addSubview:self.emptyTitleLabel];
        [_emptyListView addSubview:self.emptyListImageView];
        [_emptyListView addSubview:self.emptyListLabel];
        [self.emptyListView setHidden:YES];
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
        [_emptyTitleLabel setFrame:CGRectMake((self.viewBounds.size.width - _emptyTitleLabel.width)/2, 48.f, _emptyTitleLabel.width, _emptyTitleLabel.height)];
    }
    return _emptyTitleLabel;
}

- (UIImageView *)emptyListImageView {
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

- (UILabel *)emptyListLabel {
    if (!VALID_NOTEMPTY(_emptyListLabel, UILabel)) {
        _emptyListLabel = [UILabel new];
        _emptyListLabel.font = JABodyFont;
        _emptyListLabel.textColor = JABlack800Color;
        _emptyListLabel.text = STRING_NO_RECENTLY_VIEWED_PRODUCTS;
        [_emptyListLabel sizeToFit];
        [_emptyListLabel setFrame:CGRectMake((self.viewBounds.size.width - _emptyListLabel.width)/2,
                                             CGRectGetMaxY(self.emptyListImageView.frame) + 28,
                                             _emptyListLabel.width, _emptyListLabel.height)];
    }
    return _emptyListLabel;
}

- (JAProductCollectionViewFlowLayout *)flowLayout {
    if (!VALID_NOTEMPTY(_flowLayout, JAProductCollectionViewFlowLayout)) {
        
        _flowLayout = [[JAProductCollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 1.0f;
        _flowLayout.minimumInteritemSpacing = 0.f;
        [_flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"horizontalSeparator"];
        [_flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"verticalSeparator"];
        
        //top, left, bottom, right
        [self.flowLayout setSectionInset:UIEdgeInsetsMake(0.f, 0.0, 0.0, 0.0)];
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    CGRect frame = self.viewBounds;
    frame.size.height -= 48.f;
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

- (UIView *)bottomView {
    if (!VALID(_bottomView, UIView)) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.viewBounds.size.height , self.viewBounds.size.width, 1.f)];
        [_bottomView setBackgroundColor:JABlack700Color];
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)clearAllButton {
    if (!_clearAllButton) {
        _clearAllButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_clearAllButton setFrame:CGRectMake(0, self.viewBounds.size.height - 48.f, self.viewBounds.size.width, 48.f)];
        [_clearAllButton setBackgroundColor:[UIColor whiteColor]];
        [_clearAllButton setTitle:STRING_CLEAR_ALL forState:UIControlStateNormal];
        [_clearAllButton.titleLabel setFont:JAListFont];
        [_clearAllButton addTarget:self action:@selector(clearAllButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_clearAllButton];
    }
    return _clearAllButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    [self.collectionView registerClass:[JARecentlyViewedCell class] forCellWithReuseIdentifier:@"CellWithLines"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadProducts];
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

- (void)onOrientationChanged {
    if(self.picker) {
        [self closePicker];
    }
}

#pragma mark - Load Data
- (void)loadProducts {
    [self showLoading];
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        if (recentlyViewedProducts.count > 0) {
            NSMutableArray* skus = [NSMutableArray new];
            for (RIProduct* product in recentlyViewedProducts) {
                [skus addObject:product.sku];
            }
            self.productsArray = [NSMutableArray new];
            NSMutableDictionary *temp = [NSMutableDictionary new];
            for (RIProduct *product in recentlyViewedProducts) {
                [self.productsArray addObject:product.sku];
                [temp setObject:product forKey:product.sku];
            }
            self.productsDictionary = [temp mutableCopy];
            self.chosenSimples = [NSMutableDictionary new];
            [self.collectionView reloadData];
            [self publishScreenLoadTimeWithName:[self getScreenName] withLabel:@""];
        } else {
            self.productsDictionary = nil;
        }
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        [self publishScreenLoadTimeWithName:[self getScreenName] withLabel:@""];
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadProducts) objects:nil];
        [self hideLoading];
    }];
}

- (RIProduct *)getProductFromIndex:(NSInteger)index {
    NSString *sku = [self.productsArray objectAtIndex:index];
    if (VALID_NOTEMPTY(sku, NSString)) {
        return [self.productsDictionary objectForKey:sku];
    }
    return nil;
}

#pragma mark - collectionView methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
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
        [cell.sizeButton addTarget:self action:@selector(sizeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.sizeButton setHidden:YES];
    }
    
    [cell.favoriteButton setHidden:YES];
    [cell setTag:indexPath.row];
    [cell.feedbackView addTarget:self action:@selector(clickableViewPressedInCell:) forControlEvents:UIControlEventTouchUpInside];
    [cell.addToCartButton addTarget:self action:@selector(addToCartButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.productsDictionary.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)clickableViewPressedInCell:(UIButton *)button {
    RIProduct *product = [self getProductFromIndex:button.tag];
    
    //track tapping this teaser here
    [TrackerManager postEventWithSelector:[EventSelectors itemTappedSelector] attributes:[EventAttributes itemTappedWithCategoryEvent:[self getScreenName] screenName:[self getScreenName] labelEvent:product.name]];
    
    //track behaviour journey from here
    [[MainTabBarViewController topNavigationController] openScreenTarget:[RITarget getTarget:PRODUCT_DETAIL node:product.sku] purchaseInfo:[BehaviourTrackingInfo trackingInfoWithCategory:[self getScreenName] label:product.name] currentScreenName:[self getScreenName]];
}

- (void)addToCartButtonPressed:(UIButton *)button {
    self.backupButton = button;
    [self finishAddToCartWithButton:button];
}

- (void)finishAddToCartWithButton:(UIButton *)button {
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
    
    [DataAggregator addProductToCart:self simpleSku:productSimple.sku completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            
            //EVENT: ADD TO CART
            Product *convertedProduct = [Product new];
            convertedProduct.sku = product.sku;
            [convertedProduct setPriceWithPrice:product.price];
            
            [TrackerManager postEventWithSelector:[EventSelectors addToCartEventSelector]
                                       attributes:[EventAttributes addToCartWithProduct:convertedProduct screenName:[self getScreenName] success:YES]];
            
            [RIRecentlyViewedProductSku removeFromRecentlyViewed:product];
            
            //Track add to cart behaviour
            [[PurchaseBehaviourRecorder sharedInstance] recordAddToCartWithSku:product.sku trackingInfo: [BehaviourTrackingInfo trackingInfoWithCategory:[self getScreenName] label:product.name]];
            
            [self loadProducts];
            
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.cart forKey:kUpdateCartNotificationValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
            
            [self onSuccessResponse:RIApiResponseSuccess messages:[self extractSuccessMessages:[data objectForKey:kDataMessages]] showMessage:YES];
            //[self hideLoading];
        } else {
            //EVENT: ADD TO CART
            
            Product *convertedProduct = [Product new];
            convertedProduct.sku = product.sku;
            [convertedProduct setPriceWithPrice:product.price];
            [TrackerManager postEventWithSelector:[EventSelectors addToCartEventSelector]
                                       attributes:[EventAttributes addToCartWithProduct:convertedProduct screenName:[self getScreenName] success:NO]];
            
            [self onErrorResponse:error.code messages:[error.userInfo objectForKey:kErrorMessages] showAsMessage:YES selector:@selector(finishAddToCartWithButton:) objects:@[button]];
        }
    }];
}

- (void)clearAllButtonPressed
{
    [RIRecentlyViewedProductSku removeAllRecentlyViewedProductSkus];
    self.productsDictionary = nil;
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
-(void)selectedRow:(NSInteger)selectedRow {
    RIProduct *product = [self getProductFromIndex:self.picker.tag];
    if (selectedRow < self.pickerDataSource.count) {
        RIProductSimple* selectedSimple = [self.pickerDataSource objectAtIndex:selectedRow];
        [self.chosenSimples setObject:selectedSimple forKey:product.sku];
        [self closePicker];
        [self.collectionView reloadData];
        if (self.selectedSizeAndAddToCart) {
            self.selectedSizeAndAddToCart = NO;
            [self addToCartButtonPressed:self.backupButton];
        }
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

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"RecentlyViewed";
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0:
            self.cart = [data objectForKey:kDataContent];
        break;
            
        default:
            break;
    }
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_RECENTLY_VIEWED_TITLE;
}

@end
