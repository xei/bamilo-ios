//
//  CheckoutProgressView.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckoutProgressViewButtonModel.h"

@interface CheckoutProgressView : UIView

-(void) updateButton:(int)tag toModel:(CheckoutProgressViewButtonModel *)model;

@end
