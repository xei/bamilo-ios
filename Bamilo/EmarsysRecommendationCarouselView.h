//
//  EmarsysRecommendationCarouselView.h
//  Bamilo
//
//  Created by Ali Saeedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FeatureBoxWidget.h"
#import "RecommendItem.h"


@protocol EmarsysRecommendationCarouselViewDelegate<NSObject>

- (void)selectSuggestedItem:(RecommendItem *)item;

@end

@interface EmarsysRecommendationCarouselView: UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<EmarsysRecommendationCarouselViewDelegate> delegate;

+ (EmarsysRecommendationCarouselView *)nibInstance;
- (void)updateWithModel:(NSArray<RecommendItem *>*)modelArray; //Must be called in main threat
- (void)updateTitle:(NSString *)title;

@end
