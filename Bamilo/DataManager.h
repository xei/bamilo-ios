//
//  DataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"
#import "RICart.h"
#import "FormItemModel.h"

#define kDataMessages @"DataMessages"
#define kDataContent @"DataContent"

typedef void(^DataCompletion)(id data, NSError *error);

@interface DataManager: NSObject

@property (strong, nonatomic) RequestManager *requestManager;

+ (instancetype)sharedInstance;

- (void) processResponse:(RIApiResponse)response ofClass:(Class)aClass forData:(ResponseData *)data errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion;
- (NSError *)getErrorFrom:(RIApiResponse)response errorMessages:(NSArray *)errorMessages;

@end
