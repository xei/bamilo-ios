//
//  JAORConfirmationScreenViewController.h
//  Jumia
//
//  Created by Jose Mota on 03/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RIOrder.h"

@interface JAORConfirmationScreenViewController : JABaseViewController

@property (nonatomic) NSMutableDictionary *stateInfoValues;
@property (nonatomic) NSMutableDictionary *stateInfoLabels;
@property (nonatomic, strong) RITrackOrder *order;
@property (nonatomic, strong) NSArray *items;

@end