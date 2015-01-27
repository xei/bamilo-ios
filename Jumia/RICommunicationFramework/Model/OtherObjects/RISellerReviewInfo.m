//
//  RISellerReviewInfo.m
//  Jumia
//
//  Created by Telmo Pinto on 27/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RISellerReviewInfo.h"

@implementation RISellerReview

+(RISellerReview*)parseSellerReview:(NSDictionary*)sellerReviewJSON
{
    RISellerReview* newSellerReview = [[RISellerReview alloc] init];
    
    if ([sellerReviewJSON objectForKey:@"average"]) {
        newSellerReview.average = [sellerReviewJSON objectForKey:@"average"];
    }
    if ([sellerReviewJSON objectForKey:@"comment"]) {
        newSellerReview.comment = [sellerReviewJSON objectForKey:@"comment"];
    }
    if ([sellerReviewJSON objectForKey:@"date"]) {
        newSellerReview.dateString = [sellerReviewJSON objectForKey:@"date"];
    }
    if ([sellerReviewJSON objectForKey:@"name"]) {
        newSellerReview.userName = [sellerReviewJSON objectForKey:@"name"];
    }
    if ([sellerReviewJSON objectForKey:@"title"]) {
        newSellerReview.title = [sellerReviewJSON objectForKey:@"title"];
    }
    
    return newSellerReview;
}

@end


@implementation RISellerReviewInfo

+ (NSString *)getSellerReviewForProductWithUrl:(NSString *)url
                                      pageSize:(NSInteger)pageSize
                                    pageNumber:(NSInteger)pageNumber
                                  successBlock:(void (^)(RISellerReviewInfo *sellerReviewInfo))successBlock
                               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    NSString *operationID = nil;
    
    if (VALID_NOTEMPTY(url, NSString))
    {
        NSString* urlEnding = [NSString stringWithFormat:RI_API_SELLER_RATING, pageSize, pageNumber];
        
        operationID = [[RICommunicationWrapper sharedInstance]
                       sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, urlEnding]]
                       parameters:nil
                       httpMethodPost:YES
                       cacheType:RIURLCacheNoCache
                       cacheTime:RIURLCacheDefaultTime
                       successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                           
                           if ([jsonObject objectForKey:@"metadata"]) {
                               NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                               if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                   if ([metadata objectForKey:@"data"]) {
                                       NSDictionary* data = [metadata objectForKey:@"data"];
                                       if (VALID_NOTEMPTY(data, NSDictionary)) {
                                           
                                           RISellerReviewInfo* sellerReviewInfo = [RISellerReviewInfo parseSellerReviewInfo:data];
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               successBlock(sellerReviewInfo);
                                           });
                                       }
                                   }
                               }
                           }
                           
                       } failureBlock:^(RIApiResponse apiResponse,  NSDictionary *errorJsonObject, NSError *errorObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if(NOTEMPTY(errorJsonObject))
                               {
                                   failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                               } else if(NOTEMPTY(errorObject))
                               {
                                   NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                   failureBlock(apiResponse, errorArray);
                               } else
                               {
                                   failureBlock(apiResponse, nil);
                               }
                           });
                       }];
    } else {
        failureBlock(RIApiResponseUnknownError, nil);
    }
    
    return operationID;
}


+(RISellerReviewInfo*)parseSellerReviewInfo:(NSDictionary*)sellerReviewInfoJSON
{
    RISellerReviewInfo* newSellerReviewInfo = [[RISellerReviewInfo alloc] init];
    
    if ([sellerReviewInfoJSON objectForKey:@"max_delivery_time"]) {
        newSellerReviewInfo.maxDeliveryTime = [sellerReviewInfoJSON objectForKey:@"max_delivery_time"];
    }
    
    if ([sellerReviewInfoJSON objectForKey:@"min_delivery_time"]) {
        newSellerReviewInfo.minDeliveryTime = [sellerReviewInfoJSON objectForKey:@"min_delivery_time"];
    }
    
    if ([sellerReviewInfoJSON objectForKey:@"name"]) {
        newSellerReviewInfo.sellerName = [sellerReviewInfoJSON objectForKey:@"name"];
    }
    
    if ([sellerReviewInfoJSON objectForKey:@"reviews"]) {
        NSDictionary* reviewsJSON = [sellerReviewInfoJSON objectForKey:@"reviews"];
        
        if (VALID_NOTEMPTY(reviewsJSON, NSDictionary)) {
            
            if ([reviewsJSON objectForKey:@"average"]) {
                newSellerReviewInfo.averageReviews = [reviewsJSON objectForKey:@"average"];
            }
            
            if ([reviewsJSON objectForKey:@"comments"]) {
                NSArray* reviewsArray = [reviewsJSON objectForKey:@"comments"];
                
                if (VALID_NOTEMPTY(reviewsArray, NSArray)) {
                    
                    NSMutableArray* sellerReviews = [NSMutableArray new];
                    
                    for (NSDictionary* sellerReviewJSON in reviewsArray) {
                        
                        if (VALID_NOTEMPTY(sellerReviewJSON, NSDictionary)) {
                            
                            RISellerReview* sellerReview = [RISellerReview parseSellerReview:sellerReviewJSON];
                            [sellerReviews addObject:sellerReview];
                        }
                    }
                    
                    newSellerReviewInfo.reviews = [sellerReviews copy];
                }
            }
        }
    }
    
    return newSellerReviewInfo;
}

@end
