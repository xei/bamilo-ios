//
//  JAMaintenancePage.h
//  Jumia
//
//  Created by plopes on 13/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMaintenancePage : UIView

+ (JAMaintenancePage *)getNewJAMaintenancePage;

- (void)setupMaintenancePage:(CGRect)frame;

- (void)setRetryBlock:(void(^)(BOOL dismiss))completion;

@end
