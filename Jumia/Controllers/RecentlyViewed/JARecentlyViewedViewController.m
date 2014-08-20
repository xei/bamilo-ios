//
//  JARecentlyViewedViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARecentlyViewedViewController.h"
#import "JACatalogListCell.h"
#import "JAPDVViewController.h"
#import "RIProduct.h"

@interface JARecentlyViewedViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyListView;
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray* productsArray;

@end

@implementation JARecentlyViewedViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.collectionView.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    self.emptyListView.layer.cornerRadius = 3.0f;
    
    self.emptyListLabel.textColor = UIColorFromRGB(0xcccccc);
    self.emptyListLabel.text = @"No recently viewed products here";
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    UINib *listCellNib = [UINib nibWithNibName:@"JARecentlyViewedListCell" bundle:nil];
    [self.collectionView registerNib:listCellNib forCellWithReuseIdentifier:@"recentlyViewedListCell"];
    
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
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        
        [self hideLoading];
        self.productsArray = recentlyViewedProducts;
        
        if (ISEMPTY(recentlyViewedProducts)) {
            self.emptyListView.hidden = NO;
            self.collectionView.hidden = YES;
        } else {
            self.emptyListView.hidden = YES;
            self.collectionView.hidden = NO;
            [self.collectionView reloadData];
        }
    } andFailureBlock:^(NSArray *error) {
        [self hideLoading];
    }];
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
    
    NSString *cellIdentifier = @"recentlyViewedListCell";
    
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
    pdv.productUrl = product.url;
    pdv.fromCatalogue = YES;
    pdv.previousCategory = @"Recently Viewed";
    pdv.arrayWithRelatedItems = [tempArray copy];
    
    [self.navigationController pushViewController:pdv
                                         animated:YES];
}




@end
