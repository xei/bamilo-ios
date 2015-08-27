//
//  JAShippingCell.m
//  Jumia
//
//  Created by Pedro Lopes on 06/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShippingCell.h"

@interface JAShippingCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;

@end

@implementation JAShippingCell

-(void)loadWithShippingMethod:(RIShippingMethod *)shippingMethod
{
    self.clickableView.frame = self.bounds;
    
    self.checkMark.translatesAutoresizingMaskIntoConstraints = YES;
    self.checkMark.frame = CGRectMake(self.clickableView.frame.size.width - 14.0f - self.checkMark.frame.size.width,
                                      (self.clickableView.frame.size.height - self.checkMark.frame.size.height) / 2,
                                      self.checkMark.frame.size.width,
                                      self.checkMark.frame.size.height);
    
    
    // this triggers the constraints error output
    self.label.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.label.font = [UIFont fontWithName:kFontLightName size:self.label.font.pointSize];
    self.label.textAlignment = NSTextAlignmentLeft;
    [self.label setText:[shippingMethod label]];
    self.label.frame = CGRectMake(17.0f,
                                  0.0f,
                                  self.clickableView.frame.size.width - 14*2 - self.checkMark.frame.size.width,
                                  self.clickableView.frame.size.height);
    
    self.separator.translatesAutoresizingMaskIntoConstraints = YES;
    self.separator.frame = CGRectMake(0.0f,
                                      self.clickableView.frame.size.height - 1.0f,
                                      self.clickableView.frame.size.width,
                                      1.0f);
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
    
}

-(void)selectShippingMethod
{
    [self.checkMark setHidden:NO];
    [self.separator setHidden:YES];
}

-(void)deselectShippingMethod
{
    [self.checkMark setHidden:YES];
    [self.separator setHidden:NO];
}

@end
