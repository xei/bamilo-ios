//
//  JAMyOrderDetailViewController.h
//  Jumia
//
//  Created by miguelseabra on 14/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RIOrder.h"

@interface JAMyOrderDetailViewController : JABaseViewController

@property (strong, nonatomic) RITrackOrder *trackingOrder;

@end
