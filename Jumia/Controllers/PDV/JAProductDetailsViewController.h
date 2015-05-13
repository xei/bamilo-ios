//
//  JAProductDetailsViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 08/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JABaseViewController.h"

@class RIProduct;

@interface JAProductDetailsViewController : JABaseViewController

@property (nonatomic, strong) RIProduct *product;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong)NSString* startingTrackOrderNumber;

@end
