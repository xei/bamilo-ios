//
//  JAMyFavouritesViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyFavouritesViewController.h"
#import "JACatalogListCell.h"
#import "JAButtonCell.h"
#import "JAUtils.h"
#import "RIProduct.h"
#import "RIProductSimple.h"
#import "RICart.h"
#import "RICustomer.h"
#import "RICategory.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "JAProductListFlowLayout.h"
#import "RIAddress.h"

#define JAMyFavouritesViewControllerMaxProducts 20
#define JAMyFavouritesViewControllerMaxProducts_ipad 34

@interface JAMyFavouritesViewController ()
{
    BOOL _needRefreshProduct;
}

@property (weak, nonatomic) IBOutlet UIView *emptyFavoritesView;
@property (weak, nonatomic) IBOutlet UILabel *emptyFavoritesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *emptyFavoritesImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSString* cellIdentifier;
@property (nonatomic, strong) NSString* buttonCellIdentifier;
@property (nonatomic, strong) JAProductListFlowLayout* flowLayout;
@property (nonatomic, strong) NSArray* productsArray;
@property (assign, nonatomic) BOOL selectedSizeAndAddToCart;

@property (nonatomic, assign)NSInteger totalProdutsInWishlist;

// size picker view
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;
@property (nonatomic, strong) NSMutableDictionary* chosenSimples;

@property (strong, nonatomic) UIButton *backupButton; // for the retry connection, is necessary to store the button

// pagination
@property (assign, nonatomic) BOOL lastPage;
@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) NSInteger maxPerPage;
@property (assign, nonatomic) NSInteger numberProducts;

@end

@implementation JAMyFavouritesViewController


@synthesize productsArray=_productsArray;
- (void)setProductsArray:(NSArray *)productsArray
{
    _productsArray = productsArray;
    [self.collectionView reloadData];
    if (ISEMPTY(productsArray)) {
        self.emptyFavoritesView.hidden = NO;
        self.collectionView.hidden = YES;
    } else {
        self.emptyFavoritesView.hidden = YES;
        self.collectionView.hidden = NO;
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"SearchResults";
    self.A4SViewControllerAlias = @"MYFAVOURITES";
    
    self.navBarLayout.title = STRING_MY_FAVOURITES;
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    self.searchBarIsVisible = YES;
    
    self.totalProdutsInWishlist = 0;
    
    self.selectedSizeAndAddToCart = NO;
    
    self.navigationItem.hidesBackButton = YES;
    
    self.collectionView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    [self.emptyFavoritesView setBackgroundColor:JABlack200Color];
    
    self.emptyFavoritesLabel.font = JABody3Font;
    self.emptyFavoritesLabel.textColor = JABlack800Color;
    self.emptyFavoritesLabel.text = STRING_NO_FAVOURITES;
    [self.emptyFavoritesLabel sizeToFit];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAFavoriteListCell" bundle:nil] forCellWithReuseIdentifier:@"favoriteListCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAFavoriteListCell_ipad_portrait" bundle:nil] forCellWithReuseIdentifier:@"favoriteListCell_ipad_portrait"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAFavoriteListCell_ipad_landscape" bundle:nil] forCellWithReuseIdentifier:@"favoriteListCell_ipad_landscape"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAOrangeButtonCell" bundle:nil] forCellWithReuseIdentifier:@"buttonCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAOrangeButtonCell_ipad_portrait" bundle:nil] forCellWithReuseIdentifier:@"buttonCell_ipad_portrait"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"JAOrangeButtonCell_ipad_landscape" bundle:nil] forCellWithReuseIdentifier:@"buttonCell_ipad_landscape"];
    
    self.flowLayout = [[JAProductListFlowLayout alloc] init];
    self.flowLayout.manualCellSpacing = 6.0f;
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    self.collectionView.frame = CGRectMake(6.0f,
                                           [self viewBounds].origin.y,
                                           [self viewBounds].size.width - 6.0f*2,
                                           [self viewBounds].size.height);
    
    self.emptyFavoritesView.frame = CGRectMake(0,
                                               [self viewBounds].origin.y + 1.0f,
                                               [self viewBounds].size.width,
                                               [self viewBounds].size.height);
    self.emptyFavoritesImageView.frame = CGRectMake((self.emptyFavoritesView.frame.size.width - self.emptyFavoritesImageView.frame.size.width)/2,
                                                    48.0f,
                                                    self.emptyFavoritesImageView.frame.size.width,
                                                    self.emptyFavoritesImageView.frame.size.height);
    
    [self.emptyFavoritesLabel setY:CGRectGetMaxY(self.emptyFavoritesImageView.frame) + 32.f];
    [self.emptyFavoritesLabel setX:self.emptyFavoritesView.frame.size.width/2 - self.emptyFavoritesLabel.width/2];
    
    self.lastPage = NO;
    self.currentPage = 0;
    self.numberProducts = 0;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        self.maxPerPage = JAMyFavouritesViewControllerMaxProducts_ipad;
    } else {
        self.maxPerPage = JAMyFavouritesViewControllerMaxProducts;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.productsArray = nil;
    [self getFavorites];
    
    [self didRotateFromInterfaceOrientation:0];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"Favourites"];
    
    self.collectionView.frame = CGRectMake(6.0f,
                                           self.collectionView.frame.origin.y,
                                           [self viewBounds].size.width - 6.0f*2,
                                           [self viewBounds].size.height);
    
    self.emptyFavoritesView.frame = CGRectMake(0,
                                               [self viewBounds].origin.y + 1.0f,
                                               [self viewBounds].size.width,
                                               [self viewBounds].size.height);
    self.emptyFavoritesImageView.frame = CGRectMake((self.emptyFavoritesView.frame.size.width - self.emptyFavoritesImageView.frame.size.width)/2,
                                                    48.0f,
                                                    self.emptyFavoritesImageView.frame.size.width,
                                                    self.emptyFavoritesImageView.frame.size.height);
    [self.emptyFavoritesLabel setY:CGRectGetMaxY(self.emptyFavoritesImageView.frame) + 32.f];
    [self.emptyFavoritesLabel setX:self.emptyFavoritesView.frame.size.width/2 - self.emptyFavoritesLabel.width/2];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.picker removeFromSuperview];
    
    self.collectionView.frame = CGRectMake(6.0f,
                                           self.collectionView.frame.origin.y,
                                           [self viewBounds].size.width - 6.0f*2,
                                           [self viewBounds].size.height);
    [self.collectionView reloadData];
    
//    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        self.emptyFavoritesView.frame = CGRectMake(self.emptyFavoritesView.frame.origin.x,
                                                   self.emptyFavoritesView.frame.origin.y,
                                                   [self viewBounds].size.width - self.emptyFavoritesView.frame.origin.x * 2,
                                                   [self viewBounds].size.height);
        self.emptyFavoritesImageView.frame = CGRectMake((self.emptyFavoritesView.frame.size.width - self.emptyFavoritesImageView.frame.size.width)/2,
                                                        56.0f,
                                                        self.emptyFavoritesImageView.frame.size.width,
                                                        self.emptyFavoritesImageView.frame.size.height);
        self.emptyFavoritesLabel.frame = CGRectMake(12.0f,
                                                    183.0f,
                                                    self.emptyFavoritesView.frame.size.width - 12*2,
                                                    self.emptyFavoritesLabel.frame.size.height);
//    }
    
    [self changeViewToInterfaceOrientation:self.interfaceOrientation];
}

- (void)changeViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            self.cellIdentifier = @"favoriteListCell_ipad_landscape";
            self.buttonCellIdentifier = @"buttonCell_ipad_landscape";
        } else {
            self.cellIdentifier = @"favoriteListCell_ipad_portrait";
            self.buttonCellIdentifier = @"buttonCell_ipad_portrait";
        }
    } else {
        self.cellIdentifier = @"favoriteListCell";
        self.buttonCellIdentifier = @"buttonCell";
    }
    
    [self.collectionView reloadData];
}

- (void)updateFavorites:(NSInteger)nProd {
    NSInteger page = ++nProd / self.maxPerPage;

    if (nProd % self.maxPerPage>0) {
        page++;
    }
    
    [RIProduct getFavoriteProductsForPage:page maxItems:self.maxPerPage SuccessBlock:^(NSArray *favoriteProducts) {
        
        [self updateListsWith:favoriteProducts replace:page];
        [self hideLoading];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        [self hideLoading];
    }];
}

- (void)getFavorites
{
    [self showLoading];
    
    if(![RICustomer checkIfUserIsLogged]) {
        [self hideLoading];
        if (_needRefreshProduct) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
            return;
        }
        _needRefreshProduct = YES;
        NSMutableDictionary* userInfoLogin = [[NSMutableDictionary alloc] init];
        [userInfoLogin setObject:[NSNumber numberWithBool:NO] forKey:@"from_side_menu"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification object:nil userInfo:userInfoLogin];
        return;
    }
    _needRefreshProduct = NO;
    
    [RIProduct getFavoriteProductsForPage:(self.currentPage+1) maxItems:self.maxPerPage SuccessBlock:^(NSArray *favoriteProducts) {
        
        [self removeErrorView];
        
        self.currentPage++;
        self.numberProducts += favoriteProducts.count;
        if (favoriteProducts.count < self.maxPerPage) {
            self.lastPage = YES;
        }
        
        CGFloat totalWishlistValue = 0.0f;
        for(RIProduct *product in favoriteProducts)
        {
            if(VALID_NOTEMPTY(product.specialPrice, NSNumber) && [product.specialPrice floatValue] > 0.0f)
            {
                totalWishlistValue += [product.specialPrice floatValue];
            }
            else
            {
                totalWishlistValue += [product.price floatValue];
            }
        }
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
        NSMutableDictionary *trackingDictionary = nil;
        for(RIProduct *product in favoriteProducts)
        {
            trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
            if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
            {
                [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
            }
            [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
            
            NSString *discount = @"false";
            NSNumber *price = product.priceEuroConverted;
            if (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f)
            {
                price = product.specialPriceEuroConverted;
                discount = @"true";
            }
            
            if (VALID_NOTEMPTY(product.attributeColor, NSString))
            {
                [trackingDictionary setValue:product.attributeColor forKey:kRIEventColorKey];
            }
            
            // Since we're sending the converted price, we have to send the currency as EUR.
            // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
            [trackingDictionary setValue:price forKey:kRIEventPriceKey];
            [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
            
            [trackingDictionary setValue:discount forKey:kRIEventDiscountKey];
            [trackingDictionary setValue:product.brand forKey:kRIEventBrandKey];
            if (VALID_NOTEMPTY(product.productSimples, NSArray) && 1 == product.productSimples.count)
            {
                RIProductSimple *tempProduct = product.productSimples[0];
                if (VALID_NOTEMPTY(tempProduct.variation, NSString))
                {
                    [trackingDictionary setValue:tempProduct.variation forKey:kRIEventSizeKey];
                }
            }
            [trackingDictionary setValue:@"1" forKey:kRIEventQuantityKey];
            [trackingDictionary setValue:[NSString stringWithFormat:@"%.2f",totalWishlistValue] forKey:kRIEventTotalWishlistKey];
            
            if ([RICustomer checkIfUserIsLogged]) {
                [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
                [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
                    RIAddress *shippingAddress = (RIAddress *)[adressList objectForKey:@"shipping"];
                    [trackingDictionary setValue:shippingAddress.city forKey:kRIEventCityKey];
                    [trackingDictionary setValue:shippingAddress.customerAddressRegion forKey:kRIEventRegionKey];
                    
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewWishlist]
                                                              data:[trackingDictionary copy]];
                    
                } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                    NSLog(@"ERROR: getting customer");
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewWishlist]
                                                              data:[trackingDictionary copy]];
                }];
            }else{
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewWishlist]
                                                          data:[trackingDictionary copy]];
            }
            
            
        }
        
        // notify the InAppNotification SDK that this the active view controller
        [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        [self updateListsWith:[favoriteProducts copy]];
        [self.collectionView reloadData];
        [self hideLoading];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        if(RIApiResponseMaintenancePage == apiResponse)
        {
            [self showMaintenancePage:@selector(getFavorites) objects:nil];
        }
        else if(RIApiResponseKickoutView == apiResponse)
        {
            [self showKickoutView:@selector(getFavorites) objects:nil];
        }
        else
        {
            BOOL noConnection = NO;
            if (RIApiResponseNoInternetConnection == apiResponse)
            {
                noConnection = YES;
            }
            [self showErrorView:noConnection startingY:0.0f selector:@selector(getFavorites) objects:nil];
        }
        [self hideLoading];
    }];
}

- (void)updateListsWith:(NSArray*)products{
    [self updateListsWith:products replace:0];
}

- (void)updateListsWith:(NSArray*)products replace:(NSInteger)replace_page
{
    NSMutableArray* tempProducts = [[NSMutableArray alloc] init];
    
    if (self.chosenSimples == nil) {
        self.chosenSimples = [NSMutableDictionary new];
    }

    if (replace_page) {
        //loc is start of next page
        NSUInteger loc = self.maxPerPage*replace_page;
        NSUInteger length;
        
        NSRange range;
        
        //if loc is >  productsArray we are on the last page (that we have, there could be more)
        if (loc < [self.productsArray count]) {
            length = [self.productsArray count]-loc;
            range = NSMakeRange(loc, length);
            
            if (VALID_NOTEMPTY(products, NSArray)) {
                [tempProducts addObjectsFromArray:[self.productsArray subarrayWithRange:range]];
            }
        } else { //we only need to remove the last page
            loc -= self.maxPerPage;
            length = [self.productsArray count]-loc;
            range = NSMakeRange(loc, length);
        }
        
        range = NSMakeRange(0, self.maxPerPage*replace_page - self.maxPerPage);
        self.productsArray = [self.productsArray subarrayWithRange:range];
    }
    
    if (replace_page) {
        self.productsArray = [self.productsArray arrayByAddingObjectsFromArray:products];
        self.productsArray = [self.productsArray arrayByAddingObjectsFromArray:tempProducts];
    } else {
        if (VALID_NOTEMPTY(self.productsArray, NSArray)) {
            self.productsArray = [self.productsArray arrayByAddingObjectsFromArray:products];

        } else {
            self.productsArray = products;
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.productsArray.count;
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
    if (!self.lastPage && indexPath.row == self.productsArray.count-1) {
        
        [self getFavorites];
        
    }
    
    RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
    
    JACatalogListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    [cell loadWithProduct:product];
    cell.addToCartButton.tag = indexPath.row;
    [cell.addToCartButton addTarget:self
                             action:@selector(addToCartPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self
                          action:@selector(removeFromFavoritesPressed:)
                forControlEvents:UIControlEventTouchUpInside];
    
    if (![self.chosenSimples objectForKey:product.sku]) {
        [cell.sizeButton setTitle:STRING_SIZE forState:UIControlStateNormal];
        
    } else {
        RIProductSimple* chosenSimple = [self.chosenSimples objectForKey:product.sku];
        [cell.sizeButton setTitle:[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, chosenSimple.variation] forState:UIControlStateNormal];
            

                    [cell.priceView loadWithPrice:chosenSimple.priceFormatted
                                     specialPrice:chosenSimple.specialPriceFormatted
                                         fontSize:10.0f
                            specialPriceOnTheLeft:YES];


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

- (void)clickableViewPressedInCell:(UIControl*)sender
{
    [self collectionView:self.collectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.productsArray.count) {
        RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
        
        NSInteger count = self.productsArray.count;
        
        if (count > 20) {
            count = 20;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"targetString" : product.targetString,
                                                                      @"previousCategory" : STRING_MY_FAVOURITES,
                                                                      @"show_back_button" : [NSNumber numberWithBool:NO],
                                                                      @"fromCatalog" : [NSNumber numberWithBool:YES]}];
        [[RITrackingWrapper sharedInstance] trackScreenWithName:[NSString stringWithFormat:@"Catalog_%@",product.name]];
    }
}

#pragma mark - Button Actions

- (BOOL)didProductFail:(RIProduct*)product failedSimples:(NSArray*)failedSimples
{
    BOOL didProductFail = NO;
    if(VALID_NOTEMPTY(failedSimples, NSArray))
    {
        for(NSString *failedSimple in failedSimples)
        {
            if(VALID_NOTEMPTY(failedSimple, NSString))
            {
                for (RIProductSimple* simple in product.productSimples)
                {
                    if([failedSimple isEqualToString:simple.sku])
                    {
                        //found it
                        didProductFail = YES;
                        break;
                    }
                }
            }
        }
    }
    return didProductFail;
}

- (void)removeFromFavoritesPressed:(UIButton*)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    
    __block NSString *tempSku = product.sku;
    __block NSNumber *tempPrice = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f) ? product.specialPriceEuroConverted : product.priceEuroConverted;
    
    [self showLoading];
    [RIProduct removeFromFavorites:product successBlock:^(void) {
        
        [self removeErrorView];
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:tempSku forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"RemoveFromWishlist" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:tempPrice forKey:kRIEventValueKey];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
        
        // Since we're sending the converted price, we have to send the currency as EUR.
        // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
        [trackingDictionary setValue:tempPrice forKey:kRIEventPriceKey];
        [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
        
        [trackingDictionary setValue:tempSku forKey:kRIEventSkuKey];
        [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                  data:[trackingDictionary copy]];
        
        [self showMessage:STRING_REMOVED_FROM_WISHLIST success:YES];
        
        [self updateFavorites:button.tag];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        
        if (RIApiResponseNoInternetConnection == apiResponse)
        {
            [self showMessage:STRING_NO_CONNECTION success:NO];
        }else{
            [self showMessage:STRING_ERROR_REMOVING_FROM_WISHLIST success:NO];
        }
        [self hideLoading];
    }];
}

- (void)addToCartPressed:(UIButton*)button;
{
    self.backupButton = button;
    
    [self finishAddToCart:button];
}

- (void)finishAddToCart:(UIButton *)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    
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
                               sku:product.sku
                            simple:productSimple.sku
                  withSuccessBlock:^(RICart *cart) {
                      
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

                      // Since we're sending the converted price, we have to send the currency as EUR.
                      // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
                      [trackingDictionary setValue:price forKey:kRIEventPriceKey];
                      [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
                      
                      [trackingDictionary setValue:product.brand forKey:kRIEventBrandKey];
                      
                      NSString *discountPercentage = @"0";
                      if(VALID_NOTEMPTY(product.maxSavingPercentage, NSString))
                      {
                          discountPercentage = product.maxSavingPercentage;
                      }
                      [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
                      [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
                      [trackingDictionary setValue:@"1" forKey:kRIEventQuantityKey];
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
                      
                      [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                      
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
                      
                      [RIProduct removeFromFavorites:product successBlock:^(void) {
                          
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
                          
                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                                    data:[trackingDictionary copy]];
                          
                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInteger:RIEventAddFromWishlistToCart]
                                                                    data:[NSDictionary dictionaryWithObject:product.sku forKey:kRIEventProductFavToCartKey]];
                          
                          [[NSUserDefaults standardUserDefaults] setObject:product.sku forKey:kRIEventProductFavToCartKey];
                          [[NSUserDefaults standardUserDefaults] synchronize];
                          
                          NSMutableDictionary *tracking = [NSMutableDictionary new];
                          [tracking setValue:product.name forKey:kRIEventProductNameKey];
                          [tracking setValue:product.sku forKey:kRIEventSkuKey];
                          [tracking setValue:[product.categoryIds lastObject] forKey:kRIEventLastCategoryAddedToCartKey];
                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLastAddedToCart] data:tracking];
                          
                          [self updateFavorites:button.tag];
                          
                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                          [self hideLoading];
                      }];
                      
                  } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                      
                      NSString *addToCartError = STRING_ERROR_ADDING_TO_CART;
                      NSString *results = [[errorMessages valueForKey:@"description"] componentsJoinedByString:@""];
                      if([results  isEqualToString: @"order_product_sold_out"]){
                          
                          addToCartError = STRING_PRODCUTS_OUT_OF_STOCK;
                      }
                      if (RIApiResponseNoInternetConnection == apiResponse)
                      {
                          addToCartError = STRING_NO_CONNECTION;
                      }
                      [self showMessage:addToCartError success:NO];
                      
                      [self hideLoading];
                  }];
}

- (void)sizeButtonPressed:(UIButton*)button
{
    self.backupButton = button;
    
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    RIProductSimple* chosenSimple = [self.chosenSimples objectForKey:product.sku];
    
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:[self viewBounds]];
    [self.picker setTag:button.tag];
    [self.picker setDelegate:self];
    
    self.pickerDataSource = [NSMutableArray new];
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    NSString *simpleSize = @"";
    if (VALID(chosenSimple, RIProductSimple)) {
        simpleSize = chosenSimple.variation;
    }
    
    for (RIProductSimple* simple in product.productSimples)
    {
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
    
    CGFloat pickerViewHeight = [self viewBounds].size.height;
    CGFloat pickerViewWidth = [self viewBounds].size.width;
    [self.picker setFrame:CGRectMake(0.0f,
                                     pickerViewHeight,
                                     pickerViewWidth,
                                     pickerViewHeight)];
    [self.view addSubview:self.picker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f,
                                                          [self viewBounds].origin.y,
                                                          pickerViewWidth,
                                                          pickerViewHeight)];
                     }];
}

#pragma mark JAPickerDelegate
-(void)selectedRow:(NSInteger)selectedRow
{
    RIProduct* product = [self.productsArray objectAtIndex:self.picker.tag];
    RIProductSimple* chosenSimple;
    
    
    for( RIProductSimple* selectedSimple in product.productSimples) {
        if ([selectedSimple quantity] > 0) {
            if (selectedRow--  == 0) {
                chosenSimple = selectedSimple;
                break;
            }
        }
    }
    [self.chosenSimples setObject:chosenSimple forKey:product.sku];
    
    JACatalogCell *cell = (JACatalogCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.picker.tag
                                                                                                           inSection:0]];
    [cell.priceView loadWithPrice:chosenSimple.priceFormatted
                     specialPrice:chosenSimple.specialPriceFormatted
                         fontSize:10.0f
            specialPriceOnTheLeft:YES];
    [cell.sizeButton setTitle:[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, chosenSimple.variation] forState:UIControlStateNormal];
    
    [self closePicker];
    
    if (self.selectedSizeAndAddToCart)
    {
        self.selectedSizeAndAddToCart = NO;
        [self addToCartPressed:self.backupButton];
    }
}

- (void)closePicker
{
    CGRect frame = self.picker.frame;
    frame.origin.y = [self viewBounds].size.height;
    
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
