//
//  EmarsysRecommendationCarouselView.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationCarouselView.h"
#import "EmarsysRecommendationCarouselCollectionViewCell.h"
#import "ThreadManager.h"

@interface EmarsysRecommendationCarouselView()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray <RecommendItem *>* recommendationArray;
@property (weak, nonatomic) IBOutlet UILabel *carouselTitle;

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
    [self.collectionView reloadData];
}

- (void)updateTitle:(NSString *)title {
    self.carouselTitle.text = title;
}

+ (EmarsysRecommendationCarouselView *)nibInstance {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmarsysRecommendationCarouselCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName] forIndexPath:indexPath];
    [cell updateWithModel:self.recommendationArray[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [EmarsysRecommendationCarouselCollectionViewCell preferedSize];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommendationArray.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate selectSuggestedItem:self.recommendationArray[indexPath.row]];
}

@end
