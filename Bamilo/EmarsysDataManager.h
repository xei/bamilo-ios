//
//  EmarsysDataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseDataManager.h"
#import "AppEvent.h"

//### EmarsysContactIdentifier
@interface EmarsysContactIdentifier : NSObject

@property (copy, nonatomic) NSString *applicationId;
@property (copy, nonatomic) NSString *hardwareId;

+(instancetype) appId:(NSString *)appId hwid:(NSString *)hwid;

@end


//### EmarsysPushIdentifier
@interface EmarsysPushIdentifier : EmarsysContactIdentifier

@property (copy, nonatomic) NSString *pushToken;

+(instancetype) appId:(NSString *)appId hwid:(NSString *)hwid pushToken:(NSString *)pushToken;

@end


//### EmarsysDataManager
@interface EmarsysDataManager : BaseDataManager

-(void) anonymousLogin:(EmarsysPushIdentifier *)contact completion:(DataCompletion)completion;

-(void) login:(EmarsysPushIdentifier *)contact contactFieldId:(NSString *)contactFieldId contactFieldValue:(NSString *)contactFieldValue completion:(DataCompletion)completion;

-(void) openMessageEvent:(EmarsysContactIdentifier *)contact sid:(NSString *)sid completion:(DataCompletion)completion;

-(void) customEvent:(EmarsysContactIdentifier *)contact event:(NSString *)event attributes:(NSDictionary *)attributes completion:(DataCompletion)completion;

@end
