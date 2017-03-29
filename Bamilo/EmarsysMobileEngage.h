//
//  EmarsysMobileEngage.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^EmarsysMobileEngageResponse)(BOOL success);

@interface EmarsysMobileEngage : NSObject

+ (instancetype)sharedInstance;

-(void) sendUpdate:(NSString *)applicationId hardwareId:(NSString *)hardwareId pushToken:(NSString *)pushToken completion:(EmarsysMobileEngageResponse)completion;

@end
