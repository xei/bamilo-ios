//
//  RadioButtonViewControl.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "RadioButtonViewControl.h"
#import "RadioButtonView.h"

@interface RadioButtonViewControl()
@property (weak, nonatomic) RadioButtonView *radioButtonView;
@end

@implementation RadioButtonViewControl

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.radioButtonView = [RadioButtonView nibInstance];
    
    if(self.radioButtonView) {
        [self.radioButtonView setDelegate:self];
        [self addSubview:self.radioButtonView];
        [self anchorMatch:self.radioButtonView];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    [self.radioButtonView update:isSelected];
    _isSelected = isSelected;
}

#pragma mark - RadioButtonViewControlDelegate
- (void)didSelectRadioButton:(id)button {
    [self.delegate didSelectRadioButton:self];
}

@end
