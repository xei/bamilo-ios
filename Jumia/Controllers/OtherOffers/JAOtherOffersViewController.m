//
//  JAOtherOffersViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 23/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAOtherOffersViewController.h"
#import "RIProductOffer.h"
#import "JAOfferCollectionViewCell.h"
#import "RICart.h"
#import "RICustomer.h"
#import "RISeller.h"
#import "RIProductSimple.h"
#import "JAUtils.h"
#import "JAProductListFlowLayout.h"
#import "JAPicker.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>

@interface JAOtherOffersViewController () <JAPickerDelegate>
{
    NSString *_pickerSku;
    NSArray *_pickerDataSource;
    BOOL _pickerInProcess;
}

@property (nonatomic, strong) UIView* topView;
@property (nonatomic, strong) UILabel* brandLabel;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UIView* separatorView;
@property (nonatomic, strong) UILabel* offersFromLabel;
@property (nonatomic, strong) UILabel* priceLabel;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) JAProductListFlowLayout* flowLayout;
@property (nonatomic, strong) NSString* cellIdentifier;
@property (nonatomic, strong) NSArray* productOffers;
@property (nonatomic, strong) NSMutableDictionary* selectedProductSimple;

@property (nonatomic) JAPicker *picker;

@end

@implementation JAOtherOffersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navBarLayout.showBackButton = YES;
    
    self.navBarLayout.title = STRING_OTHER_SELLERS;
    
    self.flowLayout = [JAProductListFlowLayout new];
    self.flowLayout.manualCellSpacing = 6.0f;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAOfferCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"offerCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadAllOffers];
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0f];
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadTopView];
}

- (void)loadTopView
{
    if (ISEMPTY(self.topView)) {
        self.topView = [UIView new];
        self.topView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.topView];
    }
    [self.topView setFrame:CGRectMake(0.0f,
                                      0.0f,
                                      self.view.frame.size.width,
                                      1)];
    
    CGFloat currentY = 10.0f;
    CGFloat horizontalMargin = 16.0f;
    
    if (ISEMPTY(self.brandLabel)) {
        self.brandLabel = [UILabel new];
        self.brandLabel.textColor = JABlackColor;
        self.brandLabel.font = JAList1Font;
        [self.topView addSubview:self.brandLabel];
    }
    self.brandLabel.text = self.product.brand;
    [self.brandLabel setFrame:CGRectMake(horizontalMargin,
                                         currentY,
                                         self.topView.frame.size.width - 2*horizontalMargin,
                                         1)];
    [self.brandLabel sizeToFit];
    
    currentY += self.brandLabel.frame.size.height;
    
    if (ISEMPTY(self.nameLabel)) {
        self.nameLabel = [UILabel new];
        self.nameLabel.textColor = JABlack800Color;
        self.nameLabel.font = JACaptionFont;
        self.nameLabel.numberOfLines = -1;
        [self.topView addSubview:self.nameLabel];
    }
    self.nameLabel.text = self.product.name;
    [self.nameLabel setFrame:CGRectMake(horizontalMargin,
                                        currentY,
                                        self.topView.frame.size.width - 2*horizontalMargin,
                                        1)];
    [self.nameLabel sizeToFit];

    
    currentY += self.nameLabel.frame.size.height + 15.0f;
    
    if (ISEMPTY(self.separatorView)) {
        self.separatorView = [UIView new];
        self.separatorView.backgroundColor = UIColorFromRGB(0xcccccc);
        [self.topView addSubview:self.separatorView];
    }
    self.separatorView.frame = CGRectMake(0.0f,
                                          currentY,
                                          self.topView.frame.size.width,
                                          1);

    currentY += self.separatorView.frame.size.height;
    
    [self.topView setFrame:CGRectMake(self.topView.frame.origin.x,
                                      self.topView.frame.origin.y,
                                      self.topView.frame.size.width,
                                      currentY)];
    
    //ADJUST COLLECTIONVIEW ACCORDINGLY
    
    [self.collectionView setFrame:CGRectMake(6.0f,
                                             CGRectGetMaxY(self.topView.frame),
                                             self.view.frame.size.width - 12.0f,
                                             [self viewBounds].size.height  - CGRectGetMaxY(self.topView.frame))];
    
    if (RI_IS_RTL) {
        [self.topView flipAllSubviews];
    }
}

- (void)readjustOffersFromLabel
{
    CGFloat lastWidth = self.offersFromLabel.width;
    self.offersFromLabel.text = [NSString stringWithFormat:STRING_NUMBER_OFFERS_FROM, self.productOffers.count];
    [self.offersFromLabel sizeToFit];
    CGFloat adjustment = self.offersFromLabel.width - lastWidth;
    
    if (RI_IS_RTL) {
        self.offersFromLabel.x -= adjustment;
        [self.priceLabel setFrame:CGRectMake(self.offersFromLabel.x - self.priceLabel.frame.size.width - 4.f,
                                             self.priceLabel.frame.origin.y,
                                             self.priceLabel.frame.size.width,
                                             self.priceLabel.frame.size.height)];
    }else
        [self.priceLabel setFrame:CGRectMake(CGRectGetMaxX(self.offersFromLabel.frame) + 4.0f,
                                         self.priceLabel.frame.origin.y,
                                         self.priceLabel.frame.size.width,
                                         self.priceLabel.frame.size.height)];
}

- (void)loadAllOffers
{
    [self showLoading];
    
    [RIProductOffer getProductOffersForProductUrl:self.product.url successBlock:^(NSArray *productOffers) {
        
        [self hideLoading];
        
        self.productOffers = [productOffers copy];
        
        [self readjustOffersFromLabel];
        
        [self.collectionView reloadData];
        
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        
        [self hideLoading];
        
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.cellIdentifier = @"offerCell";
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (VALID_NOTEMPTY(self.product, RIProduct)) {
        [self loadTopView];
        
        [self.collectionView reloadData];
    }
}

- (void)setProductOffers:(NSArray *)productOffers {
    _productOffers = productOffers;
    
    self.selectedProductSimple = [NSMutableDictionary new];
    for (RIProductOffer* po in productOffers) {
        for (RIProductSimple *simple in po.productSimples) {
            if ([simple.quantity intValue] > 0) {
                [self.selectedProductSimple setValue:simple forKey:po.productSku];
                break;
            }
        }
    }
    
}

- (JAPicker *)picker
{
    if (!VALID_NOTEMPTY(_picker, JAPicker)) {
        _picker = [JAPicker new];
    }
    return _picker;
}


#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productOffers.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.width, 104.f);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIProductOffer* offer = [self.productOffers objectAtIndex:indexPath.row];
    
    JAOfferCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [cell loadWithProductOffer:offer withProductSimple:[self.selectedProductSimple objectForKey:offer.productSku]];
    cell.addToCartButton.tag = indexPath.row;
    [cell.addToCartButton addTarget:self
                             action:@selector(addToCartButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    cell.sizeButton.tag = indexPath.row;
    [cell.sizeButton addTarget:self
                             action:@selector(sizeButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Button Actions

- (void)addToCartButtonPressed:(UIButton*)sender
{
    RIProductOffer* offer = [self.productOffers objectAtIndex:sender.tag];
    RIProductSimple* simp =[self.selectedProductSimple objectForKey:offer.productSku];
    NSString* simpleSku = simp.sku;
    
    [self showLoading];
    [RICart addProductWithQuantity:@"1"
                               sku:offer.productSku
                            simple:simpleSku
                  withSuccessBlock:^(RICart *cart) {
                      
                      NSNumber *price = offer.priceEuroConverted;
                      
                      NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                      [trackingDictionary setValue:simpleSku forKey:kRIEventLabelKey];
                      [trackingDictionary setValue:@"SellerAddToCart" forKey:kRIEventActionKey];
                      [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                      [trackingDictionary setValue:price forKey:kRIEventValueKey];
                      
                      NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                      
                      [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                      [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                      [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                      [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                      
                      // Since we're sending the converted price, we have to send the currency as EUR.
                      // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
                      [trackingDictionary setValue:price forKey:kRIEventPriceKey];
                      [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];

                      [trackingDictionary setValue:@"1" forKey:kRIEventQuantityKey];
                      
                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart]
                                                                data:[trackingDictionary copy]];
                      
                      
                      NSMutableDictionary *tracking = [NSMutableDictionary new];
                      [tracking setValue:self.product.name forKey:kRIEventProductNameKey];
                      [tracking setValue:self.product.sku forKey:kRIEventSkuKey];
                      if(VALID_NOTEMPTY(self.product.categoryIds, NSOrderedSet)) {
                          [tracking setValue:[self.product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
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
                                               FBSDKAppEventParameterNameContentType : self.product.name,
                                               FBSDKAppEventParameterNameContentID   : self.product.sku}];
                      
                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      
                      [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                      [self hideLoading];
                      
                  } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                      NSString *addToCartError = STRING_ERROR_ADDING_TO_CART;
                      if(RIApiResponseNoInternetConnection == apiResponse)
                      {
                          addToCartError = STRING_NO_CONNECTION;
                      }
                      
                      [self showMessage:addToCartError success:NO];
                      [self hideLoading];
                  }];
}

- (void)sizeButtonPressed:(UIButton*)button {
    
    RIProductOffer* prod = [self.productOffers objectAtIndex:button.tag];
    _pickerSku = prod.productSku;
    [self openPickerForProduct:prod];
}


#pragma mark - picker

- (void)openPickerForProduct:(RIProductOffer *)product
{
    NSMutableArray *sizes = [NSMutableArray new];
    NSMutableArray *simples = [NSMutableArray new];
    for (RIProductSimple *simple in product.productSimples) {
        if ([simple.quantity integerValue] > 0)
        {
            [sizes addObject:simple.variation];
            [simples addObject:simple];
        }
    }
    _pickerDataSource = [simples copy];
    [self loadSizePickerWithOptions:sizes title:product.seller.name previousText:@"" leftButtonTitle:nil];
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
    [self.selectedProductSimple setObject:simple forKey:_pickerSku];
    
    [self closePicker];
    [self.collectionView reloadData];
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
    if (VALID_NOTEMPTY(self.product.sizeGuideUrl, NSString)) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.product.sizeGuideUrl, @"sizeGuideUrl", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSizeGuideNotification object:nil userInfo:dic];
    }
}

@end
