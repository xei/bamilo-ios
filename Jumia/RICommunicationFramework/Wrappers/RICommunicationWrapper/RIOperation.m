//
//  RIOperation.m
//  Comunication Project
//
//  Created by Telmo Pinto on 18/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIOperation.h"

@interface RIOperation()

@end

@implementation RIOperation

#pragma mark - Create and return the Communication Wrapper
- (id)init
{
    self = [super init];
    
    if (self) {
        [self setParameterEncoding:RICWFormURLParameterEncoding];
        [self setShouldRetry:RI_HTTP_REQUEST_SHOULD_RETRY];
        [self setTotalRetriesNumber:RI_HTTP_REQUEST_NUMBER_OF_RETRIES];
        [self setNumberOfRetry:1];
    }
    
    return self;
}

- (void)startRequest
{
    if (self.request) {
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                          delegate:self];
    }
}


#pragma mark - Cancel current request

- (void)cancelRequest
{
    [self.connection cancel];
    [self clearRequestData];
}

#pragma mark - NSURLConnection delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.mutableData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(ISEMPTY(self.mutableData)) {
        self.mutableData = [NSMutableData dataWithData:data];
    } else {
        [self.mutableData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(error.code == NSURLErrorTimedOut && (self.shouldRetry && (self.numberOfRetry < self.totalRetriesNumber)))
    {
        self.numberOfRetry++;
        NSLog(@"Connection failed with timeout error: retry %d of %d", self.numberOfRetry, self.totalRetriesNumber);
        
        // Retry
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                          delegate:self];
    }
    else if(error.code == NSURLErrorTimedOut)
    {
        NSLog(@"Connection failed with error: %@", error);
        self.failureBlock(RIApiResponseTimeOut, nil, error);
        [self clearRequestData];
    }
    else if(error.code == 503)
    {
        NSLog(@"Connection failed with error: %@", error);
        self.failureBlock(RIApiResponseMaintenancePage, nil, error);
        [self clearRequestData];
    }
    else
    {
        NSLog(@"Connection failed with error: %@", error);
        self.failureBlock(RIApiResponseUnknownError, nil, error);
        [self clearRequestData];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:self.mutableData
                                                                 options:kNilOptions
                                                                   error:&error];
    
    if(VALID_NOTEMPTY(error, NSError) || ISEMPTY(responseJSON) || ISEMPTY([responseJSON objectForKey:@"success"]) || ![[responseJSON objectForKey:@"success"] boolValue]) {
        [[RIURLCacheWrapper sharedInstance] removeRequestFromLocalCache:[connection originalRequest]
                                                              cacheType:self.cacheType];
        
        if(VALID_NOTEMPTY(responseJSON, NSDictionary) &&  (!ISEMPTY([responseJSON objectForKey:@"success"]) && ![[responseJSON objectForKey:@"success"] boolValue]))
        {
            self.failureBlock(RIApiResponseAPIError, responseJSON, nil);            
        }
        else
        {
            self.failureBlock(RIApiResponseMaintenancePage, responseJSON, nil);
        }
    } else {
        self.successBlock(RIApiResponseSuccess, responseJSON);
    }
    
    [self clearRequestData];
}


- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSCachedURLResponse *temp = nil;
    
    if( [[connection originalRequest] cachePolicy] == NSURLRequestUseProtocolCachePolicy) {
        [[RIURLCacheWrapper sharedInstance] addRequestToLocalCache:[connection originalRequest]
                                                 willCacheResponse:cachedResponse
                                                         cacheType:self.cacheType
                                                         cacheTime:self.cacheTime];
        temp = cachedResponse;
    }
    
    return temp;
}

// This method allows the application to handle redirects
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (VALID_NOTEMPTY(response, NSURLResponse)) {
        // The request you initialized the connection with should be kept as request.
        // Instead of trying to merge the pieces of request into Cocoa
        // touch's proposed redirect request, we make a mutable copy of the
        // original request, change the URL to match that of the proposed
        // request, and return it as the request to use.
        NSMutableURLRequest *newRequest = [self.request mutableCopy];
        [newRequest setURL: [request URL]];
        return newRequest;
    } else {
        return request;
    }
}

#pragma mark - Private methods

- (void) clearRequestData {
    [[RICommunicationWrapper sharedInstance] operationEnded:self];
}


@end