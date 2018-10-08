//
//  ButtonTableViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ButtonTableViewCell.h"

@interface ButtonTableViewCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonHeightConstraint;

@end

@implementation ButtonTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // apply Gradient
    CAGradientLayer *gradientMask = [CAGradientLayer layer];
    gradientMask.frame = self.button.bounds;
    gradientMask.colors = @[(id)[UIColor colorWithRed:1 green:0.65 blue:0.05 alpha:1].CGColor,
                            (id)[UIColor colorWithRed:0.97 green:0.42 blue:0.11 alpha:1].CGColor,];
    [gradientMask setOpaque:YES];
    [gradientMask setLocations:@[@(0), @(1)]];
    [gradientMask setStartPoint: CGPointMake(0, 0.5)];
    [gradientMask setEndPoint: CGPointMake(1.0, 0.5)];
    [self.button.layer addSublayer:gradientMask];
    [self.button applyStyle:[Theme font:kFontVariationBold size:12] color:[UIColor whiteColor]];
    
    self.button.layer.masksToBounds = YES;
    self.button.layer.cornerRadius = self.buttonHeightConstraint.constant / 2;
    self.button.layer.borderWidth = 0;
    self.button.layer.borderColor = 0;
    self.button.layer.shadowColor = [UIColor colorWithRed:1 green:0.65 blue:0.05 alpha:1].CGColor;
    self.button.layer.shadowOpacity = 0.5;
    self.button.layer.shadowRadius = 0.6;
    self.button.layer.shadowOffset = CGSizeMake(1, 1);
}

+ (NSString *)nibName {
    return @"ButtonTableViewCell";
}
- (IBAction)buttonTapped:(id)sender {
    [self.delegate buttonTapped:self];
}

@end
