//
//  JAPaymentCell.h
//  Jumia
//
//  Created by Pedro Lopes on 10/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIPaymentMethodFormOption;

@interface JAPaymentCell : UICollectionViewCell

@property (strong, nonatomic) UIView *separator;

-(void)loadWithPaymentMethod:(RIPaymentMethodFormOption *)paymentMethod paymentMethodView:(UIView*)paymentMethodView;

-(void)selectPaymentMethod;

-(void)deselectPaymentMethod;

@end
