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
    NSMutableArray *finalSearchArray = [NSMutableArray new];
    [RIRecentSearch deleteAllSearches];
    
    search.searchIndex = @(0);
    [finalSearchArray insertObject:search
                           atIndex:0];
    
    if (1 < searches.count)
    {
        for (int i = 1 ; i < searches.count ; i++)
        {
            RIRecentSearch *storedSearch = searches[i];
            RIRecentSearch *tempSearch = (RIRecentSearch *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIRecentSearch class])];
            
            tempSearch.searchText = storedSearch.searchText;
            tempSearch.searchIndex = @(i);
            
            [finalSearchArray insertObject:tempSearch
                                   atIndex:i];
        }
    }
    
    for (RIRecentSearch *searchToSave in finalSearchArray)
    {
        [[RIDataBaseWrapper sharedInstance] insertManagedObject:searchToSave];
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
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
