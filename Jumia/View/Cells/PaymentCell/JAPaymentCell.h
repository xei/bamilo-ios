//
//  JAPaymentCell.h
//  Jumia
//
//  Created by Pedro Lopes on 10/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@class RIPaymentMethodFormOption;

@interface JAPaymentCell : UITableViewCell

@property (strong, nonatomic) JAClickableView *clickableView;

-(void)loadWithPaymentMethod:(RIPaymentMethodFormOption *)paymentMethod paymentMethodView:(UIView*)paymentMethodView isSelected:(BOOL)isSelected width:(CGFloat)width;
-(void)loadNoPaymentMethod:(NSString *)paymentMethod paymentMethodView:(UIView*)paymentMethodView;

+ (CGFloat)xPositionAfterCheckmark;

@end
