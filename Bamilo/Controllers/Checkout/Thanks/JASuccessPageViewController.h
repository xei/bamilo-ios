//
//  JASuccessPageViewController.h
//  Jumia
//
//  Created by Jose Mota on 17/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RICart.h"
#import "EmarsysPredictProtocol.h"

@interface JASuccessPageViewController : JABaseViewController <EmarsysPredictProtocol>

@property (strong, nonatomic) RICart *cart;

@end
