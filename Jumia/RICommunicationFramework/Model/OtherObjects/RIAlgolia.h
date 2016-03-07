//
//  RIAlgolia.h
//  Jumia
//
//  Created by Jose Mota on 12/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "ASAPIClient.h"

@interface RIAlgolia : NSObject

+ (instancetype)sharedInstance;

- (void)getSearchResultsForQuery:(NSString *)textToQuery
              onFirstStepSuccess:(void(^)(NSArray *productsResults, NSArray *shopInShopResults))firstStepSuccess
             onSecondStepSuccess:(void(^)(NSArray *categoryResults))secondStepSuccess
                         onError:(void(^)(NSString *error))error;

@end
