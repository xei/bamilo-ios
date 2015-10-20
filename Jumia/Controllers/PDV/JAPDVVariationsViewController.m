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
    CGRect frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    if (!VALID_NOTEMPTY(_collectionView, UICollectionView)) {
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 64.f;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    else {
        if (!CGRectEqualToRect(frame, _collectionView.frame)) {
            [_collectionView.collectionViewLayout invalidateLayout];
            [_collectionView setFrame:frame];
        }
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self clearAllViewsFromCollectionView];
    [self.collectionView reloadData];
    [self collectionView];
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
    
    NSInteger nVariations = [self.collectionView numberOfItemsInSection:0];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIDeviceOrientationPortrait == ([UIDevice currentDevice].orientation) || UIDeviceOrientationPortraitUpsideDown == ([UIDevice currentDevice].orientation)) {
            [self drawSeparators:(int)nVariations collectionView:collectionView];
            return CGSizeMake(self.bounds.size.width - 64.f, 104.0f);
        } else {
            if (nVariations % 2 == 0) {
                nVariations = nVariations/2;
            }
            else{
                nVariations = (nVariations+1)/2;
            }
            [self drawSeparators:(int)nVariations collectionView:collectionView];
            return CGSizeMake((self.bounds.size.width/2) - 64.f, 104.0f);
        }
    } else {
        return CGSizeMake(self.view.frame.size.width - 12.f, 104.0f);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0,32,0,32);
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

- (void)clearAllViewsFromCollectionView {
    for (UIView *aView in [self.collectionView subviews]) {
        if ([aView isKindOfClass:UIView.class]) {
            [aView removeFromSuperview];
        }
    }
}

- (void)drawSeparators:(int)nLines collectionView:(UICollectionView *)collectionView{
    for (int i = 1; i<=nLines; i++) {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 104.0f*i, self.bounds.size.width, 1)];
        [separator setBackgroundColor:[UIColor colorWithRed:0.867 green:0.878 blue:0.878 alpha:1]];
        [collectionView addSubview:separator];
    }
}
@end
