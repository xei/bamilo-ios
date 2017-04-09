//
//  AuthenticationDataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"

@interface AuthenticationDataManager : DataManager

- (void)loginUser:(id<DataServiceProtocol>)target withUsername:(NSString *)username password:(NSString *)password completion:(DataCompletion)completion;
- (void)signupUser:(id<DataServiceProtocol>)target withFieldsDictionary:(NSDictionary<NSString *,FormItemModel *> *)newUserDictionary completion:(DataCompletion)completion;
- (void)forgetPassword:(id<DataServiceProtocol>)target withFields:(NSDictionary<NSString *,FormItemModel *> *)fields completion:(DataCompletion)completion;
- (void)logoutUser:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;

@end
