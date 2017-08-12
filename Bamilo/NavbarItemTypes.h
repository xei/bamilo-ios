//
//  NavbarItemTypes.h
//  Bamilo
//
//  Created by Ali Saeedifar on 7/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavbarItemTypes : NSObject

typedef NS_ENUM(NSUInteger, NavbarTitleType) {
    NavbarTitleTypeLogo = 0,
    NavbarTitleTypeString = 1
};

typedef NS_ENUM(NSUInteger, NavbarLeftButtonType) {
    NavbarLeftButtonTypeNone = 0,
    NavbarLeftButtonTypeSearch = 1,
    NavbarLeftButtonTypeCart = 2
};

@end
