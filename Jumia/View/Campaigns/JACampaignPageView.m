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
#import "JABottomBar.h"

#define kLateralMargin 16
#define kTopMargin 48
#define kBetweenMargin 28
#define kButtonWidth 288

@interface JACampaignPageView()
{
    BOOL _hasBanner;
}

@property (nonatomic, strong) RICampaign* campaign;
@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) JAProductCollectionViewFlowLayout* flowLayout;
@property (nonatomic, strong) NSString* cellIdentifier;
@property (nonatomic, strong) UIImageView* bannerImageView;
@property (nonatomic, assign) NSInteger elapsedTimeInSeconds;
@property (nonatomic, strong) NSMutableArray* chosenSimpleNames;
@property (nonatomic, strong) JACampaignProductCell* lastPressedCampaignProductCell;

// This campaign is finished
@property (nonatomic, strong) UIView *noCampaignView;
@property (nonatomic, strong) UILabel *topMessageLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *bottomMessageLabel;
@property (nonatomic, strong) JABottomBar *bottomBar;

@end

@implementation JACampaignPageView

- (UIView *)noCampaignView
{
    if (!VALID_NOTEMPTY(_noCampaignView, UIView)) {
        _noCampaignView = [[UIView alloc] initWithFrame:self.bounds];
        [_noCampaignView setBackgroundColor:[UIColor whiteColor]];
        [_noCampaignView setHidden:YES];
        [_noCampaignView addSubview:self.topMessageLabel];
        [_noCampaignView addSubview:self.imageView];
        [_noCampaignView addSubview:self.bottomMessageLabel];
        [_noCampaignView addSubview:self.bottomBar];
        [self addSubview:_noCampaignView];
    }
    return _noCampaignView;
}

- (UILabel *)topMessageLabel
{
    if (!VALID_NOTEMPTY(_topMessageLabel, UILabel)) {
        _topMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, kButtonWidth, 200)];
        [_topMessageLabel setFont:JADisplay2Font];
        [_topMessageLabel setTextColor:JABlackColor];
        [_topMessageLabel setTextAlignment:NSTextAlignmentCenter];
        [_topMessageLabel setNumberOfLines:0];
        [_topMessageLabel setText:STRING_CAMPAIGN_IS_OVER];
        [_topMessageLabel sizeToFit];
        [_topMessageLabel setWidth:kButtonWidth];
    }
    return _topMessageLabel;
}

- (UIImageView *)imageView
{
    if (!VALID_NOTEMPTY(_imageView, UIImageView)) {
        UIImage *image = [UIImage imageNamed:@"ic_campaign_timer"];
        _imageView = [[UIImageView alloc] initWithImage:image];
        [_imageView setFrame:CGRectMake((self.width - image.size.width)/2, CGRectGetMaxY(self.topMessageLabel.frame) + kBetweenMargin, image.size.width, image.size.height)];
    }
    return _imageView;
}

- (UILabel *)bottomMessageLabel
{
    if (!VALID_NOTEMPTY(_bottomMessageLabel, UILabel)) {
        _bottomMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.imageView.frame) + kBetweenMargin, kButtonWidth, 200)];
        [_bottomMessageLabel setFont:JABody3Font];
        [_bottomMessageLabel setTextColor:JABlack800Color];
        [_bottomMessageLabel setTextAlignment:NSTextAlignmentCenter];
        [_bottomMessageLabel setNumberOfLines:0];
        [_bottomMessageLabel setText:STRING_CAMPAIGN_IS_OVER_RESUME];
        [_bottomMessageLabel sizeToFit];
        [_bottomMessageLabel setWidth:kButtonWidth];
    }
    return _bottomMessageLabel;
}

- (JABottomBar *)bottomBar
{
    if (!VALID_NOTEMPTY(_bottomBar, JABottomBar)) {
        _bottomBar = [[JABottomBar alloc] initWithFrame:CGRectMake((self.width - kButtonWidth)/2, CGRectGetMaxY(self.bottomMessageLabel.frame) + kBetweenMargin, kButtonWidth, kBottomDefaultHeight)];
        [_bottomBar addButton:[STRING_CONTINUE_SHOPPING uppercaseString] target:self action:@selector(goToHomeScreen)];
    }
    return _bottomBar;
}

@synthesize interfaceOrientation=_interfaceOrientation;
-(void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation != _interfaceOrientation) {
        _interfaceOrientation = interfaceOrientation;
        [self reloadViewToInterfaceOrientation:interfaceOrientation];
    }
}

@synthesize bannerImageView = _bannerImageView;
- (UIImageView*)bannerImageView
{
    if (VALID_NOTEMPTY(self.campaign.bannerImageURL, NSString)) {
        if (!VALID_NOTEMPTY(_bannerImageView, UIImageView)) {
            _bannerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f,
                                                                         0.0f,
                                                                         0.0f,
                                                                         0.0f)];
            
            __block UIImageView *blockedImageView = _bannerImageView;
            __weak JACampaignPageView* weakSelf = self;
            [_bannerImageView setImageWithURL:[NSURL URLWithString:self.campaign.bannerImageURL]
                                  success:^(UIImage *image, BOOL cached){
                                      _hasBanner = YES;
                                      [blockedImageView changeImageHeight:0.0f andWidth:weakSelf.frame.size.width];
                                      [weakSelf.collectionView reloadData];
                                  }failure:^(NSError *error){
                                      _hasBanner = NO;
                                  }];
        }
    }else{
        _hasBanner = NO;
        _bannerImageView = nil;
    }
    return _bannerImageView;
}

- (void)loadWithCampaign:(RICampaign*)campaign
{
    [self setBackgroundColor:[UIColor whiteColor]];
    if (VALID(campaign, RICampaign)) {
        [self.noCampaignView setHidden:YES];
    }else{
        [self.noCampaignView setHidden:NO];
        [self.noCampaignView setFrame:self.bounds];
        for (UIView *subView in self.noCampaignView.subviews) {
            [subView setXCenterAligned];
        }
        return;
    }
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
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = [UIColor clearColor];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        [self addSubview:self.collectionView];
        
        self.cellIdentifier = @"campaignProductCell";
        [self.collectionView registerClass:[JACampaignProductCell class] forCellWithReuseIdentifier:self.cellIdentifier];
        
        if (VALID_NOTEMPTY(self.campaign.bannerImageURL, NSString)) {
            [self.collectionView registerClass:[JACampaignBannerCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"campaignBannerCell"];
            [self bannerImageView];
        }
        
        
        [self reloadViewToInterfaceOrientation:self.interfaceOrientation];
    }
}

- (void)reloadViewToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (_hasBanner) {
        [self.bannerImageView changeImageHeight:0.0f andWidth:self.frame.size.width];
    }
    [self.collectionView setFrame:self.bounds];
    [self.collectionView reloadData];
}

- (void)setNoCampaigns:(BOOL)visible
{
    [self.noCampaignView setHidden:!visible];
}

- (void)goToHomeScreen
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.campaign.campaignProducts.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
    JACampaignProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier forIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    RICampaignProduct* product = [self.campaign.campaignProducts objectAtIndex:indexPath.row];
    
    NSString* chosenSimpleName = [self.chosenSimpleNames objectAtIndex:indexPath.row];
    
    [cell loadWithCampaignProduct:product
             elapsedTimeInSeconds:self.elapsedTimeInSeconds
                       chosenSize:chosenSimpleName];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader && _hasBanner) {
        
        JACampaignBannerCell *cell = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"campaignBannerCell" forIndexPath:indexPath];
        
        [cell loadWithImageView:self.bannerImageView];
        
        return cell;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (_hasBanner) {
        return self.bannerImageView.frame.size;
    }
    return CGSizeMake(0, 0);
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
            [dataSource addObject:simple.variation];
            if ([simple.variation isEqualToString:campaignProductCell.chosenSize])
            {
                //found it
                simpleSize = simple.variation;
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
    [self.chosenSimpleNames replaceObjectAtIndex:self.lastPressedCampaignProductCell.tag withObject:selectedSimple.variation];
    
    if (NOT_NIL(self.lastPressedCampaignProductCell.onSelected)) {
        self.lastPressedCampaignProductCell.chosenSize = selectedSimple.variation;
        self.lastPressedCampaignProductCell.onSelected();
    }
    [self.collectionView reloadData];
}

@end
