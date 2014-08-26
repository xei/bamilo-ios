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

@end

@implementation JACatalogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    
    if (self.searchString.length > 0) {
        
        [self showLoading];
        
        [RISearchSuggestion getResultsForSearch:self.searchString
                                           page:@"1"
                                       maxItems:[NSString stringWithFormat:@"%d",JACatalogViewControllerMaxProducts]
                                   successBlock:^(NSArray *results) {
                                       
                                       [self hideLoading];
                                       self.productsArray = [results mutableCopy];
                                       
                                       [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                       
                                   } andFailureBlock:^(NSArray *errorMessages) {
                                       
                                       [self hideLoading];
                                       
                                       [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                                   message:@"Error processing request"
                                                                  delegate:nil
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:@"Ok", nil] show];
                                   }];
        
    }
    
    [self changeToList];
    
    NSArray* sortList = [NSArray arrayWithObjects:@"Best Rating", @"Popularity", @"New In", @"Price Up", @"Price Down", @"Name", @"Brand", nil];
    
    self.sortingMethod = NSIntegerMax;
    //this will trigger load methods
    [self.sortingScrollView setOptions:sortList];
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
                                           page:[NSString stringWithFormat:@"%d", [self getCurrentPage]+1]
                                       maxItems:[NSString stringWithFormat:@"%d",JACatalogViewControllerMaxProducts]
                                   successBlock:^(NSArray *results) {
                                       
                                       if (0 == results.count || JACatalogViewControllerMaxProducts > results.count) {
                                           self.loadedEverything = YES;
                                       }
                                       
                                       [self.productsArray addObjectsFromArray:results];
                                       
                                       [self.collectionView reloadData];
                                       
                                       [self hideLoading];
                                       
                                   } andFailureBlock:^(NSArray *errorMessages) {
                                       
                                       [self hideLoading];
                                       
                                       [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                                   message:@"Error processing request"
                                                                  delegate:nil
                                                         cancelButtonTitle:nil
                                                         otherButtonTitles:@"Ok", nil] show];
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
                                    successBlock:^(NSArray* products, NSArray* filters, NSArray* categories) {
                                        
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
    
    JAPDVViewController *pdv = [self.storyboard instantiateViewControllerWithIdentifier:@"pdvViewController"];
    pdv.productUrl = product.url;
    pdv.fromCatalogue = YES;
    pdv.previousCategory = self.category.name;
    pdv.arrayWithRelatedItems = [tempArray copy];
    pdv.delegate = self;
    
    [self.navigationController pushViewController:pdv
                                         animated:YES];
}

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{
    if (index != self.sortingMethod) {
        self.sortingMethod = index;
        
        [self resetCatalog];
        [self loadMoreProducts];
    }
}

#pragma mark - JAMainFiltersViewControllerDelegate

- (void)updatedFiltersAndCategory:(RICategory *)category;
{
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
                                        [self hideLoading];
                                    } andFailureBlock:^(NSArray *error) {
                                        [self hideLoading];
                                    }];
                                } andFailureBlock:^(NSArray *error) {
                                    [self hideLoading];
                                }];
    } else {
        [RIProduct removeFromFavorites:product successBlock:^(NSArray *favoriteProducts) {
            //update favoriteProducts
            [self hideLoading];
        } andFailureBlock:^(NSArray *error) {
            [self hideLoading];
        }];
    }
}

@end
