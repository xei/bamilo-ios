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

#define JACatalogViewControllerButtonColor UIColorFromRGB(0xe3e3e3);
#define JACatalogViewControllerMaxProducts 36

@interface JACatalogViewController ()

@property (weak, nonatomic) IBOutlet UIButton *filterButton;
@property (weak, nonatomic) IBOutlet UIButton *viewToggleButton;
@property (weak, nonatomic) IBOutlet JAPickerScrollView *sortingScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout* flowLayout;
@property (nonatomic, strong) NSMutableArray* productsArray;
@property (nonatomic, assign) BOOL loadedEverything;

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
    
    [self.sortingScrollView setOptions:sortList];
    
    self.productsArray = [NSMutableArray new];
    
    self.loadedEverything = NO;
    
    [self loadMoreProducts];
}

- (void)loadMoreProducts
{
    if (VALID_NOTEMPTY(self.category, RICategory) && NO == self.loadedEverything) {
        [self showLoading];
        [RIProduct getProductsWithCatalogUrl:self.category.apiUrl
                               sortingMethod:RICatalogSortingPopularity
                                        page:[self getCurrentPage]+1
                                    maxItems:JACatalogViewControllerMaxProducts
                                successBlock:^(NSArray* products) {
                                    
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
                        
                        self.flowLayout.itemSize = CGSizeMake(320, 98);
                        
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
                        
                        self.flowLayout.itemSize = CGSizeMake(160, 196);
                        
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

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{

}

#pragma mark - Button actions

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


@end
