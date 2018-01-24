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
#import "NavigationBarProtocol.h"

@interface BaseViewController : UIViewController <SideMenuProtocol, TabBarProtocol, PerformanceTrackerProtocol, DataTrackerProtocol, NavigationBarProtocol>
- (CGRect)viewBounds;
- (NSArray <NSString *>*)extractSuccessMessages:(id)dataMessages;
- (void)showMessage:(NSArray <NSString *>*)successMessages showMessage:(BOOL)showMessage;
- (BOOL)showNotificationBar:(id)message isSuccess:(BOOL)success;
- (BOOL)showNotificationBarFromMessageDictionary:(NSDictionary *)messageDict isSuccess:(BOOL)success;
- (BOOL)showNotificationBarMessage:(NSString *)message isSuccess:(BOOL)success;
- (void)updateCartInNavBar;
- (void)handleGenericErrorCodesWithErrorControlView:(int)errorCode forRequestID:(int)rid;
- (void)removeErrorView;

@end
