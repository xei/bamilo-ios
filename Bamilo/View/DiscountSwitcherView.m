//
//  DiscountSwitcherView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DiscountSwitcherView.h"

#define cGREEN_COLOR [UIColor withRGBA:0 green:160 blue:0 alpha:1.0]

@interface DiscountSwitcherView()
@property (weak, nonatomic) IBOutlet UISwitch *switcherView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@end

@implementation DiscountSwitcherView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    //Initial Setup
    [self.switcherView setTintColor:cGREEN_COLOR];
    [self.switcherView setOnTintColor:cGREEN_COLOR];
    
    self.descriptionLabel.textColor = [UIColor withRepeatingRGBA:110 alpha:1.0f];
    self.descriptionLabel.font = [UIFont fontWithName:kFontRegularName size:12.0f];
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
