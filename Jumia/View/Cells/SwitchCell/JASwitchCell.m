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
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation JASwitchCell

-(void)loadWithText:(NSString*)text isLastRow:(BOOL)isLastRow
{
    self.backgroundColor = UIColorFromRGB(0xffffff);
    
    self.containerView.translatesAutoresizingMaskIntoConstraints = YES;
    self.containerView.frame = self.bounds;
    
    self.switchView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.switchView setAccessibilityLabel:text];
    self.switchView.frame = CGRectMake(17.0f,
                                       self.switchView.frame.origin.y,
                                       self.switchView.frame.size.width,
                                       self.switchView.frame.size.height);
    
    self.label.translatesAutoresizingMaskIntoConstraints = YES;
    self.label.font = [UIFont fontWithName:kFontRegularName size:self.label.font.pointSize];
    self.label.textAlignment = NSTextAlignmentLeft;
    [self.label setText:text];
    self.label.frame = CGRectMake(84.0f,
                                  self.label.frame.origin.y,
                                  self.frame.size.width - 11.0f - 84.0f,
                                  self.label.frame.size.height);
    
    self.separator.translatesAutoresizingMaskIntoConstraints = YES;
    self.separator.frame = CGRectMake(0.0f,
                                      50.0f,
                                      self.frame.size.width,
                                      1.0f);
    [self.separator setHidden:YES];
    if(!isLastRow)
    {
        [self.separator setHidden:NO];
    }
    
    if (RI_IS_RTL) {
        [self.containerView flipAllSubviews];
    }
}

@end
