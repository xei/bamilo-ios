//
//  ButtonTableViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ButtonTableViewCell.h"

@implementation ButtonTableViewCell

+ (NSString *)nibName {
    return @"ButtonTableViewCell";
}
- (IBAction)buttonTapped:(id)sender {
    [self.delegate buttonTapped:self];
}

@end
