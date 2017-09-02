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

typedef NS_ENUM(NSUInteger, NavBarLeftButtonType) {
    NavBarLeftButtonTypeNone = 0,
    NavBarLeftButtonTypeSearch = 1,
    NavBarLeftButtonTypeCart = 2
};

@end
