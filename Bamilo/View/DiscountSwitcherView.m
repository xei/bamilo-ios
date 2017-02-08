//
//  DiscountSwitcherView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DiscountSwitcherView.h"

@interface DiscountSwitcherView()
@property (weak, nonatomic) IBOutlet UISwitch *switcherView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation DiscountSwitcherView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    //Initial Setup
    [self.switcherView setBackgroundColor:cDARK_GRAY_COLOR];
    [self.switcherView setTintColor:cDARK_GRAY_COLOR];
    self.switcherView.layer.cornerRadius = 16.0;
    [self.switcherView setOnTintColor:cGREEN_COLOR];
    
    [self.descriptionLabel applyStyle:kFontRegularName fontSize:12.0f color:[UIColor withRepeatingRGBA:110 alpha:1.0f]];
    self.descriptionLabel.text = STRING_COUPON;
}

- (IBAction)switcherValueToggled:(id)sender {
    [self.delegate discountSwitcherViewDidToggle:[sender isOn]];
}

#pragma mark - Overrides
+(NSString *)nibName {
    return @"DiscountSwitcherView";
}

@end
