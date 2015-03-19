//
//  JAButtonCell.m
//  Jumia
//
//  Created by Telmo Pinto on 20/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAButtonCell.h"

@implementation JAButtonCell

- (void)loadWithButtonName:(NSString*)buttonName
{
    self.backgroundColor = [UIColor clearColor];
    self.button.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.button.titleLabel.font.pointSize];
    [self.button setTitle:buttonName forState:UIControlStateNormal];
    [self.button setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
}

@end
