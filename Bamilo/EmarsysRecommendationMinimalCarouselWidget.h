//
//  EmarsysRecommendationMinimalCarouselWidget.h
//  Bamilo
//
//  Created by Ali Saeedifar on 4/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FeatureBoxCollectionViewWidget.h"
#import "FeatureBoxCollectionViewWidgetView.h"

@interface EmarsysRecommendationMinimalCarouselWidget : FeatureBoxCollectionViewWidget

@property (nonatomic, weak) id<FeatureBoxCollectionViewWidgetViewDelegate> delegate;
- (void)updateTitle:(NSString *)title;

@end
