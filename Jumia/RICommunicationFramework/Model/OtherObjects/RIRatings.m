//
//  RIRatings.m
//  Comunication Project
//
//  Created by Miguel Chaves on 17/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIRatings.h"
@implementation RIRatingsOptions

@end

@implementation RIRatingsDetails

@end

@interface RIRatings ()

@property (strong, nonatomic) NSString* ratingsRequestID;

@end

@implementation RIRatings

+ (NSString*)getRatingsWithSuccessBlock:(void (^)(NSArray *ratings))successBlock
                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_RATING_OPTIONS]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  NSDictionary *dataDic = [metadata objectForKey:@"data"];
                                                                  NSMutableArray *returnArray = [NSMutableArray new];
                                                                  
                                                                  for (NSDictionary *dic in dataDic) {
                                                                      [returnArray addObject:[RIRatings parseRatingWithDictionay:dic]];
                                                                  }
                                                                  
                                                                  successBlock(returnArray);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
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
                                                          }];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Parse Review

+ (RIRatingsDetails *)parseRatingWithDictionay:(NSDictionary *)json
{
    RIRatingsDetails *returnRating = [[RIRatingsDetails alloc] init];
    
    if ([json objectForKey:@"id_rating_type"]) {
        returnRating.idRatingType = [json objectForKey:@"id_rating_type"];
    }
    
    if ([json objectForKey:@"code"]) {
        returnRating.code = [json objectForKey:@"code"];
    }
    
    if ([json objectForKey:@"title"]) {
        returnRating.title = [json objectForKey:@"title"];
    }
    
    if ([json objectForKey:@"position"]) {
        returnRating.position = [json objectForKey:@"position"];
    }
    
    if ([json objectForKey:@"created_at"]) {
        returnRating.createdAt = [json objectForKey:@"created_at"];
    }
    
    if ([json objectForKey:@"has_email"]) {
        returnRating.hasEmail = [json objectForKey:@"has_email"];
    }
    
    if ([json objectForKey:@"created_by"]) {
        returnRating.createdBy = [json objectForKey:@"created_by"];
    }
    
    if ([json objectForKey:@"options"]) {
        
        NSArray *options = [json objectForKey:@"options"];
        NSMutableArray *tempArray = [NSMutableArray new];
        
        for (NSDictionary *option in options) {
            [tempArray addObject:[RIRatings parseRatingOptions:option]];
        }
        
        returnRating.options = [tempArray copy];
    }
    
    return returnRating;
}

+ (RIRatingsOptions *)parseRatingOptions:(NSDictionary *)json
{
    RIRatingsOptions *reviewOptions = [[RIRatingsOptions alloc] init];
    
    if ([json objectForKey:@"id_rating_option"]) {
        reviewOptions.idRatingOption = [json objectForKey:@"id_rating_option"];
    }
    
    if ([json objectForKey:@"fk_rating_type"]) {
        reviewOptions.fkRatingType = [json objectForKey:@"fk_rating_type"];
    }
    
    if ([json objectForKey:@"code"]) {
        reviewOptions.code = [json objectForKey:@"code"];
    }
    
    if ([json objectForKey:@"value"]) {
        reviewOptions.value = [json objectForKey:@"value"];
    }
    
    if ([json objectForKey:@"position"]) {
        reviewOptions.position = [json objectForKey:@"position"];
    }
    
    if ([json objectForKey:@"created_at"]) {
        reviewOptions.createdAt = [json objectForKey:@"created_at"];
    }
    
    if ([json objectForKey:@"created_by"]) {
        reviewOptions.createdBy = [json objectForKey:@"created_by"];
    }
    
    return reviewOptions;
}

@end
