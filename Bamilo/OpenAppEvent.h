//
//  OpenAppEvent.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AppEvent.h"

@interface OpenAppEvent : AppEvent

typedef NS_ENUM(NSUInteger, OpenAppEventSourceType) {
    OPEN_APP_SOURCE_NONE = 0,
    OPEN_APP_SOURCE_DIRECT = 1,
    OPEN_APP_SOURCE_PUSH_NOTIFICATION,
    OPEN_APP_SOURCE_DEEPLINK
};

@end
