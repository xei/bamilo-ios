//
//  JAORReasonsViewController.h
//  Jumia
//
//  Created by telmopinto on 10/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIOrder.h"

@interface JAORReasonsViewController : JABaseViewController

@property (nonatomic) NSMutableDictionary *stateInfoValues;
@property (nonatomic) NSMutableDictionary *stateInfoLabels;
@property (nonatomic, strong) RITrackOrder *order;
@property (nonatomic, strong) NSArray *items;

@end
