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
    OpenAppEventSourceTypeNone = 0,
    OpenAppEventSourceTypeDirect = 1,
    OpenAppEventSourceTypePushNotification,
    OpenAppEventSourceTypeDeeplink
};

@end
