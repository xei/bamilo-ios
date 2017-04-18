//
//  EmarsysRecommendationCarouselWidget.h
//  Bamilo
//
//  Created by Ali Saeedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FeatureBoxCollectionViewWidget.h"
#import "EmarsysRecommendationCarouselView.h"

@interface EmarsysRecommendationCarouselWidget : FeatureBoxCollectionViewWidget

@property (nonatomic, weak) id<FeatureBoxCollectionViewWidgetViewDelegate> delegate;
- (void)updateTitle:(NSString *)title;

@end
