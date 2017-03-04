//
//  CheckoutProgressViewControl.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewControl.h"
#import "CheckoutProgressViewDelegate.h"

@interface CheckoutProgressViewControl : BaseViewControl <CheckoutProgressViewDelegate>

@property (weak, nonatomic) id<CheckoutProgressViewDelegate> delegate;

-(void) requestUpdate;

@end
