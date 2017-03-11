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
    [self.switcherView setBackgroundColor:[Theme color:kColorDarkGray]];
    [self.switcherView setTintColor:[Theme color:kColorDarkGray]];
    self.switcherView.layer.cornerRadius = 16.0;
    [self.switcherView setOnTintColor:[Theme color:kColorGreen]];
    
    [self.descriptionLabel applyStyle:[Theme font:kFontVariationRegular size:12] color:[Theme color:kColorDarkGray]];
    self.descriptionLabel.text = STRING_COUPON;
}

- (IBAction)switcherValueToggled:(id)sender {    
    [self.delegate discountSwitcherViewDidToggle:[sender isOn]];
}

#pragma mark - Overrides
+(NSString *)nibName {
    return @"DiscountSwitcherView";
}

-(void)updateWithModel:(id)model {
    BOOL toOn = [model boolValue];
    
    //Only automatically on the switcher. Don't turn it off with update model.
    if(toOn == YES) {
        [self.switcherView setOn:toOn];
    }
}

@end
