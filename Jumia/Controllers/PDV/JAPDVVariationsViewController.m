//
//  JAPDVVariationsViewController.m
//  Jumia
//
//  Created by josemota on 10/5/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVVariationsViewController.h"
#import "JACatalogListCollectionViewCell.h"

@interface JAPDVVariationsViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) UICollectionView *collectionView;

@end

@implementation JAPDVVariationsViewController

@synthesize variations = _variations;

- (UICollectionView *)collectionView
{
    if (!VALID_NOTEMPTY(_collectionView, UICollectionView)) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (NSArray *)variations
{
    if (!VALID_NOTEMPTY(_variations, NSArray)) {
        _variations = [NSArray new];
    }
    return _variations;
}

- (void)setVariations:(NSArray *)variations
{
    _variations = [variations copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    self.navBarLayout.showBackButton = YES;
    
    [self.collectionView registerClass:[JACatalogListCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogListCollectionViewCell"];
}

#pragma mark - collectionView methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIVariation *variationProduct = [self.variations objectAtIndex:indexPath.row];
    
    JACatalogCollectionViewCell *cell = (JACatalogCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogListCollectionViewCell" forIndexPath:indexPath];
    
    cell.favoriteButton.tag = indexPath.row;
    [cell.favoriteButton addTarget:self
                            action:@selector(addToFavoritesPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    cell.feedbackView.tag = indexPath.row;
    [cell.feedbackView addTarget:self
                          action:@selector(clickableViewPressedInCell:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [cell loadWithVariation:variationProduct];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.variations.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.width, JACatalogViewControllerListCellHeight);
}

#pragma mark - actions

- (void)addToFavoritesPressed:(UIControl *)control
{
    NSLog(@"addToFavoritesPressed");
}

- (void)clickableViewPressedInCell:(UIControl *)control
{
    RIVariation *variationProduct = [self.variations objectAtIndex:control.tag];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"fromCatalog"];
    [userInfo setObject:self forKey:@"delegate"];
    if(VALID_NOTEMPTY(variationProduct.sku, NSString))
    {
        [userInfo setObject:variationProduct.sku forKey:@"sku"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
