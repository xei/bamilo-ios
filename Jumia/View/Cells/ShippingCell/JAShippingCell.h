//
//  JAShippingCell.h
//  Jumia
//
//  Created by Pedro Lopes on 06/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"
#import "RIShippingMethod.h"

@interface JAShippingCell : UITableViewCell

@property (strong, nonatomic) JAClickableView *clickableView;

-(void)loadWithShippingMethod:(RIShippingMethod *)shippingMethod width:(CGFloat)width;

-(void)selectShippingMethod;

-(void)deselectShippingMethod;

@end
