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
#import "JAUtils.h"
#import <FacebookSDK/FacebookSDK.h>

@interface JAOtherOffersViewController ()

@property (nonatomic, strong) UIView* topView;
@property (nonatomic, strong) UILabel* brandLabel;
@property (nonatomic, strong) UILabel* nameLabel;
@property (nonatomic, strong) UIView* separatorView;
@property (nonatomic, strong) UILabel* offersFromLabel;
@property (nonatomic, strong) UILabel* priceLabel;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout* flowLayout;
@property (nonatomic, strong) NSString* cellIdentifier;
@property (nonatomic, strong) NSArray* productOffers;

@end

@implementation JAOtherOffersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    
    self.flowLayout = [UICollectionViewFlowLayout new];
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAOfferCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"offerCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAOfferCollectionViewCell_ipad_portrait" bundle:nil] forCellWithReuseIdentifier:@"offerCell_ipad_portrait"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAOfferCollectionViewCell_ipad_landscape" bundle:nil] forCellWithReuseIdentifier:@"offerCell_ipad_landscape"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadAllOffers];
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0f];
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
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
    
    CGFloat currentY = 15.0f;
    CGFloat horizontalMargin = 12.0f;
    
    if (ISEMPTY(self.brandLabel)) {
        self.brandLabel = [UILabel new];
        self.brandLabel.textColor = UIColorFromRGB(0x666666);
        self.brandLabel.font = [UIFont fontWithName:kFontMediumName size:14.0f];
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
        self.nameLabel.textColor = UIColorFromRGB(0x666666);
        self.nameLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
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

    
    currentY += self.separatorView.frame.size.height + 12.0f;
    
    if (ISEMPTY(self.offersFromLabel)) {
        self.offersFromLabel = [UILabel new];
        self.offersFromLabel.textColor = UIColorFromRGB(0x666666);
        self.offersFromLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
        if (VALID_NOTEMPTY(self.productOffers, NSArray)) {
            self.offersFromLabel.text = [NSString stringWithFormat:STRING_NUMBER_OFFERS_FROM, self.productOffers.count];
        } else {
            self.offersFromLabel.text = @" ";
        }
        [self.topView addSubview:self.offersFromLabel];
    }
    [self.offersFromLabel setFrame:CGRectMake(horizontalMargin,
                                              currentY,
                                              self.topView.frame.size.width - 2*horizontalMargin,
                                              1)];
    [self.offersFromLabel sizeToFit];
    [self.offersFromLabel setBackgroundColor:[UIColor greenColor]];
    
    if (ISEMPTY(self.priceLabel)) {
        self.priceLabel = [UILabel new];
        self.priceLabel.textColor = UIColorFromRGB(0xcc0000);
        self.priceLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
        [self.topView addSubview:self.priceLabel];
    }
    self.priceLabel.text = self.product.offersMinPriceFormatted;
    [self.priceLabel setFrame:CGRectMake(CGRectGetMaxX(self.offersFromLabel.frame) + 4.0f,
                                         currentY,
                                         self.topView.frame.size.width - 2*horizontalMargin,
                                         1)];
    [self.priceLabel sizeToFit];

    
    currentY += self.priceLabel.frame.size.height + 14.0f;
    
    [self.topView setFrame:CGRectMake(self.topView.frame.origin.x,
                                      self.topView.frame.origin.y,
                                      self.topView.frame.size.width,
                                      currentY)];
    
    //ADJUST COLLECTIONVIEW ACCORDINGLY
    
    [self.collectionView setFrame:CGRectMake(6.0f,
                                             CGRectGetMaxY(self.topView.frame),
                                             self.view.frame.size.width - 12.0f,
                                             self.view.frame.size.height - CGRectGetMaxY(self.topView.frame))];
    
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
        
        self.productOffers = productOffers;
        
        [self readjustOffersFromLabel];
        
        [self.collectionView reloadData];
        
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        
        [self hideLoading];
        
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            self.cellIdentifier = @"offerCell_ipad_landscape";
        } else {
            self.cellIdentifier = @"offerCell_ipad_portrait";
        }
    } else {
        self.cellIdentifier = @"offerCell";
    }
    
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
    return [self getLayoutItemSizeForInterfaceOrientation:self.interfaceOrientation];
}

- (CGSize)getLayoutItemSizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat width = 0.0f;
    CGFloat height = 0.0f;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            width = 375.0f;
            height = 104.0f;
        } else {
            width = 333.0f;
            height = 104.0f;
        }
    } else {
        width = self.view.frame.size.width;
        height = 104.0f;
    }
    
    return CGSizeMake(width, height);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIProductOffer* offer = [self.productOffers objectAtIndex:indexPath.row];
    
    JAOfferCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [cell loadWithProductOffer:offer];
    cell.addToCartButton.tag = indexPath.row;
    [cell.addToCartButton addTarget:self
                             action:@selector(addToCartButtonPressed:)
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
    
    [self showLoading];
    [RICart addProductWithQuantity:@"1"
                               sku:offer.productSku
                            simple:offer.simpleSku
                  withSuccessBlock:^(RICart *cart) {
                      
                      NSNumber *price = offer.priceEuroConverted;
                      
                      NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                      [trackingDictionary setValue:offer.simpleSku forKey:kRIEventLabelKey];
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
                      
                      float value = [price floatValue];
                      [FBAppEvents logEvent:FBAppEventNameAddedToCart
                                 valueToSum:value
                                 parameters:@{ FBAppEventParameterNameCurrency    : @"EUR",
                                               FBAppEventParameterNameContentType : self.product.name,
                                               FBAppEventParameterNameContentID   : self.product.sku}];
                      
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


@end
