//
//  EmarsysRecommendationCarouselView.h
//  Bamilo
//
//  Created by Ali saiedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FeatureBoxWidget.h"
#import "RecommendItem.h"


@protocol EmarsysRecommendationCarouselViewDelegate<NSObject>

- (void)selectSuggestedItem:(RecommendItem *)item;

@end

@interface EmarsysRecommendationCarouselView: FeatureBoxWidget <UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) id<EmarsysRecommendationCarouselViewDelegate> delegate;
- (void)updateWithModel:(NSArray<RecommendItem *>*)modelArray;

@end
