//
//  DataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"
#import "Address.h"

typedef void(^DataCompletion)(id data, NSError *error);

@interface DataManager : NSObject

+(instancetype) sharedInstance;

-(void) getUserAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
-(void) setDefaultAddress:(id<DataServiceProtocol>)target address:(Address *)address isBilling:(BOOL)isBilling completion:(DataCompletion)completion;
-(void) loginUser:(id<DataServiceProtocol>)target withUsername:(NSString *)username password:(NSString *)password completion:(DataCompletion)completion;

@end
