//
//  EmarsysRequestManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"

typedef NS_ENUM(NSUInteger, EmarsysMobileEngageHTTPStatusCode) {
    CREATED = 201, //Created
    SUCCESSFUL = 202, //User data is successfully updated
    WRONG_INPUT_OR_MISSING_PARAM = 400, //Wrong input or missing mandatory parameter
    UNAUTHORIZED = 401, //Invalid HTTP Basic Authentication
    DATABASE_ERROR = 500, //Database error (Everything else)
    INTERNAL_SERVER_ERROR = 501 //Internal server error
};

@interface EmarsysRequestManager : RequestManager

@end
