//
//  CheckoutProgressView.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckoutProgressViewButtonModel.h"
#import "CheckoutProgressViewDelegate.h"

@interface CheckoutProgressView : UIView

@property (weak, nonatomic) id<CheckoutProgressViewDelegate> delegate;

-(void) updateButton:(int)tag toModel:(CheckoutProgressViewButtonModel *)model;

@end
