//
//  EmarsysRecommendationGridWidgetView.h
//  Bamilo
//
//  Created by Ali saiedifar on 4/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FeatureBoxWidget.h"
#import "FeatureBoxCollectionViewWidgetView.h"

@interface EmarsysRecommendationGridWidgetView: FeatureBoxCollectionViewWidgetView

- (void)updateTitle:(NSString *)title;
+ (CGFloat)preferredHeightWithContentModel:(NSArray<RecommendItem *> *)arrayModel boundWidth:(CGFloat)width;

@end
