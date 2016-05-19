//
//  JAORPaymentViewController.h
//  Jumia
//
//  Created by telmopinto on 18/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RIOrder.h"

@interface JAORPaymentViewController : JABaseViewController

@property (nonatomic, strong) NSMutableDictionary* stateInfo;
@property (nonatomic, strong) RITrackOrder *order;
@property (nonatomic, strong) NSArray *items;

@end
