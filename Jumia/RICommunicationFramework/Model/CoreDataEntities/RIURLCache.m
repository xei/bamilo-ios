//
//  RIURLCache.m
//  Comunication Project
//
//  Created by Pedro Lopes on 21/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIURLCache.h"


@implementation RIURLCache

@dynamic responseData;
@dynamic url;
@dynamic duration;

+ (void)cacheResponse:(NSCachedURLResponse*)cachedResponse forUrl:(NSString *)url withDuration:(NSInteger)duration
{
    RIURLCache *cache = [RIURLCache createCache:cachedResponse forUrl:url withDuration:duration];
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:cache];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (RIURLCache *)loadCachedResponseForUrl:(NSString *)url
{
    RIURLCache *response = nil;
    NSArray *responses = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RIURLCache class]) withPropertyName:@"url" andPropertyValue:url];
    
    if(VALID_NOTEMPTY(responses, NSArray))
    {
        response = [responses objectAtIndex:0];
    }
    return response;
}

+ (NSArray *)loadAllCachedResponses
{
    return [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RIURLCache class])];
}

+ (void)deleteCachedResponseForUrl:(NSString *)url {
    [[RIDataBaseWrapper sharedInstance] deleteObject:[RIURLCache loadCachedResponseForUrl:url]];
}

#pragma mark - private method to create RIURLCache object
+ (RIURLCache *) createCache:(NSCachedURLResponse*)cachedResponse forUrl:(NSString *)url withDuration:(NSInteger)duration
{
    RIURLCache* newCache = (RIURLCache*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIURLCache class])];
    
    newCache.responseData = [cachedResponse data];
    newCache.url = url;
    newCache.duration = [NSNumber numberWithInt:duration];
    
    return newCache;
}

@end
