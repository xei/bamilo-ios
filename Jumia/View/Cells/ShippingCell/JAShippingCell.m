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

-(void)loadWithShippingMethod:(NSString *)shippingMethod
{
    [self.label setText:shippingMethod];
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
