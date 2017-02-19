//
//  BaseViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuProtocol.h"
#import "TabBarProtocol.h"

@interface BaseViewController : BMA4SViewController <SideMenuProtocol, TabBarProtocol>

@property (strong, nonatomic) JANavigationBarLayout *navBarLayout;

- (void)updateNavBar;
- (void)showNotificationBar:(NSString *)message isSuccess:(BOOL)success;

@end
