//
//  JAPDVVariationsViewController.m
//  Jumia
//
//  Created by josemota on 10/5/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVVariationsViewController.h"
#import "JAPDVVariationsCollectionViewCell.h"

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
        layout.minimumInteritemSpacing = 0.f;
        layout.minimumLineSpacing = 0.f;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    else {
        if (!CGRectEqualToRect(frame, _collectionView.frame)) {
            [_collectionView reloadData];
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
    [self.collectionView registerClass:[JAPDVVariationsCollectionViewCell class] forCellWithReuseIdentifier:@"CellWithLines"];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self collectionView];
}

#pragma mark - collectionView methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RIVariation *variationProduct = [self.variations objectAtIndex:indexPath.row];
    
    JAPDVVariationsCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"CellWithLines" forIndexPath:indexPath];
    
    cell.favoriteButton.tag = indexPath.row;
    [cell.favoriteButton addTarget:self
                            action:@selector(addToFavoritesPressed:)
                  forControlEvents:UIControlEventTouchUpInside];
    
    cell.feedbackView.tag = indexPath.row;
    [cell.feedbackView addTarget:self
                          action:@selector(clickableViewPressedInCell:)
                forControlEvents:UIControlEventTouchUpInside];
    
    [cell loadWithVariation:variationProduct];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIDeviceOrientationPortrait == ([UIDevice currentDevice].orientation) || UIDeviceOrientationPortraitUpsideDown == ([UIDevice currentDevice].orientation)) {
            cell.rightVerticalSeparator.hidden = YES;
            if (indexPath.row == 0) {
                cell.topHorizontalSeparator.hidden = NO;
            }
            else{
                cell.topHorizontalSeparator.hidden = YES;
            }
            
        }else{
            
            if (indexPath.row == 0 || indexPath.row == 1) {
                cell.topHorizontalSeparator.hidden = NO;
            }
            else{
               cell.topHorizontalSeparator.hidden = YES;
            }
            if (indexPath.row % 2 == 0) {
                cell.rightVerticalSeparator.hidden = NO;
            }
            else{
                cell.rightVerticalSeparator.hidden = YES;
            }
            
        }
    }
    else {
        cell.rightVerticalSeparator.hidden = YES;
        if (indexPath.row == 0) {
            cell.topHorizontalSeparator.hidden = NO;
        }
        else{
            cell.topHorizontalSeparator.hidden = YES;
        }
    }
    

    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.variations.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIDeviceOrientationPortrait == ([UIDevice currentDevice].orientation) || UIDeviceOrientationPortraitUpsideDown == ([UIDevice currentDevice].orientation)) {

            return CGSizeMake(self.bounds.size.width, 104.0f);

        } else {
            return CGSizeMake((self.bounds.size.width/2), 104.0f);
        }
    } else {
        return CGSizeMake(self.view.frame.size.width, 104.0f);
    }
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
