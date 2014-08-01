//
//  RIRecentSearch.m
//  Jumia
//
//  Created by Miguel Chaves on 01/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIRecentSearch.h"
#import "RIDataBaseWrapper.h"

@implementation RIRecentSearch

@dynamic searchIndex;
@dynamic searchText;

+ (void)saveRecentSearch:(RIRecentSearch *)search
{
    NSArray *searches = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIRecentSearch class])];
    
    if (searches.count > 4) {
        
        RIRecentSearch *searchToDelete = searches[searches.count-1];
        
        [RIRecentSearch deleteRecentSearch:searchToDelete];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:search];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (void)deleteRecentSearch:(RIRecentSearch *)search
{
    [[RIDataBaseWrapper sharedInstance] deleteObject:search];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (void)deleteAllSearches
{
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RIRecentSearch class])];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (NSArray *)getRecentSearches
{
    NSArray *searches = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIRecentSearch class])];

    if (searches) {
#warning remove this. for tests only
        if (searches.count == 0) {
            RIRecentSearch *newSearch = (RIRecentSearch *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIRecentSearch class])];
            newSearch.searchText = @"Adidas or Nike";
            newSearch.searchIndex = @(0);
            
            [RIRecentSearch saveRecentSearch:newSearch];
            
            RIRecentSearch *newSearch2 = (RIRecentSearch *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIRecentSearch class])];
            newSearch2.searchText = @"Apple iPhone 4";
            newSearch2.searchIndex = @(0);
            
            [RIRecentSearch saveRecentSearch:newSearch2];
        }
        
        return searches;
    } else {
        return nil;
    }
}

@end
