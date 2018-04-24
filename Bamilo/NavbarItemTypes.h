//
//  NavBarItemTypes.h
//  Bamilo
//
//  Created by Ali Saeedifar on 7/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavBarItemTypes : NSObject

typedef NS_ENUM(NSUInteger, NavBarTitleType) {
    NavBarTitleTypeLogo = 0,
    NavBarTitleTypeString = 1
};

typedef NS_ENUM(NSUInteger, NavBarButtonType) {
    NavBarButtonTypeNone = 0,
    NavBarButtonTypeSearch = 1,
    NavBarButtonTypeCart = 2,
    NavBarButtonTypeClose = 3,
    NavBarButtonTypeDarkClose = 4
};

@end
