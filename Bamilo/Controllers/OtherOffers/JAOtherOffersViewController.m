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
#import "RISeller.h"
#import "RIProductSimple.h"
#import "JAUtils.h"
#import "JAProductListFlowLayout.h"
#import "JAPicker.h"
#import "Bamilo-Swift.h"

@interface JAOtherOffersViewController () <JAPickerDelegate, JAOfferCollectionViewCellDelegate>
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
@property (strong, nonatomic) RICart *cart;

@end

@implementation JAOtherOffersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cellIdentifier = @"offerCell";
    
    [self.view setBackgroundColor:JAWhiteColor];
    
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
    
    [self.collectionView registerClass:[JAOfferCollectionViewCell class] forCellWithReuseIdentifier: self.cellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadAllOffers];
    
//    [self willRotateToInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation] duration:0.0f];
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
    [self.topView setFrame: [self viewBounds]];
    [self.topView setHeight:1];
    
    CGFloat currentY = 10.0f;
    CGFloat horizontalMargin = 10.0f;
    
    if (ISEMPTY(self.brandLabel)) {
        self.brandLabel = [UILabel new];
        self.brandLabel.textColor = JABlackColor;
        self.brandLabel.font = JAListFont;
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
        self.separatorView.backgroundColor = JATextFieldColor;
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
    
    [self.collectionView setFrame:CGRectMake(0.0f,
                                             [self viewBounds].origin.y + self.topView.height,
                                             self.view.frame.size.width,
                                             [self viewBounds].size.height  - CGRectGetMaxY(self.topView.frame))];
    
    if (RI_IS_RTL) {
        [self.topView flipAllSubviews];
    }
}

- (void)readjustOffersFromLabel {
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
    
    [RIProductOffer getProductOffersForProductWithSku:self.product.sku successBlock:^(NSArray *productOffers) {
        
        [self hideLoading];
        
        self.productOffers = [productOffers copy];
        
        [self readjustOffersFromLabel];
        
        [self.collectionView reloadData];
        
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        
        [self hideLoading];
        
    }];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         //UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         if (VALID_NOTEMPTY(self.product, RIProduct)) {
             [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

             [self loadTopView];
             
             [self.collectionView reloadData];
         }
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         
     }];
}

- (void)setProductOffers:(NSArray *)productOffers {
    _productOffers = productOffers;
    
    self.selectedProductSimple = [NSMutableDictionary new];
    for (RIProductOffer* po in productOffers) {
        for (RIProductSimple *simple in po.productSimples) {
            if ([simple.quantity intValue] > 0 || po.productSimples.count == 1) {
                [self.selectedProductSimple setValue:simple forKey:po.productSku];
                break;
            }
        }
    }
}

- (JAPicker *)picker {
    if (!VALID_NOTEMPTY(_picker, JAPicker)) {
        _picker = [JAPicker new];
    }
    return _picker;
}


#pragma mark - UICollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.productOffers.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 114.0f;
    RIProductOffer* offer = [self.productOffers objectAtIndex:indexPath.row];
    if (offer.freeShippingPossible) {
        cellHeight += 20.0f;
    }
    return CGSizeMake(self.collectionView.width, cellHeight);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RIProductOffer* offer = [self.productOffers objectAtIndex:indexPath.row];
    
    JAOfferCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell loadWithProductOffer:offer withProductSimple:[self.selectedProductSimple objectForKey:offer.productSku]];
    cell.addToCartClicableView.tag = indexPath.row;
    [cell.addToCartClicableView addTarget:self
                             action:@selector(addToCartButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    cell.sizeClickableView.tag = indexPath.row;
    [cell.sizeClickableView addTarget:self
                             action:@selector(sizeButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Button Actions

- (void)addToCartButtonPressed:(UIButton*)sender {
    RIProductOffer *offer = [self.productOffers objectAtIndex:sender.tag];
    RIProductSimple *simpleProduct =[self.selectedProductSimple objectForKey:offer.productSku];
    NSString *simpleSku = simpleProduct.sku;
    
    [DataAggregator addProductToCart:self simpleSku:simpleSku completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.cart forKey:kUpdateCartNotificationValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
            
            [self onSuccessResponse:RIApiResponseSuccess messages:[self extractSuccessMessages:[data objectForKey:kDataMessages]] showMessage:YES];
            //[self hideLoading];
        } else {
            //EVENT: ADD TO CART
            [self onErrorResponse:error.code messages:[error.userInfo objectForKey:kErrorMessages] showAsMessage:YES selector:@selector(addToCartButtonPressed:) objects:@[sender]];
        }
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
    
    self.picker = [[JAPicker alloc] initWithFrame: [self viewBounds]];
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

//- (void)leftButtonPressed {
//    if (VALID_NOTEMPTY(self.product.sizeGuideUrl, NSString)) {
//        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:self.product.sizeGuideUrl, @"sizeGuideUrl", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSizeGuideNotification object:nil userInfo:dic];
//    }
//}

#pragma mark - DataServiceProtocol.h
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
    return STRING_OTHER_SELLERS;
}

- (NSString *)getScreenName {
    return @"OtherOffersView";
}

#pragma mark - JAOfferCollectionViewCellDelegate
- (void)sellerNameTappedByProductOffer:(RIProductOffer *)offer {
    if(VALID_NOTEMPTY(offer.seller, Seller) && VALID_NOTEMPTY(offer.seller.target, NSString)) {
        [[MainTabBarViewController topNavigationController] openScreenTarget:offer.seller.target purchaseInfo:nil currentScreenName:[self getScreenName]];
    }
}

@end
