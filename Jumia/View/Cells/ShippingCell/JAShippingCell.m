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

- (void)loadWithShippingMethod:(NSString *)shippingMethod andOptions:(NSArray *)options
{
    [self.label setText:shippingMethod];
}

-(void)selectAddress
{
    [self.checkMark setHidden:NO];
}

-(void)deselectAddress
{
    [self.checkMark setHidden:YES];
}

@end
