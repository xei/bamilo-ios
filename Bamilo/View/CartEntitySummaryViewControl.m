//
//  CartEntitySummaryViewControl.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartEntitySummaryViewControl.h"

@interface CartEntitySummaryViewControl()
@property (nonatomic, strong) CartEntitySummaryView *summeryView;
@end

@implementation CartEntitySummaryViewControl

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.summeryView = [CartEntitySummaryView nibInstance];
    self.summeryView.delegate = self;
    [self addSubview:self.summeryView];
    self.summeryView.frame = self.bounds;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self.summeryView setBackgroundColor:backgroundColor];
}

- (void)updateWithModel:(id)model {
    if(![model isKindOfClass:CartEntity.class]) {
        return;
    }
    [self.summeryView setCartEntity:model]; 
}

#pragma mark - CartEntitySummaryViewDelegate
- (void)cartEntitySummeryTapped:(id)view {
    [self.delegate cartEntityTapped:self];
}

- (void)applyColor:(UIColor *)color {
    [self.summeryView applyColor:color];
}

@end
