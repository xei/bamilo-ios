//
//  EmarsysRecommendationCollectionView.m
//  Bamilo
//
//  Created by Ali saiedifar on 4/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationCollectionView.h"
#import "EmarsysRecommendationCarouselCollectionViewCell.h"



@interface EmarsysRecommendationCollectionView() <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
//@property (nonatomic, strong) NSArray <>
@end

@implementation EmarsysRecommendationCollectionView


- (void)awakeFromNib {
    [super awakeFromNib];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    
}

+ (EmarsysRecommendationCollectionView *)nibInstance {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
}



#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EmarsysRecommendationCarouselCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:[EmarsysRecommendationCarouselCollectionViewCell nibName] forIndexPath:indexPath];
//    [cell updateWithModel:self.recommendationArray[indexPath.row]];
    return cell;
}

@end
