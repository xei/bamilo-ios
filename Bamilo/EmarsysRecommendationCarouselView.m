//
//  EmarsysRecommendationCarouselView.m
//  Bamilo
//
//  Created by Ali saiedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationCarouselView.h"
#import "EmarsysRecommendationCarouselCollectionViewCell.h"
#import "ThreadManager.h"

const CGFloat cellHeight = 280;
const CGFloat cellWidth = 138;

@interface EmarsysRecommendationCarouselView()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <RecommendItem *>* recommendationArray;
@end

@implementation EmarsysRecommendationCarouselView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerNib:[UINib nibWithNibName:[EmarsysRecommendationCarouselCollectionViewCell nibName] bundle:nil]
          forCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName]];
}

- (void)updateWithModel:(NSArray<RecommendItem *> *)modelArray {
    self.recommendationArray = modelArray;
    [ThreadManager executeOnMainThread:^{
        [self.collectionView reloadData];
    }];
}

+ (EmarsysRecommendationCarouselView *)nibInstance {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil] lastObject];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmarsysRecommendationCarouselCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName] forIndexPath:indexPath];
    [cell updateWithModel:self.recommendationArray[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(cellWidth, cellHeight);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommendationArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate selectSuggestedItem:self.recommendationArray[indexPath.row]];
}

@end
