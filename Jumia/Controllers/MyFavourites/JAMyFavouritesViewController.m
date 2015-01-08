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
#import "JAProductListFlowLayout.h"

@interface JAMyFavouritesViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyFavoritesView;
@property (weak, nonatomic) IBOutlet UILabel *emptyFavoritesLabel;
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
@property (nonatomic, strong) NSMutableArray* chosenSimpleNames;

@property (strong, nonatomic) UIButton *backupButton; // for the retry connection, is necessary to store the button

@property (assign, nonatomic) BOOL addAllToCartClicked;

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

    self.totalProdutsInWishlist = 0;
    
    self.selectedSizeAndAddToCart = NO;
    
    self.navigationItem.hidesBackButton = YES;
    
    self.collectionView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    self.emptyFavoritesView.layer.cornerRadius = 3.0f;
    
    self.emptyFavoritesLabel.textColor = UIColorFromRGB(0xcccccc);
    self.emptyFavoritesLabel.text = STRING_NO_FAVOURITES;
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getFavorites];
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0f];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self changeViewToInterfaceOrientation:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
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

- (void)getFavorites
{
    [self showLoading];
    
    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
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
            NSString *price = [product.priceEuroConverted stringValue];
            if (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f)
            {
                price = [product.specialPriceEuroConverted stringValue];
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
            
            [trackingDictionary setValue:[NSString stringWithFormat:@"%.2f",totalWishlistValue] forKey:kRIEventTotalWishlistKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewWishlist]
                                                      data:[trackingDictionary copy]];
        }
        
        // notify the InAppNotification SDK that this the active view controller
        [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        [self hideLoading];
        [self updateListsWith:[favoriteProducts copy]];
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
        width = self.view.frame.size.width;
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
        width = self.view.frame.size.width;
    }
    
    return CGSizeMake(width, height);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.productsArray.count) {
        
        JAButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.buttonCellIdentifier forIndexPath:indexPath];
        
        [cell loadWithButtonName:STRING_ADD_ALL_TO_CART];
        
        [cell.button addTarget:self
                        action:@selector(addAllToCart)
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
        cell.deleteButton.tag = indexPath.row;
        [cell.deleteButton addTarget:self
                              action:@selector(removeFromFavoritesPressed:)
                    forControlEvents:UIControlEventTouchUpInside];
        
        NSString* chosenSimpleName = [self.chosenSimpleNames objectAtIndex:indexPath.row];
        if ([chosenSimpleName isEqualToString:@""]) {
            [cell.sizeButton setTitle:STRING_SIZE forState:UIControlStateNormal];
            
            if(self.addAllToCartClicked)
            {
                [cell.sizeButton setTitleColor:UIColorFromRGB(0xcc0000) forState:UIControlStateNormal];
            }
            
        } else {
            [cell.sizeButton setTitle:[NSString stringWithFormat:STRING_SIZE_WITH_VALUE, chosenSimpleName] forState:UIControlStateNormal];
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
        
        NSInteger count = self.productsArray.count;
        
        if (count > 20) {
            count = 20;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"url" : product.url,
                                                                      @"previousCategory" : STRING_MY_FAVOURITES,
                                                                      @"show_back_button" : [NSNumber numberWithBool:NO],
                                                                      @"fromCatalog" : [NSNumber numberWithBool:YES]}];
    }
}

#pragma mark - Button Actions

- (void)addErrorToSizeButtons
{
    for (int i = 0; i < self.chosenSimpleNames.count; i++)
    {
        RIProduct* product = [self.productsArray objectAtIndex:i];
        if (1 != product.productSimples.count)
        {
            //has more than one simple, lets check if there is a simple selected
            NSString* string = [self.chosenSimpleNames objectAtIndex:i];
            if ([string isEqualToString:@""])
            {
                JACatalogCell *cell = (JACatalogCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                
                [cell.sizeButton setTitleColor:UIColorFromRGB(0xcc0000) forState:UIControlStateNormal];
            }
        }
    }
}

- (void)addAllToCart
{
    self.addAllToCartClicked = YES;
    
    self.totalProdutsInWishlist = self.productsArray.count;
    
    NSMutableArray *productsToAdd = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.chosenSimpleNames.count; i++) {
        NSMutableDictionary *productToAdd = [[NSMutableDictionary alloc] init];
        [productToAdd setObject:@"1" forKey:@"quantity"];

        RIProduct* product = [self.productsArray objectAtIndex:i];
        [productToAdd setObject:product.sku forKey:@"sku"];
        
        //lets find the simple that was selected
        NSString* simpleName = [self.chosenSimpleNames objectAtIndex:i];
        
        if (1 == product.productSimples.count)
        {
            //found it
            RIProductSimple *simple = [product.productSimples firstObject];
            [productToAdd setObject:simple.sku forKey:@"simple"];
        }
        else
        {
            //has more than one simple, lets check if there is a simple selected
            NSString* string = [self.chosenSimpleNames objectAtIndex:i];
            if ([string isEqualToString:@""])
            {
                //nothing is selected, abort
                
                [self showMessage:STRING_CHOOSE_SIZE_FOR_ALL_PRODUCTS success:NO];
                
                [self addErrorToSizeButtons];
                return;
            }
            else
            {
                for (RIProductSimple* simple in product.productSimples) {
                    if ([simpleName isEqualToString:simple.variation]) {
                        //found it
                        [productToAdd setObject:simple.sku forKey:@"simple"];
                        break;
                    }
                }
            }
        }
        
        [productsToAdd addObject:[productToAdd copy]];
    }
    
    [self showLoading];

    [RICart addProductsWithQuantity:[productsToAdd copy]
                   withSuccessBlock:^(RICart *cart, NSArray *failedSimples) {
                       
                       BOOL outOfStock = NO;
                       for(RIProduct *product in self.productsArray)
                       {
                           if(![self didProductFail:product failedSimples:failedSimples])
                           {
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
                               [trackingDictionary setValue:@"Wishlist" forKey:kRIEventLocationKey];
                               
                               [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart]
                                                                         data:[trackingDictionary copy]];
                               
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
                               } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                               }];
                           }
                           else
                           {
                               outOfStock = YES;
                           }
                       }
                       
                       [self addAddAllToCartFinishedWithOutOfStock:outOfStock];
                   } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages, BOOL outOfStock) {
                       [self addAddAllToCartFinishedWithOutOfStock:outOfStock];
                   }];
}

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

- (void)addAddAllToCartFinishedWithOutOfStock:(BOOL)outOfStock
{
    [RICart getCartWithSuccessBlock:^(RICart *cartData) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cartData forKey:kUpdateCartNotificationValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];

        [self hideLoading];

    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {

        [self hideLoading];
    }];
    
    self.addAllToCartClicked = NO;
    
    [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
        if (VALID_NOTEMPTY(favoriteProducts, NSArray))
        {
            NSString* errorMessage = STRING_ERROR_ADDING_TO_CART;           
            if(outOfStock)
            {
                errorMessage = STRING_PRODCUT_OUT_OF_STOCK;
                if (1 < favoriteProducts.count) {
                    errorMessage = STRING_PRODCUTS_OUT_OF_STOCK;
                }
            }
            
            [self showMessage:errorMessage success:NO];
            
            self.totalProdutsInWishlist -= [favoriteProducts count];
        }
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInteger:RIEventAddFromWishlistToCart] data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.totalProdutsInWishlist] forKey:kRIEventNumberOfProductsKey]];
        
        [self updateListsWith:favoriteProducts];
        
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInteger:RIEventAddFromWishlistToCart] data:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.totalProdutsInWishlist] forKey:kRIEventNumberOfProductsKey]];
        
        [self hideLoading];
    }];
}

- (void)removeFromFavoritesPressed:(UIButton*)button
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    
    __block NSString *tempSku = product.sku;
    __block NSNumber *tempPrice = (VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f) ? product.specialPriceEuroConverted : product.priceEuroConverted;
    
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
        
        // Since we're sending the converted price, we have to send the currency as EUR.
        // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
        [trackingDictionary setValue:tempPrice forKey:kRIEventPriceKey];
        [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
        
        [trackingDictionary setValue:tempSku forKey:kRIEventSkuKey];
        [trackingDictionary setValue:product.avr forKey:kRIEventRatingKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromWishlist]
                                                  data:[trackingDictionary copy]];
        
        [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
            [self updateListsWith:favoriteProducts];
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
            [self hideLoading];
        }];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
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
    
    if (1 == product.productSimples.count) {
        productSimple = [product.productSimples firstObject];
    } else {
        NSString* simpleName = [self.chosenSimpleNames objectAtIndex:button.tag];
        if ([simpleName isEqualToString:@""]) {
            
            // Turn the title red
            JACatalogCell *cell = (JACatalogCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:button.tag
                                                                                                                   inSection:0]];
            
            [cell.sizeButton setTitleColor:UIColorFromRGB(0xcc0000) forState:UIControlStateNormal];
            
            self.selectedSizeAndAddToCart = YES;
            
            [self sizeButtonPressed:button];
            
            return;
        } else {
            for (RIProductSimple* simple in product.productSimples) {
                if ([simple.variation isEqualToString:simpleName]) {
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
                      
                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      
                      [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                      
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
                          
                          [RIProduct getFavoriteProductsWithSuccessBlock:^(NSArray *favoriteProducts) {
                              [self updateListsWith:favoriteProducts];
                              [self hideLoading];
                          } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                              [self hideLoading];
                          }];
                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                          [self hideLoading];
                      }];
                      
                  } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                      
                      NSString *addToCartError = STRING_ERROR_ADDING_TO_CART;
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
    NSString* simpleName = [self.chosenSimpleNames objectAtIndex:button.tag];
    
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
    for (int i = 0; i < product.productSimples.count; i++)
    {
        RIProductSimple* simple = [product.productSimples objectAtIndex:i];
        [self.pickerDataSource addObject:simple];
        [dataSource addObject:simple.variation];
        if ([simple.variation isEqualToString:simpleName]) {
            //found it
            simpleSize = simple.variation;
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
    
    RIProductSimple* selectedSimple = [product.productSimples objectAtIndex:selectedRow];
    NSString* simpleName = @"";
    if (VALID_NOTEMPTY(selectedSimple.variation, NSString)) {
        simpleName = selectedSimple.variation;
    }
    
    [self.chosenSimpleNames replaceObjectAtIndex:self.picker.tag withObject:simpleName];
    
    [self closePicker];
    [self.collectionView reloadData];
    
    if (self.selectedSizeAndAddToCart)
    {
        JACatalogCell *cell = (JACatalogCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.picker.tag
                                                                                                               inSection:0]];
        
        [cell.sizeButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
        [cell.sizeButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
        
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
