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
#import "JAPDVViewController.h"
#import "JAUtils.h"
#import "RIProduct.h"
#import "RIProductSimple.h"
#import "RICart.h"
#import "RICustomer.h"

@interface JAMyFavouritesViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyFavoritesView;
@property (weak, nonatomic) IBOutlet UILabel *emptyFavoritesLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray* productsArray;
@property (assign, nonatomic) BOOL selectedSizeAndAddToCart;
@property (assign, nonatomic) BOOL finishedAddingAllToCart;

@property (nonatomic, assign)NSInteger addAllToCartCount;
@property (nonatomic, assign)NSInteger totalProdutsInWishlist;

// size picker view
@property (strong, nonatomic) UIView *sizePickerBackgroundView;
@property (strong, nonatomic) UIToolbar *sizePickerToolbar;
@property (strong, nonatomic) UIPickerView *sizePicker;
@property (nonatomic, strong) NSMutableArray* chosenSimpleNames;

@property (strong, nonatomic) UIButton *backupButton; // for the retry connection, is necessary to store the button

@end

@implementation JAMyFavouritesViewController

@synthesize addAllToCartCount=_addAllToCartCount;
-(void)setAddAllToCartCount:(NSInteger)addAllToCartCount
{
    _addAllToCartCount=addAllToCartCount;
    if (0 == addAllToCartCount) {
        [self addAddAllToCartFinished];
    }
}

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
    
    self.A4SViewControllerAlias = @"MYFAVOURITES";
    
    self.navBarLayout.title = STRING_MY_FAVOURITES;
    
    self.totalProdutsInWishlist = 0;
    self.addAllToCartCount = -1;
    
    self.selectedSizeAndAddToCart = NO;
    self.finishedAddingAllToCart = NO;
    
    self.navigationItem.hidesBackButton = YES;
    
    self.collectionView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    self.emptyFavoritesView.layer.cornerRadius = 3.0f;
    
    self.emptyFavoritesLabel.textColor = UIColorFromRGB(0xcccccc);
    self.emptyFavoritesLabel.text = STRING_NO_FAVOURITES;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UINib *listCellNib = [UINib nibWithNibName:@"JAFavoriteListCell" bundle:nil];
    [self.collectionView registerNib:listCellNib forCellWithReuseIdentifier:@"favoriteListCell"];
    UINib *buttonCellNib = [UINib nibWithNibName:@"JAOrangeButtonCell" bundle:nil];
    [self.collectionView registerNib:buttonCellNib forCellWithReuseIdentifier:@"buttonCell"];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, JACatalogViewControllerListCellHeight);
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showLoading];
    
    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
        
        NSMutableArray *tempArray = [favoriteProducts mutableCopy];
        
        [tempArray sortUsingComparator:^(RIProduct *obj1, RIProduct *obj2)
         {
             NSComparisonResult result = [obj1.price compare:obj2.price];
             
             switch (result)
             {
                 case NSOrderedAscending: return (NSComparisonResult)NSOrderedDescending; break;
                 case NSOrderedDescending: return (NSComparisonResult)NSOrderedAscending; break;
                 case NSOrderedSame: return (NSComparisonResult)NSOrderedSame; break;
                     
                 default: return (NSComparisonResult)NSOrderedSame; break;
             }
         }];
        
        CGFloat totalWishlistValue = 0.0f;
        for(RIProduct *product in tempArray)
        {
            if(VALID_NOTEMPTY(product.specialPrice, NSNumber) && [product.specialPrice floatValue] < [product.price floatValue] )
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
        for(RIProduct *product in tempArray)
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
            [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
            
            NSString *discount = @"false";
            NSString *price = [product.price stringValue];
            if (VALID_NOTEMPTY(product.specialPrice, NSNumber) && [product.specialPrice floatValue] < [product.price floatValue])
            {
                price = [product.specialPrice stringValue];
                discount = @"true";
            }
            
            [trackingDictionary setValue:price forKey:kRIEventPriceKey];
            [trackingDictionary setValue:discount forKey:kRIEventDiscountKey];
            [trackingDictionary setValue:product.brand forKey:kRIEventBrandKey];
            if (VALID_NOTEMPTY(product.productSimples, NSArray) && 1 == product.productSimples.count)
            {
                RIProductSimple *tempProduct = product.productSimples[0];
                if (VALID_NOTEMPTY(tempProduct.attributeSize, NSString))
                {
                    [trackingDictionary setValue:tempProduct.attributeSize forKey:kRIEventSizeKey];
                }
            }
            
            [trackingDictionary setValue:[NSString stringWithFormat:@"%f",totalWishlistValue] forKey:kRIEventTotalWishlistKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewWishlist]
                                                      data:[trackingDictionary copy]];
        }
        
        // notify the InAppNotification SDK that this the active view controller
        [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
        
        [self hideLoading];
        [self updateListsWith:[tempArray copy]];
    } andFailureBlock:^(NSArray *error) {
        [self hideLoading];
    }];
}

- (void)updateListsWith:(NSArray*)products
{
    self.chosenSimpleNames = [NSMutableArray new];
    for (int i = 0; i < products.count; i++) {
        [self.chosenSimpleNames addObject:@""];
    }
    self.productsArray = products;
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
    return self.productsArray.count + 1;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(3, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.productsArray.count == indexPath.row) {
        return CGSizeMake(self.view.frame.size.width,
                          55.0f);
    } else {
        return CGSizeMake(self.view.frame.size.width,
                          98.0f);
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.productsArray.count) {
        
        NSString *cellIdentifier = @"buttonCell";
        
        JAButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell loadWithButtonName:STRING_ADD_ALL_TO_CART];
        
        [cell.button addTarget:self
                        action:@selector(addAllToCart)
              forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
        
        NSString *cellIdentifier = @"favoriteListCell";
        
        JACatalogListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell loadWithProduct:product];
        cell.addToCartButton.tag = indexPath.row;
        [cell.addToCartButton addTarget:self
                                 action:@selector(addToCartPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
        cell.deleteButton.tag = indexPath.row;
        [cell.deleteButton addTarget:self
                              action:@selector(removeFromFavoritesPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        NSString* chosenSimpleName = [self.chosenSimpleNames objectAtIndex:indexPath.row];
        if ([chosenSimpleName isEqualToString:@""]) {
            [cell.sizeButton setTitle:STRING_SIZE forState:UIControlStateNormal];
        } else {
            [cell.sizeButton setTitle:[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, chosenSimpleName] forState:UIControlStateNormal];
        }
        cell.sizeButton.tag = indexPath.row;
        [cell.sizeButton addTarget:self
                            action:@selector(sizeButtonPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.productsArray.count) {
        RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
        
        NSInteger count = self.productsArray.count;
        
        if (count > 20) {
            count = 20;
        }
        
        NSMutableArray *tempArray = [NSMutableArray new];
        
        for (int i = 0 ; i < count ; i ++) {
            [tempArray addObject:[self.productsArray objectAtIndex:i]];
        }
        
        JAPDVViewController *pdv = [self.storyboard instantiateViewControllerWithIdentifier:@"pdvViewController"];
        pdv.productUrl = product.url;
        pdv.fromCatalogue = YES;
        pdv.previousCategory = STRING_MY_FAVOURITES;
        pdv.arrayWithRelatedItems = [tempArray copy];
        
        [self.navigationController pushViewController:pdv
                                             animated:YES];
    }
}

#pragma mark - Button Actions

- (void)addAllToCart
{
    //first lets check if we have all products with simples selected
    for (int i = 0; i < self.chosenSimpleNames.count; i++) {
        RIProduct* product = [self.productsArray objectAtIndex:i];
        if (1 != product.productSimples.count) {
            //has more than one simple, lets check if there is a simple selected
            NSString* string = [self.chosenSimpleNames objectAtIndex:i];
            if ([string isEqualToString:@""]) {
                //nothing is selected, abort
                
                [self showMessage:STRING_CHOOSE_SIZE_FOR_ALL_PRODUCTS success:NO];

                return;
            }
        }
    }
    
    [self showLoading];
    
    self.totalProdutsInWishlist = self.productsArray.count;
    self.addAllToCartCount = self.productsArray.count;
    
    for (int i = 0; i < self.chosenSimpleNames.count; i++) {
        RIProduct* product = [self.productsArray objectAtIndex:i];
        
        //lets find the simple that was selected
        NSString* simpleName = [self.chosenSimpleNames objectAtIndex:i];
        
        RIProductSimple* productSimple;
        
        if (1 == product.productSimples.count) {
            //found it
            productSimple = [product.productSimples firstObject];
        }
        for (RIProductSimple* simple in product.productSimples) {
            if ([simpleName isEqualToString:simple.attributeSize] ||
                [simpleName isEqualToString:simple.variation] ||
                [simpleName isEqualToString:simple.color]) {
                //found it
                productSimple = simple;
                break;
            }
        }
        
        [RICart addProductWithQuantity:@"1"
                                   sku:product.sku
                                simple:productSimple.sku
                      withSuccessBlock:^(RICart *cart) {
                          
                          NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                          [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
                          [trackingDictionary setValue:@"AddToCart" forKey:kRIEventActionKey];
                          [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                          [trackingDictionary setValue:product.price forKey:kRIEventValueKey];
                          [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                          [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                          [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                          NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                          [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                          [trackingDictionary setValue:[product.price stringValue] forKey:kRIEventPriceKey];
                          [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
                          [trackingDictionary setValue:product.name forKey:kRIEventProductNameKey];
                          
                          if(VALID_NOTEMPTY(product.categoryIds, NSOrderedSet))
                          {
                              NSArray *categoryIds = [product.categoryIds array];
                              [trackingDictionary setValue:[categoryIds objectAtIndex:0] forKey:kRIEventCategoryIdKey];
                          }
                          
                          [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
                          
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
                          
                          [RIProduct removeFromFavorites:product successBlock:^(void) {
                              
                              NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                              [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
                              [trackingDictionary setValue:@"RemoveFromWishlist" forKey:kRIEventActionKey];
                              [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                              [trackingDictionary setValue:product.price forKey:kRIEventValueKey];
                              [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                              [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                              [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                              NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                              [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                              [trackingDictionary setValue:[product.price stringValue] forKey:kRIEventPriceKey];
                              [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
                              [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
                              
                              [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                                        data:[trackingDictionary copy]];
                          } andFailureBlock:^(NSArray *error) {
                          }];
                          
                          self.addAllToCartCount--;
                          
                      } andFailureBlock:^(NSArray *errorMessages) {
                          
                          self.addAllToCartCount--;
                          
                      }];
        
    }
    
    self.finishedAddingAllToCart = YES;
}

- (void)addAddAllToCartFinished
{
    [RICart getCartWithSuccessBlock:^(RICart *cartData) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cartData forKey:kUpdateCartNotificationValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
        
        if (self.finishedAddingAllToCart) {
            self.finishedAddingAllToCart = NO;
            [self hideLoading];
        }
    } andFailureBlock:^(NSArray *errorMessages) {
        if (self.finishedAddingAllToCart) {
            self.finishedAddingAllToCart = NO;
            [self hideLoading];
        }
    }];
    
    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
        if (VALID_NOTEMPTY(favoriteProducts, NSArray)) {
            NSString* errorMessage = STRING_ERROR_ADD_TO_CART_FAILED_FOR_1_PRODUCT;
            if (1 < favoriteProducts.count) {
                errorMessage = [NSString stringWithFormat:STRING_ERROR_ADD_TO_CART_FAILED_FOR_X_PRODUCTS, favoriteProducts.count];
            }

            [self showMessage:errorMessage success:NO];
            
            self.totalProdutsInWishlist -= [favoriteProducts count];
        }
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInteger:RIEventAddFromWishlistToCart] data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.totalProdutsInWishlist] forKey:kRIEventNumberOfProductsKey]];
        
        [self updateListsWith:favoriteProducts];
        [self hideLoading];
    } andFailureBlock:^(NSArray *error) {
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInteger:RIEventAddFromWishlistToCart] data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.totalProdutsInWishlist] forKey:kRIEventNumberOfProductsKey]];

        [self hideLoading];
    }];
}

- (void)removeFromFavoritesPressed:(UIButton*)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    
    __block NSString *tempSku = product.sku;
    __block NSNumber *tempPrice = product.price;
    
    [self showLoading];
    [RIProduct removeFromFavorites:product successBlock:^(void) {
        
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
        [trackingDictionary setValue:[tempPrice stringValue] forKey:kRIEventPriceKey];
        [trackingDictionary setValue:tempSku forKey:kRIEventSkuKey];
        [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                  data:[trackingDictionary copy]];
        
        [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
            [self updateListsWith:favoriteProducts];
            [self hideLoading];
        } andFailureBlock:^(NSArray *error) {
            [self hideLoading];
        }];
    } andFailureBlock:^(NSArray *error) {
        [self hideLoading];
    }];
}

- (void)addToCartPressed:(UIButton*)button;
{
    self.backupButton = button;
    
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self finishAddToCart:button];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self finishAddToCart:button];
    }
}

#pragma mark - No connection delegate

- (void)retryConnection
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self finishAddToCart:self.backupButton];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self finishAddToCart:self.backupButton];
    }
}

- (void)finishAddToCart:(UIButton *)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    
    RIProductSimple* productSimple;
    
    if (1 == product.productSimples.count) {
        productSimple = [product.productSimples firstObject];
    } else {
        NSString* simpleName = [self.chosenSimpleNames objectAtIndex:button.tag];
        if ([simpleName isEqualToString:@""]) {
            
            // Turn the title red
            JACatalogCell *cell = (JACatalogCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:button.tag
                                                                                                                   inSection:0]];
            
            [cell.sizeButton setTitleColor:[UIColor redColor]
                                  forState:UIControlStateNormal];
            
            self.selectedSizeAndAddToCart = YES;
            
            [self sizeButtonPressed:button];
            
            return;
        } else {
            for (RIProductSimple* simple in product.productSimples) {
                if ([simple.attributeSize isEqualToString:simpleName] ||
                    [simple.variation isEqualToString:simpleName] ||
                    [simple.color isEqualToString:simpleName]) {
                    //found it
                    productSimple = simple;
                }
            }
        }
    }
    
    [self showLoading];
    [RICart addProductWithQuantity:@"1"
                               sku:product.sku
                            simple:productSimple.sku
                  withSuccessBlock:^(RICart *cart) {
                      
                      NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                      [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
                      [trackingDictionary setValue:@"AddToCart" forKey:kRIEventActionKey];
                      [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                      [trackingDictionary setValue:product.price forKey:kRIEventValueKey];
                      [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                      [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                      [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                      NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                      [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                      [trackingDictionary setValue:[product.price stringValue] forKey:kRIEventPriceKey];
                      [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
                      [trackingDictionary setValue:product.name forKey:kRIEventProductNameKey];
                      
                      if(VALID_NOTEMPTY(product.categoryIds, NSOrderedSet))
                      {
                          NSArray *categoryIds = [product.categoryIds array];
                          [trackingDictionary setValue:[categoryIds objectAtIndex:0] forKey:kRIEventCategoryIdKey];
                      }
                      
                      [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
                      
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
                      
                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      
                      [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                      
                      [RIProduct removeFromFavorites:product successBlock:^(void) {
                          
                          NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                          [trackingDictionary setValue:product.sku forKey:kRIEventLabelKey];
                          [trackingDictionary setValue:@"RemoveFromWishlist" forKey:kRIEventActionKey];
                          [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                          [trackingDictionary setValue:product.price forKey:kRIEventValueKey];
                          [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                          [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                          [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                          NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                          [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                          [trackingDictionary setValue:[product.price stringValue] forKey:kRIEventPriceKey];
                          [trackingDictionary setValue:product.sku forKey:kRIEventSkuKey];
                          [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
                          
                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                                    data:[trackingDictionary copy]];
                          
                          [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
                              [self updateListsWith:favoriteProducts];
                              [self hideLoading];
                          } andFailureBlock:^(NSArray *error) {
                              [self hideLoading];
                          }];
                      } andFailureBlock:^(NSArray *error) {
                          [self hideLoading];
                      }];
                      
                  } andFailureBlock:^(NSArray *errorMessages) {
                      
                      [self showMessage:STRING_ERROR_ADDING_TO_CART success:NO];
                      
                      [self hideLoading];                      
                  }];
}

- (void)sizeButtonPressed:(UIButton*)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    NSString* simpleName = [self.chosenSimpleNames objectAtIndex:button.tag];
    
    self.sizePickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             self.view.frame.size.width,
                                                                             self.view.frame.size.height)];
    [self.sizePickerBackgroundView setBackgroundColor:[UIColor clearColor]];
    
    UITapGestureRecognizer *removePickerViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(removePickerView)];
    [self.sizePickerBackgroundView addGestureRecognizer:removePickerViewTap];
    
    self.sizePicker = [[UIPickerView alloc] init];
    [self.sizePicker setFrame:CGRectMake(self.sizePickerBackgroundView.frame.origin.x,
                                         CGRectGetMaxY(self.sizePickerBackgroundView.frame) - self.sizePicker.frame.size.height,
                                         self.sizePicker.frame.size.width,
                                         self.sizePicker.frame.size.height)];
    [self.sizePicker setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.sizePicker setAlpha:0.9];
    [self.sizePicker setShowsSelectionIndicator:YES];
    [self.sizePicker setDataSource:self];
    [self.sizePicker setDelegate:self];
    self.sizePicker.tag = button.tag;
    
    self.sizePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.sizePickerToolbar setTranslucent:NO];
    [self.sizePickerToolbar setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.sizePickerToolbar setAlpha:0.9];
    [self.sizePickerToolbar setFrame:CGRectMake(0.0f,
                                                CGRectGetMinY(self.sizePicker.frame) - self.sizePickerToolbar.frame.size.height,
                                                self.sizePickerToolbar.frame.size.width,
                                                self.sizePickerToolbar.frame.size.height)];
    
    UIButton *tmpbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tmpbutton setFrame:CGRectMake(0.0, 0.0f, 0.0f, 0.0f)];
    [tmpbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [tmpbutton setTitle:STRING_DONE forState:UIControlStateNormal];
    [tmpbutton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [tmpbutton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [tmpbutton addTarget:self action:@selector(selectSize:) forControlEvents:UIControlEventTouchUpInside];
    [tmpbutton sizeToFit];
    tmpbutton.tag = button.tag;
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithCustomView:tmpbutton];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.sizePickerToolbar setItems:[NSArray arrayWithObjects:flexibleItem, doneButton, nil]];
    
    //simple index
    NSInteger simpleIndex = 0;
    for (int i = 0; i < product.productSimples.count; i++) {
        RIProductSimple* simple = [product.productSimples objectAtIndex:i];
        if ([simple.attributeSize isEqualToString:simpleName] ||
            [simple.variation isEqualToString:simpleName] ||
            [simple.color isEqualToString:simpleName]) {
            //found it
            simpleIndex = i;
        }
    }
    
    [self.sizePicker selectRow:simpleIndex inComponent:0 animated:NO];
    [self.sizePickerBackgroundView addSubview:self.sizePicker];
    [self.sizePickerBackgroundView addSubview:self.sizePickerToolbar];
    [self.view addSubview:self.sizePickerBackgroundView];
}

- (void)selectSize:(UIButton*)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    NSInteger selectedIndex = [self.sizePicker selectedRowInComponent:0];
    
    RIProductSimple* selectedSimple = [product.productSimples objectAtIndex:selectedIndex];
    NSString* simpleName = @"";
    if (VALID_NOTEMPTY(selectedSimple.attributeSize, NSString)) {
        simpleName = selectedSimple.attributeSize;
    } else if (VALID_NOTEMPTY(selectedSimple.variation, NSString)) {
        simpleName = selectedSimple.variation;
    } else if (VALID_NOTEMPTY(selectedSimple.color, NSString)) {
        simpleName = selectedSimple.color;
    }
    
    [self.chosenSimpleNames replaceObjectAtIndex:button.tag withObject:simpleName];
    
    [self removePickerView];
    [self.collectionView reloadData];
    
    if (self.selectedSizeAndAddToCart) {
        JACatalogCell *cell = (JACatalogCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:button.tag
                                                                                                               inSection:0]];
        
        [cell.sizeButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
        [cell.sizeButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
        
        self.selectedSizeAndAddToCart = NO;
        
        [self addToCartPressed:button];
    }
}

- (void)removePickerView
{
    [self.sizePicker removeFromSuperview];
    self.sizePicker = nil;
    
    [self.sizePickerBackgroundView removeFromSuperview];
    self.sizePickerBackgroundView = nil;
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
    if (VALID_NOTEMPTY(simple.attributeSize, NSString)) {
        simpleName = simple.attributeSize;
    } else if (VALID_NOTEMPTY(simple.variation, NSString)) {
        simpleName = simple.variation;
    } else if (VALID_NOTEMPTY(simple.color, NSString)) {
        simpleName = simple.color;
    }
    NSString *title = [NSString stringWithFormat:@"%@", simpleName];
    return title;
}

@end
