//
//  JAAddressCell.h
//  Jumia
//
//  Created by Pedro Lopes on 04/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

#define kAddressCellHeight 110.0f

@class RIAddress;

@interface JAAddressCell : UITableViewCell

@property (strong, nonatomic) UIButton *editAddressButton;
@property (assign, nonatomic) BOOL fromCheckOut;
@property (strong, nonatomic) UIButton * radioButton;
@property (strong, nonatomic) UIButton *deleteAddressButton;

-(void)loadWithWidth:(CGFloat)width
             address:(RIAddress*)address;

@end
