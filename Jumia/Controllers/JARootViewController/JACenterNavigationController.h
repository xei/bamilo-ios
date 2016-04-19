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
#import "JAScreenTarget.h"

@interface JACenterNavigationController : UINavigationController

@property (strong, nonatomic) JACustomNavigationBarView *navigationBarView;
@property (strong, nonatomic) JATabBarView *tabBarView;

@property (nonatomic, assign)BOOL searchViewAlwaysHidden;

+ (instancetype)sharedInstance;

- (void)openTargetString:(NSString *)targetString;
- (BOOL)openScreenTarget:(JAScreenTarget *)target;
- (void)showSearchView;

@end
