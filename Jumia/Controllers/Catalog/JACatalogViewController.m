//
//  JACatalogViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACatalogViewController.h"
#import "RIProduct.h"
#import "JACatalogListCell.h"
#import "JACatalogGridCell.h"
#import "RISearchSuggestion.h"
#import "RICustomer.h"

#define JACatalogViewControllerButtonColor UIColorFromRGB(0xe3e3e3);
#define JACatalogViewControllerMaxProducts 36

@interface JACatalogViewController ()

@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *viewToggleButton;
@property (weak, nonatomic) IBOutlet JAPickerScrollView *sortingScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *catalogTopButton;
@property (nonatomic, strong) UICollectionViewFlowLayout* flowLayout;
@property (nonatomic, strong) NSMutableArray* productsArray;
@property (nonatomic, strong) NSArray* filtersArray;
@property (nonatomic, strong) NSArray* categoriesArray;
@property (nonatomic, strong) RICategory* filterCategory;
@property (nonatomic, assign) BOOL loadedEverything;
@property (nonatomic, assign) RICatalogSorting sortingMethod;
@property (nonatomic, strong) JAUndefinedSearchView *undefinedView;
@property (nonatomic, strong) RIUndefinedSearchTerm *undefinedBackup;
@property (assign, nonatomic) CGRect backupFrame;
@property (assign, nonatomic) BOOL isFirstLoad;
@property (assign, nonatomic) BOOL isFirstLoadTracking;

@end

@implementation JACatalogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.forceShowBackButton)
    {
        self.navBarLayout.showBackButton = YES;
    }

    self.isFirstLoad = YES;
    self.isFirstLoadTracking = NO;
    self.filterButton.backgroundColor = JACatalogViewControllerButtonColor;
    self.viewToggleButton.backgroundColor = JACatalogViewControllerButtonColor;
    
    self.sortingScrollView.delegate = self;

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UINib *gridCellNib = [UINib nibWithNibName:@"JACatalogGridCell" bundle:nil];
    [self.collectionView registerNib:gridCellNib forCellWithReuseIdentifier:@"gridCell"];
    UINib *listCellNib = [UINib nibWithNibName:@"JACatalogListCell" bundle:nil];
    [self.collectionView registerNib:listCellNib forCellWithReuseIdentifier:@"listCell"];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 0;
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:self.flowLayout];
    
    [self changeToList];
    
    NSArray* sortList = [NSArray arrayWithObjects:STRING_BEST_RATING, STRING_POPULARITY, STRING_NEW_IN, STRING_PRICE_UP, STRING_PRICE_DOWN, STRING_NAME, STRING_BRAND, nil];
    
    self.sortingMethod = NSIntegerMax;
    //this will trigger load methods
    [self.sortingScrollView setOptions:sortList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
    
    if (self.undefinedView) {
        [self.undefinedView removeFromSuperview];
        
        [self addUndefinedSearchView:self.undefinedBackup];
    }
    
    if (self.isFirstLoad)
    {
        [self showLoading];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.isFirstLoad) {
        [self swipeLeft:nil];
        self.isFirstLoad = NO;
        
        [self hideLoading];
    }
}

- (void)resetCatalog
{
    //[self.collectionView setContentOffset:CGPointZero animated:NO];
    
    self.productsArray = [NSMutableArray new];
    
    self.loadedEverything = NO;
}

- (void)loadMoreProducts
{
    if (self.searchString.length > 0)
    {
        // In case of this is a search
        
        [self showLoading];
        
        [RISearchSuggestion getResultsForSearch:self.searchString
                                           page:@"1"
                                       maxItems:[NSString stringWithFormat:@"%d",JACatalogViewControllerMaxProducts]
                                   successBlock:^(NSArray *results) {
                                       
                                       if (!self.isFirstLoadTracking) {
                                           self.isFirstLoadTracking = YES;
                                           
                                           [[RITrackingWrapper sharedInstance] trackEvent:self.searchString
                                                                                    value:@(results.count)
                                                                                   action:@"Search"
                                                                                 category:@"Catalog"
                                                                                     data:nil];
                                       }
                                       
                                       if (0 == results.count || JACatalogViewControllerMaxProducts > results.count) {
                                           self.loadedEverything = YES;
                                       }
                                       
                                       self.navBarLayout.subTitle = [NSString stringWithFormat:@"%d", results.count];
                                       
                                       [self.productsArray addObjectsFromArray:results];
                                       
                                       [self.collectionView reloadData];
                                       
                                       [self hideLoading];
                                       
                                   } andFailureBlock:^(NSArray *errorMessages, RIUndefinedSearchTerm *undefSearchTerm) {
                                       
                                       [self hideLoading];
                                       
                                       if (undefSearchTerm) {
                                           self.navBarLayout.subTitle = @"0";
                                           [self reloadNavBar];
                                           self.undefinedBackup = undefSearchTerm;
                                           self.backupFrame = self.collectionView.frame;
                                           [self addUndefinedSearchView:undefSearchTerm];
                                       } else {
                                           [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                                                       message:@"Error processing request temp"
                                                                      delegate:nil
                                                             cancelButtonTitle:nil
                                                             otherButtonTitles:STRING_OK, nil] show];
                                       }
                                   }];
    }
    else
    {
        if (NO == self.loadedEverything) {
            
            [self showLoading];
            
            NSString* urlToUse = self.catalogUrl;
            if (VALID_NOTEMPTY(self.category, RICategory) && VALID_NOTEMPTY(self.category.apiUrl, NSString)) {
                urlToUse = self.category.apiUrl;
            }
            if (VALID_NOTEMPTY(self.filterCategory, RICategory) && VALID_NOTEMPTY(self.filterCategory.apiUrl, NSString)) {
                urlToUse = self.filterCategory.apiUrl;
            }
            [RIProduct getProductsWithCatalogUrl:urlToUse
                                   sortingMethod:self.sortingMethod
                                            page:[self getCurrentPage]+1
                                        maxItems:JACatalogViewControllerMaxProducts
                                         filters:self.filtersArray
                                    successBlock:^(NSArray* products, NSString* productCount, NSArray* filters, NSArray* categories) {
                                        
                                        self.navBarLayout.subTitle = productCount;
                                        [self reloadNavBar];
                                        
                                        if (ISEMPTY(self.filtersArray) && NOTEMPTY(filters)) {
                                            self.filtersArray = filters;
                                        }
                                        
                                        if (NOTEMPTY(categories)) {
                                            self.categoriesArray = categories;
                                        }
                                        
                                        if (0 == products.count || JACatalogViewControllerMaxProducts > products.count) {
                                            self.loadedEverything = YES;
                                        }
                                        
                                        [self.productsArray addObjectsFromArray:products];
                                        
                                        [self.collectionView reloadData];
                                        
                                        [self hideLoading];
                                        
                                    } andFailureBlock:^(NSArray *error) {
                                        [self hideLoading];
                                        [self resetCatalog];
                                        [self.collectionView reloadData];
                                    }];
        }
    }
}

- (NSInteger)getCurrentPage
{
    if (self.productsArray.count) {
        return self.productsArray.count / JACatalogViewControllerMaxProducts;
    } else {
        return 0;
    }
}

#pragma mark - Actions

- (IBAction)swipeRight:(id)sender
{
    [self.sortingScrollView scrollRight];
}

- (IBAction)swipeLeft:(id)sender
{
    [self.sortingScrollView scrollLeft];
}

- (void)changeToList
{
    [UIView transitionWithView:self.collectionView
                      duration:.3
                       options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        
                        //use view instead of collection view, the list cell has the insets inside itself;
                        self.flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, JACatalogViewControllerListCellHeight);
                        self.flowLayout.minimumInteritemSpacing = 0.0f;
                        
                    } completion:^(BOOL finished) {
                        
                    }];
    [self.collectionView reloadData];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[RICustomer getCustomerId]
                                             value:nil
                                            action:@"List"
                                          category:@"Catalog"
                                              data:nil];
}

- (void)changeToGrid
{
    [UIView transitionWithView:self.collectionView
                      duration:.3
                       options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        
                        self.flowLayout.itemSize = CGSizeMake((self.collectionView.frame.size.width / 2) - 2, JACatalogViewControllerGridCellHeight);
                        self.flowLayout.minimumInteritemSpacing = 3.0f;
                        
                    } completion:^(BOOL finished) {
                        
                    }];
    [self.collectionView reloadData];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[RICustomer getCustomerId]
                                             value:nil
                                            action:@"Grid"
                                          category:@"Catalog"
                                              data:nil];
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(3, 0, 0, 0);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) {
        self.catalogTopButton.hidden = YES;
    }
    
    if ((YES == self.viewToggleButton.selected && 7 <= indexPath.row) ||
        (NO == self.viewToggleButton.selected && 5 <= indexPath.row)) {
        self.catalogTopButton.hidden = NO;
    }
    
    if (self.productsArray.count - 5 == indexPath.row) {
        [self loadMoreProducts];
    }
    
    RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier;
    if (self.viewToggleButton.selected) {
        cellIdentifier = @"gridCell";
    }else{
        cellIdentifier = @"listCell";
    }
    
    JACatalogCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.favoriteButton.tag = indexPath.row;
    [cell.favoriteButton addTarget:self
                            action:@selector(addToFavoritesPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    [cell loadWithProduct:product];
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
    
    NSInteger count = self.productsArray.count;
    
    if (count > 20) {
        count = 20;
    }
    
    NSMutableArray *tempArray = [NSMutableArray new];
    
    for (int i = 0 ; i < count ; i ++) {
        [tempArray addObject:[self.productsArray objectAtIndex:i]];
    }
    
    NSString *temp = self.category.name;
    
    if (temp.length > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"url" : product.url,
                                                                      @"previousCategory" : temp,
                                                                      @"fromCatalog" : @"YES",
                                                                      @"relatedItems" : tempArray ,
                                                                      @"delegate": self }];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"url" : product.url,
                                                                      @"fromCatalog" : @"YES",
                                                                      @"previousCategory" : @"",
                                                                      @"relatedItems" : tempArray ,
                                                                      @"delegate": self }];
    }
    
//    JAPDVViewController *pdv = [self.storyboard instantiateViewControllerWithIdentifier:@"pdvViewController"];
//    pdv.productUrl = product.url;
//    pdv.fromCatalogue = YES;
//    pdv.previousCategory = self.category.name;
//    pdv.arrayWithRelatedItems = [tempArray copy];
//    pdv.delegate = self;
//    
//    [self.navigationController pushViewController:pdv
//                                         animated:YES];
}

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{
    if (index != self.sortingMethod) {
        self.sortingMethod = index;
        
        [self resetCatalog];
        [self loadMoreProducts];
        
        [[RITrackingWrapper sharedInstance] trackEvent:self.title
                                                 value:nil
                                                action:@"SortingOnCatalog"
                                              category:@"Catalog"
                                                  data:nil];
    }
}

#pragma mark - JAMainFiltersViewControllerDelegate

- (void)updatedFiltersAndCategory:(RICategory *)category;
{
    [[RITrackingWrapper sharedInstance] trackEvent:self.catalogUrl
                                             value:nil
                                            action:STRING_FILTERS
                                          category:@"Catalog"
                                              data:nil];
    
    self.filterCategory = category;
    [self resetCatalog];
    [self loadMoreProducts];
}

#pragma mark - JAPDVViewControllerDelegate

- (void)changedFavoriteStateOfProduct:(RIProduct*)product;
{
    for (int i = 0; i < self.productsArray.count; i++) {
        RIProduct* currentProduct = [self.productsArray objectAtIndex:i];
        currentProduct.isFavorite = product.isFavorite;
        if ([currentProduct.sku isEqualToString:product.sku]) {
            [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]]];
        }
    }
}

#pragma mark - Button actions

- (IBAction)filterButtonPressed:(id)sender
{
    JAMainFiltersViewController *mainFiltersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainFiltersViewController"];
    mainFiltersViewController.filtersArray = self.filtersArray;
    mainFiltersViewController.categoriesArray = self.categoriesArray;
    mainFiltersViewController.selectedCategory = self.filterCategory;
    mainFiltersViewController.delegate = self;
    [self.navigationController pushViewController:mainFiltersViewController
                                         animated:YES];
}

- (IBAction)viewButtonPressed:(id)sender
{
    //reverse selection
    self.viewToggleButton.selected = !self.viewToggleButton.selected;
    
    if (self.viewToggleButton.selected) {
        [self changeToGrid];
    } else {
        [self changeToList];
    }
}

- (IBAction)catalogTopButtonPressed:(id)sender
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)addToFavoritesPressed:(UIButton*)button
{
    button.selected = !button.selected;
    
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    product.isFavorite = [NSNumber numberWithBool:button.selected];
    [self showLoading];
    if (button.selected) {
        //add to favorites
        [RIProduct getCompleteProductWithUrl:product.url
                                successBlock:^(id completeProduct) {
                                    [RIProduct addToFavorites:completeProduct successBlock:^{
                                        
                                        [[RITrackingWrapper sharedInstance] trackEvent:product.sku
                                                                                 value:product.price
                                                                                action:@"AddtoWishlist"
                                                                              category:@"Catalog"
                                                                                  data:nil];
                                        
                                        [self hideLoading];
                                    } andFailureBlock:^(NSArray *error) {
                                        [self hideLoading];
                                    }];
                                } andFailureBlock:^(NSArray *error) {
                                    [self hideLoading];
                                }];
    } else {
        [RIProduct removeFromFavorites:product successBlock:^(NSArray *favoriteProducts) {
            
            [[RITrackingWrapper sharedInstance] trackEvent:product.sku
                                                     value:product.price
                                                    action:@"RemoveFromWishlist"
                                                  category:@"Catalog"
                                                      data:nil];
            
            //update favoriteProducts
            [self hideLoading];
        } andFailureBlock:^(NSArray *error) {
            [self hideLoading];
        }];
    }
}

#pragma mark - Add the undefined search view

- (void)addUndefinedSearchView:(RIUndefinedSearchTerm *)undefSearch
{
    self.undefinedView = [JAUndefinedSearchView getNewJAUndefinedSearchView];
    self.undefinedView.delegate = self;
    CGRect frame = self.backupFrame;
    frame.origin.y += 6;
    frame.size.height -= 12;
    
    [self.undefinedView setFrame:frame];
    
    // Remove the existent components
    self.filterButton.userInteractionEnabled = NO;
    self.viewToggleButton.userInteractionEnabled = NO;
    self.sortingScrollView.disableDelagation = YES;
    [self.collectionView removeFromSuperview];
    [self.catalogTopButton removeFromSuperview];
    
    // Build and add the new view
    [self.view addSubview:self.undefinedView];
    
    [self.undefinedView setupWithUndefinedSearchResult:undefSearch
                                            searchText:self.searchString];
}

#pragma mark - Undefined view delegate

- (void)didSelectProduct:(NSString *)productUrl
{
    JAPDVViewController *pdv = [self.storyboard instantiateViewControllerWithIdentifier:@"pdvViewController"];
    pdv.productUrl = productUrl;
    pdv.fromCatalogue = NO;
    pdv.previousCategory = self.category.name;
    pdv.delegate = self;
    
    [self.navigationController pushViewController:pdv
                                         animated:YES];
}

- (void)didSelectBrand:(NSString *)brandUrl
             brandName:(NSString *)brandName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(98),
                                                                 @"name": brandName,
                                                                 @"url": brandUrl }];
}

@end
