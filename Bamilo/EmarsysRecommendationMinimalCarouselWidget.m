//
//  EmarsysRecommendationMinimalCarouselWidget.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRecommendationMinimalCarouselWidget.h"
#import "EmarsysRecommendationMinimalCarouselWidgetView.h"
#import "Bamilo-Swift.h"

@interface EmarsysRecommendationMinimalCarouselWidget()

@property (nonatomic, strong) EmarsysRecommendationMinimalCarouselWidgetView *carouselView;

@end

@implementation EmarsysRecommendationMinimalCarouselWidget

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    self.carouselView = [EmarsysRecommendationMinimalCarouselWidgetView nibInstance];
    if(self.carouselView) {
        [self addSubview:self.carouselView];
        [self.carouselView setFrame:self.bounds];
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
