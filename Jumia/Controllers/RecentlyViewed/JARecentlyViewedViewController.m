//
//  JARecentlyViewedViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARecentlyViewedViewController.h"
#import "JACatalogListCell.h"
#import "JAButtonCell.h"
#import "JAPDVViewController.h"
#import "RIProduct.h"
#import "RICart.h"

@interface JARecentlyViewedViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyListView;
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray* productsArray;

@end

@implementation JARecentlyViewedViewController

@synthesize productsArray=_productsArray;
- (void)setProductsArray:(NSArray *)productsArray
{
    _productsArray = productsArray;
    [self.collectionView reloadData];
    if (ISEMPTY(productsArray)) {
        self.emptyListView.hidden = NO;
        self.collectionView.hidden = YES;
    } else {
        self.emptyListView.hidden = YES;
        self.collectionView.hidden = NO;
    }
}

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
    UINib *buttonCellNib = [UINib nibWithNibName:@"JAGrayButtonCell" bundle:nil];
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
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {
        [self hideLoading];
        self.productsArray = recentlyViewedProducts;
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
    return self.productsArray.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.productsArray.count) {
        
        NSString *cellIdentifier = @"buttonCell";
        
        JAButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell loadWithButtonName:@"Clear Recently Viewed"];
        
        [cell.button addTarget:self
                        action:@selector(clearAllButtonPressed)
              forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
        
    } else {
        RIProduct *product = [self.productsArray objectAtIndex:indexPath.row];
        
        NSString *cellIdentifier = @"recentlyViewedListCell";
        
        JACatalogListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        [cell loadWithProduct:product];
        cell.addToCartButton.tag = indexPath.row;
        [cell.addToCartButton addTarget:self
                                 action:@selector(addToCartPressed:)
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
        pdv.previousCategory = @"Recently Viewed";
        pdv.arrayWithRelatedItems = [tempArray copy];
        
        [self.navigationController pushViewController:pdv
                                             animated:YES];
    }
}

#pragma mark - Button Actions

- (void)addToCartPressed:(UIButton*)button;
{
    RIProduct* product = [self.productsArray objectAtIndex:button.tag];
    
    [self showLoading];
    [RICart addProductWithQuantity:@"1"
                               sku:product.sku
                            simple:((RIProduct *)[product.productSimples firstObject]).sku
                  withSuccessBlock:^(RICart *cart) {

                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      
                      [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                  message:@"Product added"
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"Ok", nil] show];
                      
                      [self hideLoading];
                      
                  } andFailureBlock:^(NSArray *errorMessages) {
                      
                      [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                  message:@"Error adding to the cart"
                                                 delegate:nil
                                        cancelButtonTitle:nil
                                        otherButtonTitles:@"Ok", nil] show];
                      
                      [self hideLoading];
                      
                  }];
}


- (void)clearAllButtonPressed
{
    [self showLoading];
    [RIProduct removeAllRecentlyViewedWithSuccessBlock:^{
        [self hideLoading];
        self.productsArray = nil;
    } andFailureBlock:^(NSArray *error) {
        [self hideLoading];
    }];
}

@end
