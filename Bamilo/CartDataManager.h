//
//  CartDataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"

@interface CartDataManager : DataManager

-(void) addProductToCart:(id<DataServiceProtocol>)target simpleSku:(NSString *)simpleSku completion:(DataCompletion)completion;
- (void)getUserCart:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;

@end
