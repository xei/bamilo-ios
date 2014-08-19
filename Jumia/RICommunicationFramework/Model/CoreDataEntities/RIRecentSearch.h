//
//  RIRecentSearch.h
//  Jumia
//
//  Created by Miguel Chaves on 01/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RIRecentSearch : NSManagedObject

@property (nonatomic, retain) NSNumber * searchIndex;
@property (nonatomic, retain) NSString * searchText;

+ (void)saveRecentSearch:(NSString *)text;

+ (void)deleteRecentSearch:(RIRecentSearch *)search;

+ (void)deleteAllSearches;

+ (NSArray *)getRecentSearches;

@end
