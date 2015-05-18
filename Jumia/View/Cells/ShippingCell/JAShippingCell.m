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
    self.label.font = [UIFont fontWithName:kFontLightName size:self.label.font.pointSize];
    [self.label setText:[shippingMethod label]];
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
