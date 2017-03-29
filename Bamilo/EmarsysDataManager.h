//
//  EmarsysDataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseDataManager.h"

@interface EmarsysDataManager : BaseDataManager

-(void) doAnonymousLogin:(id<DataServiceProtocol>)target applicationId:(NSString *)applicationId hardwareId:(NSString *)hardwareId pushToken:(NSString *)pushToken completion:(DataCompletion)completion;

@end
