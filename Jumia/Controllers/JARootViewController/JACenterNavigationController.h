//
//  JACenterNavigationController.h
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANavigationBarView.h"
#import "JATabBarView.h"

@interface JACenterNavigationController : UINavigationController

@property (strong, nonatomic) JANavigationBarView *navigationBarView;
@property (strong, nonatomic) JATabBarView *tabBarView;

@end
