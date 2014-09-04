//
//  JASwitchCell.m
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASwitchCell.h"

@interface JASwitchCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIView *separator;

@end

@implementation JASwitchCell

-(void)loadWithText:(NSString*)text isLastRow:(BOOL)isLastRow
{
    self.backgroundColor = UIColorFromRGB(0xffffff);
    
    [self.label setText:text];
    
    [self.separator setHidden:YES];
    if(!isLastRow)
    {
        [self.separator setHidden:NO];
    }
}

@end
