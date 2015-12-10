//
//  JACampaignPageView.m
//  Jumia
//
//  Created by Telmo Pinto on 29/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignPageView.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+JA.h"
#import "RICampaign.h"
#import "JAUtils.h"
#import "JAProductListFlowLayout.h"
#import "JACampaignBannerCell.h"
#import "JAProductCollectionViewFlowLayout.h"

@interface JACampaignPageView()

@property (nonatomic, strong) RICampaign* campaign;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) JAProductCollectionViewFlowLayout* flowLayout;
@property (nonatomic, strong) NSString* cellIdentifier;
@property (nonatomic, strong) UIImageView* bannerImage;
@property (nonatomic, assign) NSInteger elapsedTimeInSeconds;
@property (nonatomic, strong) NSMutableArray* chosenSimpleNames;
@property (nonatomic, strong) JACampaignProductCell* lastPressedCampaignProductCell;

@end

@implementation JACampaignPageView

@synthesize interfaceOrientation=_interfaceOrientation;
-(void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation != _interfaceOrientation) {
        _interfaceOrientation = interfaceOrientation;
        [self reloadViewToInterfaceOrientation:interfaceOrientation];
    }
}

@synthesize bannerImage = _bannerImage;
- (UIImageView*)bannerImage
{
    if (VALID_NOTEMPTY(_bannerImage, UIImageView)) {
        //do nothing
    } else {
        _bannerImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     0.0f,
                                                                     1.0f,
                                                                     1.0f)];
        
        if (VALID_NOTEMPTY(self.campaign.bannerImageURL, NSString)) {
            __block UIImageView *blockedImageView = _bannerImage;
            __weak JACampaignPageView* weakSelf = self;
            [_bannerImage setImageWithURL:[NSURL URLWithString:self.campaign.bannerImageURL]
                                  success:^(UIImage *image, BOOL cached){
                                      [blockedImageView changeImageHeight:0.0f andWidth:weakSelf.frame.size.width];
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [weakSelf.collectionView reloadData];
                                      });
                                  }failure:^(NSError *error){}];
        }
    }
    return _bannerImage;
}

- (void)loadWithCampaign:(RICampaign*)campaign
{
    [self setBackgroundColor:[UIColor whiteColor]];
    if (NO == self.isLoaded) {
        self.isLoaded = YES;
        
        self.campaign = campaign;
        
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:self.campaign.name forKey:kRIEventCampaignKey];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewCampaign] data:trackingDictionary];
        
        
        
        self.chosenSimpleNames = [NSMutableArray new];
        for (int i = 0; i < self.campaign.campaignProducts.count; i++) {
            [self.chosenSimpleNames addObject:@""];
        }
        
        self.elapsedTimeInSeconds = 0;
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateSeconds)
                                       userInfo:nil
                                        repeats:YES];
        
        self.flowLayout = [[JAProductCollectionViewFlowLayout alloc] init];
        self.flowLayout.minimumLineSpacing = 1.0f;
        self.flowLayout.minimumInteritemSpacing = 0.f;
        [self.flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"horizontalSeparator"];
        [self.flowLayout registerClass:[JACollectionSeparator class] forDecorationViewOfKind:@"verticalSeparator"];
        
        //                                              top, left, bottom, right
        [self.flowLayout setSectionInset:UIEdgeInsetsMake(0.f, 0.0, 0.0, 0.0)];
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        if (VALID_NOTEMPTY(campaign.bannerImageURL, NSString)) {
            [self.flowLayout setHasBanner:YES];
        }
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self addSubview:self.collectionView];
        
        [self.collectionView registerClass:[JACampaignProductCell class] forCellWithReuseIdentifier:@"campaignProductCell"];
        [self.collectionView registerClass:[JACampaignBannerCell class] forCellWithReuseIdentifier:@"campaignBannerCell"];
        
        
        [self reloadViewToInterfaceOrientation:self.interfaceOrientation];
    }
}

- (void)reloadViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.bannerImage = nil;
    
    self.cellIdentifier = @"campaignProductCell";
    
    [self.collectionView setFrame:self.bounds];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CGFloat numberOfCells = self.campaign.campaignProducts.count;
    if (VALID_NOTEMPTY(self.campaign.bannerImageURL, NSString)) {
        numberOfCells++;
    }
    return numberOfCells;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (VALID_NOTEMPTY(self.campaign.bannerImageURL, NSString) && 0 == indexPath.row) {
        return self.bannerImage.frame.size;
    }
    CGSize size = [self getCellLayoutForInterfaceOrientation:self.interfaceOrientation];
    self.flowLayout.itemSize = CGSizeMake(size.width, size.height);
    return size;
}

- (CGSize)getCellLayoutForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat width = 0.0f;
    CGFloat height = 482.f;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        if(UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
            width = 384.0f;
        } else {
            width = 341.0f;
        }
    } else {
        width = 320;
    }
    
    return CGSizeMake(width, height);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger realIndex = indexPath.row;
    BOOL campaignHasBanner = NO;
    if (VALID_NOTEMPTY(self.campaign.bannerImageURL, NSString)) {
        campaignHasBanner = YES;
        if (0 == indexPath.row) {
            JACampaignBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"campaignBannerCell" forIndexPath:indexPath];
            [cell loadWithImageView:self.bannerImage];
            return cell;
        }
        realIndex--;
    }
    JACampaignProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    cell.delegate = self;
    cell.tag = realIndex;
    
    RICampaignProduct* product = [self.campaign.campaignProducts objectAtIndex:realIndex];
    
    NSString* chosenSimpleName = [self.chosenSimpleNames objectAtIndex:realIndex];
    
    [cell loadWithCampaignProduct:product
             elapsedTimeInSeconds:self.elapsedTimeInSeconds
                       chosenSize:chosenSimpleName
                 capaignHasBanner:campaignHasBanner];
    
    return cell;
}

#pragma mark - Timer

- (void)updateSeconds
{
    self.elapsedTimeInSeconds++;
}

#pragma mark - JACampaignProductCellDelegate

- (void)pressedAddToCartForProduct:(RICampaignProduct*)campaignProduct
                 withProductSimple:(NSString*)simpleSku;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addToCartForProduct:withProductSimple:)]) {
        [self.delegate addToCartForProduct:campaignProduct withProductSimple:simpleSku];
    }
}

- (void)pressedCampaignProductWithTarget:(NSString*)targetString;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(openCampaignProductWithTarget:)]) {
        [self.delegate openCampaignProductWithTarget:targetString];
    }
}

- (void)pressedSizeOnView:(JACampaignProductCell*)campaignProductCell;
{
    self.lastPressedCampaignProductCell = campaignProductCell;
    
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    NSString *simpleSize = @"";
    if(VALID_NOTEMPTY(campaignProductCell.campaignProduct.productSimples, NSArray))
    {
        for (int i = 0; i < campaignProductCell.campaignProduct.productSimples.count; i++)
        {
            RICampaignProductSimple* simple = [campaignProductCell.campaignProduct.productSimples objectAtIndex:i];
            [dataSource addObject:simple.size];
            if ([simple.size isEqualToString:campaignProductCell.chosenSize])
            {
                //found it
                simpleSize = simple.size;
            }
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(openPickerForCampaignPage:dataSource:previousText:)]) {
        [self.delegate openPickerForCampaignPage:self
                                      dataSource:[dataSource copy]
                                    previousText:simpleSize];
    }
}

- (void)selectedSizeIndex:(NSInteger)index;
{
    RICampaignProductSimple* selectedSimple = [self.lastPressedCampaignProductCell.campaignProduct.productSimples objectAtIndex:index];
    [self.chosenSimpleNames replaceObjectAtIndex:self.lastPressedCampaignProductCell.tag withObject:selectedSimple.size];
    
    if (NOT_NIL(self.lastPressedCampaignProductCell.onSelected)) {
        self.lastPressedCampaignProductCell.chosenSize = selectedSimple.size;
        self.lastPressedCampaignProductCell.onSelected();
    }
    [self.collectionView reloadData];
}

@end
