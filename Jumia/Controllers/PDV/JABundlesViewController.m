//
//  JAPDVVariationsViewController.m
//  Jumia
//
//  Created by josemota on 10/5/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JABundlesViewController.h"
#import "JACatalogListCollectionViewCell.h"
#import "JABottomBar.h"
#import "JAProductInfoSubLine.h"

@interface JABundlesViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) JABottomBar *bottomBar;
@property (nonatomic) NSMutableDictionary *selectedItems;
@property (nonatomic) JAProductInfoSubLine *totalSubLine;

@end

@implementation JABundlesViewController

@synthesize bundles = _bundles, totalSubLine = _totalSubLine;

- (NSArray *)bundles
{
    if (!VALID_NOTEMPTY(_bundles, NSArray)) {
        _bundles = [NSArray new];
    }
    return _bundles;
}

- (void)setBundles:(NSArray *)bundles
{
    _bundles = [bundles copy];
    for (RIProduct *product in _bundles) {
        [self.selectedItems setValue:product forKey:product.sku];
    }
    [self reloadPrice];
}

- (UICollectionView *)collectionView
{
    if (!VALID_NOTEMPTY(_collectionView, UICollectionView)) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        _collectionView = [[UICollectionView alloc] initWithFrame:self.viewBounds collectionViewLayout:layout];
        [_collectionView setBackgroundColor:[UIColor whiteColor]];
        _collectionView.height -= 64;
        _collectionView.height -= self.bottomBar.height;
        _collectionView.height -= self.totalSubLine.height;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (JABottomBar *)bottomBar
{
    if (!VALID_NOTEMPTY(_bottomBar, JABottomBar)) {
        _bottomBar = [[JABottomBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame) - 48, self.view.width, 48)];
        [_bottomBar addButton:@"Buy Combo" target:self action:@selector(addComboToCart)];
        [self.view addSubview:_bottomBar];
    }
    return _bottomBar;
}

- (NSMutableDictionary *)selectedItems
{
    if (!VALID_NOTEMPTY(_selectedItems, NSMutableDictionary)) {
        _selectedItems = [NSMutableDictionary new];
    }
    return _selectedItems;
}

- (JAProductInfoSubLine *)totalSubLine
{
    if (!VALID_NOTEMPTY(_totalSubLine, JAProductInfoSubLine)) {
        _totalSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame) - kProductInfoSubLineHeight, self.view.width, kProductInfoSubLineHeight)];
        [self.view addSubview:_totalSubLine];
    }
    return _totalSubLine;
}

#pragma mark - viewcontroller events

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navBarLayout.showBackButton = YES;
    
    [self.collectionView registerClass:[JACatalogListCollectionViewCell class] forCellWithReuseIdentifier:@"JACatalogListCollectionViewCell"];
}

#pragma mark - collectionView methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIProduct *bundleProduct = [self.bundles objectAtIndex:indexPath.row];
    
    JACatalogCollectionViewCell *cell = (JACatalogCollectionViewCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:@"JACatalogListCollectionViewCell" forIndexPath:indexPath];
    
    [cell loadWithProduct:bundleProduct];
    
    UIButton *select = [UIButton buttonWithType:UIButtonTypeCustom];
    [select setFrame:cell.favoriteButton.frame];
    select.tag = indexPath.row;
    [select setImage:[UIImage imageNamed:@"check_empty"] forState:UIControlStateNormal];
    [select setImage:[UIImage imageNamed:@"check"] forState:UIControlStateSelected];
    [select setImage:[UIImage imageNamed:@"check"] forState:UIControlStateHighlighted];
    [select setSelected:[self.selectedItems objectForKey:bundleProduct.sku]?YES:NO];
    [cell addSubview:select];
    [select addTarget:self action:@selector(itemSelection:) forControlEvents:UIControlEventTouchUpInside];
    [cell.favoriteButton setHidden:YES];

    cell.feedbackView.tag = indexPath.row;
    [cell.feedbackView addTarget:self
                          action:@selector(clickableViewPressedInCell:)
                forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bundles.count;
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
    RIVariation *bundleProduct = [self.bundles objectAtIndex:control.tag];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    [userInfo setObject:[NSNumber numberWithBool:NO] forKey:@"fromCatalog"];
    [userInfo setObject:self forKey:@"delegate"];
    if(VALID_NOTEMPTY(bundleProduct.sku, NSString))
    {
        [userInfo setObject:bundleProduct.sku forKey:@"sku"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)itemSelection:(UIControl *)control
{
    RIProduct *bundleProduct = [self.bundles objectAtIndex:control.tag];
    if ([self.selectedItems objectForKey:bundleProduct.sku]) {
        [control setSelected:NO];
        [self.selectedItems removeObjectForKey:bundleProduct.sku];
    }else{
        [control setSelected:YES];
        [self.selectedItems setValue:bundleProduct forKey:bundleProduct.sku];
    }
    [self reloadPrice];
}

- (void)addComboToCart
{
    NSLog(@"addComboToCart");
}

- (void)reloadPrice
{
    NSInteger totalPrice = 0;
    for (RIProduct *product in [self.selectedItems allValues]) {
        if (VALID_NOTEMPTY(product.specialPriceFormatted, NSString))
            totalPrice += product.specialPrice.integerValue;
        else
            totalPrice += product.price.integerValue;
    }
#warning TODO String§
    [self.totalSubLine.label setText:[NSString stringWithFormat:@"Total:  %ld", (long)totalPrice]];
    [self.totalSubLine.layer setBorderColor:[UIColor blackColor].CGColor];

    [self.totalSubLine.layer setBorderWidth:3];
    [self.totalSubLine.label sizeToFit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
