//
//  JATabNavigationViewController.h
//  Jumia
//
//  Created by josemota on 10/13/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProduct.h"

#define kTabsHeight 48

typedef NS_ENUM(NSUInteger, JATabScreenEnum) {
    kTabScreenDescription = 0,
    kTabScreenSpecifications = 1,
    kTabScreenReviews = 2
};

@interface JATabNavigationViewController : JABaseViewController

@property (nonatomic, strong) RIProduct *product;
@property (nonatomic) JATabScreenEnum tabScreenEnum;

@end
