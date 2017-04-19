//
//  EmarsysRecommendationCarouselWidget.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationCarouselWidget.h"

@interface EmarsysRecommendationCarouselWidget()
    
@property (nonatomic, strong) EmarsysRecommendationCarouselView *carouselView;

@end

@implementation EmarsysRecommendationCarouselWidget

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    self.carouselView = [EmarsysRecommendationCarouselView nibInstance];
    if(self.carouselView) {
        [self addSubview:self.carouselView];
        [self anchorMatch:self.carouselView];
    }
}

- (void)setDelegate:(id<FeatureBoxCollectionViewWidgetViewDelegate>)delegate {
    self.carouselView.delegate = delegate;
    _delegate = delegate;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    [self.carouselView setWidgetBacgkround:backgroundColor];
}

- (void)updateTitle:(NSString *)title {
    [self.carouselView updateTitle:title];
}

- (void)updateWithModel:(id)model {
    if ([model isKindOfClass: [NSArray <RecommendItem *> class]]) {
        [self.carouselView updateWithModel:model];
    }
}

@end
