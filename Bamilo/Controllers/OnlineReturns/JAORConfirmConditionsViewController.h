//
//  JAORConfirmConditionsViewController.h
//  Jumia
//
//  Created by Jose Mota on 03/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RIOrder.h"

@interface JAORConfirmConditionsViewController : JABaseViewController

@property (nonatomic, strong) RITrackOrder *order;
@property (nonatomic, strong) NSString *html;
@property (nonatomic, strong) NSArray *items;

@end
