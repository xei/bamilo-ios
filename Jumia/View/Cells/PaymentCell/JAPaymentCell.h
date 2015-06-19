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

@interface JAPaymentCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet JAClickableView *clickableView;
@property (strong, nonatomic) UIView *separator;

-(void)loadWithPaymentMethod:(RIPaymentMethodFormOption *)paymentMethod paymentMethodView:(UIView*)paymentMethodView isSelected:(BOOL)isSelected;

@end
