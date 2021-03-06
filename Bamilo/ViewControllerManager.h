//
//  ViewControllerManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JACenterNavigationController.h"

@interface ViewControllerManager : NSObject

+(instancetype) sharedInstance;

- (UIViewController *) loadNib:(NSString *)nibName resetCache:(BOOL)resetCache;
- (UIViewController *) loadViewController:(NSString *)nibName;
- (UIViewController *) loadViewController:(NSString *)nibName resetCache:(BOOL)resetCache;
- (UIViewController *) loadViewController:(NSString *)storyboard nibName:(NSString *)nibName resetCache:(BOOL)resetCache;
- (UIViewController *)loadViewControllerWithoutStoryBoard:(NSString *)className;
- (void)clearCache;

@end

@interface ViewControllerManager()
+ (id) topViewController;

@end
