//
//  RIWrapperConfiguration.h
//  Comunication Project
//
//  Created by Telmo Pinto on 21/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#ifndef Comunication_Project_RIWrapperConfiguration_h
#define Comunication_Project_RIWrapperConfiguration_h

#ifndef APP_NAME
#define APP_NAME [[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey] capitalizedString]
#endif

#ifndef ISEMPTY
#define ISEMPTY(__OBJECT) ( (nil == __OBJECT) ? YES : ( ([__OBJECT respondsToSelector:@selector(count)]) ? ([__OBJECT performSelector:@selector(count)] <= 0) : ( ([__OBJECT respondsToSelector:@selector(length)]) ? ([__OBJECT performSelector:@selector(length)] <= 0) : NO ) ) )
#endif

#ifndef NOTEMPTY
#define NOTEMPTY(__OBJECT) (ISEMPTY(__OBJECT) == NO)
#endif

#ifndef VALID
#define VALID(__OBJECT, __CLASSNAME) (nil != __OBJECT && [__OBJECT isKindOfClass:[__CLASSNAME class]])
#endif

#ifndef VALID_ISEMPTY
#define VALID_ISEMPTY(__OBJECT, __CLASSNAME) (VALID(__OBJECT, __CLASSNAME) == YES && ISEMPTY(__OBJECT) == YES)
#endif

#ifndef VALID_NOTEMPTY
#define VALID_NOTEMPTY(__OBJECT, __CLASSNAME) (VALID(__OBJECT, __CLASSNAME) == YES && ISEMPTY(__OBJECT) == NO)
#endif

#ifndef ARRAY_INDEX_EXISTS
#define ARRAY_INDEX_EXISTS(__OBJECT, __INDEX) (VALID(__OBJECT, NSArray) && __INDEX >= 0 && [(NSArray *) __OBJECT count] > __INDEX)
#endif

#ifndef OBJECT_AT_INDEX
#define OBJECT_AT_INDEX(__OBJECT, __INDEX) ((ARRAY_INDEX_EXISTS(__OBJECT, __INDEX)) ? [__OBJECT objectAtIndex:__INDEX] : nil)
#endif

typedef NS_ENUM(NSInteger, RIApiResponse) {
    RIApiResponseSuccess                = 9000,
    RIApiResponseAuthorizationError     = 9001,
    RIApiResponseTimeOut                = 9002,
    RIApiResponseBadUrl                 = 9003,
    RIApiResponseUnknownError           = 9004,
    RIApiResponseAPIError               = 9005,
    RIApiResponseNoInternetConnection   = 9006,
    RIApiResponseMaintenancePage        = 9007,
    RIApiResponseKickoutView            = 9008
};

typedef NS_ENUM(NSInteger, HttpVerb) {
    HttpVerbPOST                    = 0,
    HttpVerbGET                     = 1,
    HttpVerbPUT                     = 2,
    HttpVerbDELETE                  = 3
};

#ifndef UIColorFromRGB
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#endif

#endif
