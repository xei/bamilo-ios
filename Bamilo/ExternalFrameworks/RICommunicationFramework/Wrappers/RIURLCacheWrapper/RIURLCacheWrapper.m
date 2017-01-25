//
//  RIURLCacheWrapper.m
//  Comunication Project
//
//  Created by Pedro Lopes on 15/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIURLCacheWrapper.h"
#import "RIURLCache.h"

#ifndef kRIURLCacheMinTime
#define kRIURLCacheMinTime 900
#endif

#ifndef kRIURLCacheDefaultTime
#define kRIURLCacheDefaultTime 1800
#endif

#ifndef kRIURLCacheMaxTime
#define kRIURLCacheMaxTime 3600
#endif

@interface RIURLCacheWrapper ()


@property (strong, nonatomic) NSMutableDictionary *requests;

@end

@implementation RIURLCacheWrapper

static RIURLCacheWrapper *sharedInstance;
static dispatch_once_t sharedInstanceToken;

#pragma mark - Create and return the instance

+ (instancetype)sharedInstance
{
    dispatch_once(&sharedInstanceToken, ^{
        sharedInstance = [[RIURLCacheWrapper alloc] init];
    });
    
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if(self) {
        self.requests = [[NSMutableDictionary alloc] init];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [self reinitCoreDataTimers];
    }
    return self;
}

/**
 * Method that checks if there are anything cached in core data and restart their timers
 */
- (void) reinitCoreDataTimers
{
    // Check core data for cached responses
    NSArray *coreDataResponses = [RIURLCache loadAllCachedResponses];
    if(NOTEMPTY(coreDataResponses)) {
        for(RIURLCache *response in coreDataResponses) {
            NSURL *url = [[NSURL alloc] initWithString:response.url];
            
            NSURLResponse *urlResponse = [[NSURLResponse alloc] initWithURL:url MIMEType:@"application/json" expectedContentLength:[[response responseData] length] textEncodingName:@"UTF-8"];
            NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:urlResponse data:[response responseData]];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

            // Re-save  the response in sharedURLCache
            [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:request];

            // Restart timer
            [NSTimer scheduledTimerWithTimeInterval:[[response duration] integerValue] target:self selector:@selector(removeFromDBCache:) userInfo:request repeats:NO];
        }
    }
}

- (void) addRequestToLocalCache:(NSURLRequest *)request
              willCacheResponse:(NSCachedURLResponse *)cachedResponse
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime
{
    if(cacheType != RIURLCacheNoCache) {
        NSInteger cachingTime = [RIURLCacheWrapper getCacheTime:cacheTime];
        [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:request];
        if(cacheType == RIURLCacheMemCache) {
            [self.requests setValue:cachedResponse forKey:[[request URL] absoluteString]];
            [NSTimer scheduledTimerWithTimeInterval:cachingTime target:self selector:@selector(removeFromMemCache:) userInfo:request repeats:NO];
        } else if(cacheType == RIURLCacheDBCache) {
            [RIURLCache cacheResponse:cachedResponse forUrl:[[request URL] absoluteString] withDuration:cachingTime];
            [NSTimer scheduledTimerWithTimeInterval:cachingTime target:self selector:@selector(removeFromDBCache:) userInfo:request repeats:NO];
        }
    }
}

- (NSCachedURLResponse *) getRequestFromLocalCache:(NSURLRequest *)request
                                         cacheType:(RIURLCacheType)cacheType
{
    NSCachedURLResponse *response = nil;
    if(cacheType == RIURLCacheMemCache) {
        response = [self.requests objectForKey:[[request URL] absoluteString]];
    } else if(cacheType == RIURLCacheDBCache) {
        RIURLCache *urlCache = [RIURLCache loadCachedResponseForUrl:[[request URL] absoluteString]];
        
        if(NOTEMPTY(urlCache)) {
            // Create the cacheable response
            NSURLResponse *urlResponse = [[NSURLResponse alloc] initWithURL:[request URL] MIMEType:@"application/json" expectedContentLength:[[urlCache responseData] length] textEncodingName:@"UTF-8"];
            response = [[NSCachedURLResponse alloc] initWithResponse:urlResponse data:[urlCache responseData]];
        }
    }
    return response;
}

- (void) removeRequestFromLocalCache:(NSURLRequest *)request
                           cacheType:(RIURLCacheType)cacheType
{
    if(cacheType == RIURLCacheMemCache)
    {
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
        [self.requests removeObjectForKey:[[request URL] absoluteString]];
    }
    else if(cacheType == RIURLCacheMemCache)
    {
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
        [RIURLCache deleteCachedResponseForUrl:[[request URL] absoluteString]];
    }
}

+ (NSInteger) getCacheTime:(RIURLCacheTime) cacheType
{
    NSInteger cacheTime = 0;
    switch (cacheType) {
        case RIURLCacheMinTime:
            cacheTime = kRIURLCacheMinTime;
            break;
        case RIURLCacheDefaultTime:
            cacheTime = kRIURLCacheDefaultTime;
            break;
        case RIURLCacheMaxTime:
            cacheTime = kRIURLCacheMaxTime;
            break;
        default:
            break;
    }
    return cacheTime;
}

#pragma mark - Method to remove request from memory

- (void)removeFromMemCache:(NSTimer*)timer
{
    NSURLRequest *request =[timer userInfo];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [self.requests removeObjectForKey:[[request URL] absoluteString]];
}

#pragma mark - Method to remove request from DB

- (void)removeFromDBCache:(NSTimer*)timer
{
    NSURLRequest *request =[timer userInfo];
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [RIURLCache deleteCachedResponseForUrl:[[request URL] absoluteString]];
}

@end
