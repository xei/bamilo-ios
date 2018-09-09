//
//  EmarsysRecommendationGridWidget.h
//  Bamilo
//
//  Created by Ali saiedifar on 4/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FeatureBoxCollectionViewWidget.h"
#import "EmarsysRecommendationGridWidgetView.h"

@interface EmarsysRecommendationGridWidget : FeatureBoxCollectionViewWidget

@property (nonatomic, strong) EmarsysRecommendationGridWidgetView *widgetView;
- (void)setDelegate:(id<FeatureBoxCollectionViewWidgetViewDelegate>)delegate;

@end
