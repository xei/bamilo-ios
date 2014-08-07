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

@interface JACatalogViewController ()

@property (weak, nonatomic) IBOutlet JAPickerScrollView *sortingScrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray* productsArray;

@end

@implementation JACatalogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sortingScrollView.delegate = self;

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"JACatalogGridCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"cvCell"];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.itemSize = CGSizeMake(160, 196); //320, 98);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    NSArray* sortList = [NSArray arrayWithObjects:@"Popularity", @"Best Rating", @"New In", @"Price Up", @"Price Down", @"Name", @"Brand", nil];
    
    [self.sortingScrollView setOptions:sortList];
    
    self.productsArray = [NSMutableArray new];
    
    if (VALID_NOTEMPTY(self.category, RICategory)) {
        [self showLoading];
        [RIProduct getProductsWithUrl:self.category.apiUrl successBlock:^(id products) {
            
            [self.productsArray addObjectsFromArray:products];
            
            [self.collectionView reloadData];
            
            [self hideLoading];
        } andFailureBlock:^(NSArray *error) {
            [self hideLoading];
        }];
    }
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
    
    RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"cvCell";
    
    JACatalogGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell loadWithProduct:product];
    
    return cell;
    
}

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{

}

@end
