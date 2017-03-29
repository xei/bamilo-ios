//
//  EmarsysDataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseDataManager.h"

@interface EmarsysContactIdentifier : NSObject

@property (copy, nonatomic) NSString *applicationId;
@property (copy, nonatomic) NSString *hardwareId;
@property (copy, nonatomic) NSString *pushToken;

+(instancetype) appId:(NSString *)appId hwid:(NSString *)hwid;
+(instancetype) appId:(NSString *)appId hwid:(NSString *)hwid pushToken:(NSString *)pushToken;

@end

@interface EmarsysDataManager : BaseDataManager

-(void) anonymousLogin:(EmarsysContactIdentifier *)contact completion:(DataCompletion)completion;

-(void) login:(EmarsysContactIdentifier *)contact contactFieldId:(NSString *)contactFieldId contactFieldValue:(NSString *)contactFieldValue completion:(DataCompletion)completion;

-(void) openMessage:(EmarsysContactIdentifier *)contact sid:(NSString *)sid completion:(DataCompletion)completion;

-(void) event:(EmarsysContactIdentifier *)contact event:(NSString *)event completion:(DataCompletion)completion;

@end
