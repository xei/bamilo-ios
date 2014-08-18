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
#import "JAPDVViewController.h"

#define JACatalogViewControllerButtonColor UIColorFromRGB(0xe3e3e3);
#define JACatalogViewControllerMaxProducts 36
#define JACatalogViewControllerListCellHeight 98.0f
#define JACatalogViewControllerGridCellHeight 196.0f

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
    [self changeToList];
    
    NSArray* sortList = [NSArray arrayWithObjects:@"Popularity", @"Best Rating", @"New In", @"Price Up", @"Price Down", @"Name", @"Brand", nil];
    
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
    if (VALID_NOTEMPTY(self.category, RICategory) && NO == self.loadedEverything) {
        [self showLoading];
        
        NSString* urlToUse = self.category.apiUrl;
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
                                    }];
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

- (void)changeToList
{
    [UIView transitionWithView:self.collectionView
                      duration:.3
                       options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseIn
                    animations:^{
                        
                        self.flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, JACatalogViewControllerListCellHeight);
                        
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
                        
                        self.flowLayout.itemSize = CGSizeMake(self.view.frame.size.width / 2, JACatalogViewControllerGridCellHeight);
                        
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
    
    if (5 <= indexPath.row) {
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
    pdv.product = product;
    pdv.fromCatalogue = YES;
    pdv.previousCategory = self.category.name;
    pdv.arrayWithRelatedItems = [tempArray copy];
    
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

@end
