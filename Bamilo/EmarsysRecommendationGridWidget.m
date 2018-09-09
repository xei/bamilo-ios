//
//  EmarsysRecommendationGridWidget.m
//  Bamilo
//
//  Created by Ali saiedifar on 4/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationGridWidget.h"
#import "Bamilo-Swift.h"

@interface EmarsysRecommendationGridWidget()
@end

@implementation EmarsysRecommendationGridWidget

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    self.widgetView = [EmarsysRecommendationGridWidgetView nibInstance];
    self.widgetView.backgroundColor = [UIColor clearColor];
    if(self.widgetView) {
        [self addAnchorMatchedSubViewWithView:self.widgetView];
    }
}

- (void)setDelegate:(id<FeatureBoxCollectionViewWidgetViewDelegate>)delegate {
    self.widgetView.delegate = delegate;
}

@end
