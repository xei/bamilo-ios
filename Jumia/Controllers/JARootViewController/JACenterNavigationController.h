//
//  JACenterNavigationController.h
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACustomNavigationBarView.h"
#import "JATabBarView.h"

@interface JACenterNavigationController : UINavigationController

@property (strong, nonatomic) JACustomNavigationBarView *navigationBarView;
@property (strong, nonatomic) JATabBarView *tabBarView;

@end
