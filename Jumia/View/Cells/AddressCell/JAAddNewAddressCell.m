//
//  JAAddNewAddressCell.m
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddNewAddressCell.h"

@interface JAAddNewAddressCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation JAAddNewAddressCell

-(void)loadWithText:(NSString*)text
{
    self.backgroundColor = UIColorFromRGB(0xffffff);
 
    self.clickableView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.clickableView setFrame:CGRectMake(0.0f,
                                            0.0f,
                                            self.frame.size.width,
                                            self.frame.size.height)];
    
    [self.label setTextColor:UIColorFromRGB(0x55a1ff)];
    [self.label setText:text];
}

@end
