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
    self.button.clipsToBounds = YES;
    self.button.layer.cornerRadius = self.buttonHeightConstraint.constant / 2;
}

+ (NSString *)nibName {
    return @"ButtonTableViewCell";
}
- (IBAction)buttonTapped:(id)sender {
    [self.delegate buttonTapped:self];
}

@end
