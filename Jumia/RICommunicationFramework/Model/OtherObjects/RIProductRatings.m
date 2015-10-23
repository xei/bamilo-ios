//
//  RIProductRatings.m
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIProductRatings.h"

@implementation RIReview

+ (NSArray*)parseReviews:(NSDictionary*)reviewsJSON
{
    RIReview *review = [[RIReview alloc]init];
    NSMutableArray* newReviews = [NSMutableArray new];
    
    if ([reviewsJSON objectForKey:@"comments"]) {
        
        NSArray* comments = [reviewsJSON objectForKey:@"comments"];
        if (VALID_NOTEMPTY(comments, NSArray)) {
            
            for (NSDictionary* comment in comments) {
                if (VALID_NOTEMPTY(comment, NSDictionary)) {
                    
                    review = [RIReview parseReview:comment];
                    
                    [newReviews addObject:review];
                }
            }
        }
    }
    
    return [newReviews copy];
}

+ (RIReview*)parseReview:(NSDictionary*)reviewJSON
{
    RIReview* newReview = [[RIReview alloc] init];
    
    if ([reviewJSON objectForKey:@"name"]) {
        newReview.userName = [reviewJSON objectForKey:@"name"];
    }
    
    if ([reviewJSON objectForKey:@"title"]) {
        newReview.title = [reviewJSON objectForKey:@"title"];
    }
    
    if ([reviewJSON objectForKey:@"comment"]) {
        newReview.comment = [reviewJSON objectForKey:@"comment"];
    }
    
    if ([reviewJSON objectForKey:@"date"]) {
        newReview.dateString = [reviewJSON objectForKey:@"date"];
    }
    
    if ([reviewJSON objectForKey:@"stars"]) {
        
        NSArray* starsJSON = [reviewJSON objectForKey:@"stars"];
        if (VALID_NOTEMPTY(starsJSON, NSArray)) {
            
            NSMutableArray* stars = [NSMutableArray new];
            NSMutableArray* titles = [NSMutableArray new];
            for (NSDictionary* star in starsJSON) {
                
                if (VALID_NOTEMPTY(star, NSDictionary)) {
                    
                    if ([star objectForKey:@"title"] && [star objectForKey:@"average"]) {
                        
                        NSString* title = [star objectForKey:@"title"];
                        NSNumber* average = [star objectForKey:@"average"];
                        
                        if (VALID_NOTEMPTY(title, NSString) && VALID_NOTEMPTY(average, NSNumber)) {
                            
                            [stars addObject:average];
                            [titles addObject:title];
                        }
                    }
                }
            }
            
            newReview.ratingStars = [stars copy];
            newReview.ratingTitles = [titles copy];
        }
    }
    
    return newReview;
}

@end

@implementation RIRatingInfo

+ (RIRatingInfo*)parseRatingInfo:(NSDictionary*)ratingInfoJSON
{
    RIRatingInfo* newRatingInfo = [[RIRatingInfo alloc] init];
    
    if ([ratingInfoJSON objectForKey:@"based_on"]) {
        newRatingInfo.basedOn = [ratingInfoJSON objectForKey:@"based_on"];
    }
    
    if ([ratingInfoJSON objectForKey:@"by_type"]) {
        
        NSArray* byTypeArray = [ratingInfoJSON objectForKey:@"by_type"];
        if (VALID_NOTEMPTY(byTypeArray, NSArray)) {
            
            NSMutableArray* averages = [NSMutableArray new];
            NSMutableArray* titles = [NSMutableArray new];
            
            for (NSDictionary* byType in byTypeArray) {
                
                if (VALID_NOTEMPTY(byType, NSDictionary)) {
                    
                    if ([byType objectForKey:@"average"] && [byType objectForKey:@"title"]) {
                        
                        NSNumber* average = [byType objectForKey:@"average"];
                        NSString* title = [byType objectForKey:@"title"];
                        
                        if (VALID_NOTEMPTY(average, NSNumber) && VALID_NOTEMPTY(title, NSString)) {
                            [averages addObject:average];
                            [titles addObject:title];
                        }
                    }
                }
            }
            
            newRatingInfo.averageRatingsArray = [averages copy];
            newRatingInfo.typesArray = [titles copy];
        }
    }
    
    if ([ratingInfoJSON objectForKey:@"by_stars"]) {
        
        NSDictionary* byStars = [ratingInfoJSON objectForKey:@"by_stars"];
        
        if (VALID_NOTEMPTY(byStars, NSDictionary) && [byStars objectForKey:@"stars"]) {
            
            NSDictionary* stars = [byStars objectForKey:@"stars"];
            
            if (VALID_NOTEMPTY(stars, NSDictionary)) {
                
                newRatingInfo.numberOfRatingsByStar = [stars copy];
            }
        }
    }
    
    return newRatingInfo;
}

@end

@implementation RIProductRatings

#pragma mark - Send request

+ (NSString *)getRatingsForProductWithUrl:(NSString *)url
                              allowRating:(NSInteger) allowRating
                               pageNumber:(NSInteger) pageNumber
                             successBlock:(void (^)(RIProductRatings *ratings))successBlock
                          andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;{
    NSString *operationID = nil;
    
    if (VALID_NOTEMPTY(url, NSString))
    {
        NSString* urlEnding = [NSString stringWithFormat:RI_API_PROD_RATING, allowRating, pageNumber];
        
        operationID = [[RICommunicationWrapper sharedInstance]
                       sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", url, urlEnding]]
                       parameters:nil
                       httpMethodPost:YES
                       cacheType:RIURLCacheDBCache
                       cacheTime:RIURLCacheDefaultTime
                       userAgentInjection:[RIApi getCountryUserAgentInjection]
                       successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                           
                           if ([jsonObject objectForKey:@"metadata"]) {
                              
                                           RIProductRatings* productRatingInfo = [RIProductRatings parseRatingWithDictionay:jsonObject];
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               successBlock(productRatingInfo);
                                           });
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

+ (NSString *)getRatingsDetails:(NSString *)sku successBlock:(void (^)(NSDictionary *))successBlock andFailureBlock:(void (^)(RIApiResponse, NSArray *))failureBlock
{
    NSString *finalUrl = [NSString stringWithFormat:@"%@%@catalog/details?sku=%@&rating=1", [RIApi getCountryUrlInUse], RI_API_VERSION, sku];
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:finalUrl]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  NSDictionary* data = [metadata objectForKey:@"data"];
                                                                  if (VALID_NOTEMPTY(data, NSDictionary)) {
                                                                      NSDictionary* ratings = [data objectForKey:@"ratings"];
                                                                      if (VALID_NOTEMPTY(ratings, NSDictionary)) {
                                                                          NSDictionary* stars = [ratings objectForKey:@"by_stars"];
                                                                          if (VALID_NOTEMPTY(stars, NSDictionary)) {
                                                                              successBlock(stars);
                                                                              return;
                                                                          }
                                                                      }
                                                                  }
                                                              }
                                                              failureBlock(apiResponse, nil);
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
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

+ (NSString *)sendRatingWithSku:(NSString *)sku
                          stars:(NSString *)stars
                         userId:(NSString *)userId
                           name:(NSString *)name
                          title:(NSString *)title
                        comment:(NSString *)comment
                   successBlock:(void (^)(BOOL success))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSString *operationID = nil;
    
    if (VALID_NOTEMPTY(sku, NSString))
    {
        NSString *url = [NSString stringWithFormat:@"%@%@rating/add/?rating-costumer=%@&rating-option--1=%@&rating-catalog-sku=%@&RatingForm[comment]=%@&RatingForm[title]=%@&RatingForm[name]=%@", [RIApi getCountryUrlInUse], RI_API_VERSION, userId, stars, sku, comment, title, name];
        operationID = [[RICommunicationWrapper sharedInstance]
                       sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@", url]]
                       parameters:nil
                       httpMethodPost:YES
                       cacheType:RIURLCacheDBCache
                       cacheTime:RIURLCacheDefaultTime
                       userAgentInjection:[RIApi getCountryUserAgentInjection]
                       successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               successBlock(YES);
                           });
                           
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
    }
    else
    {
        failureBlock(RIApiResponseUnknownError, nil);
    }
    
    return operationID;
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString)) {
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
    }
}

#pragma mark - Parsers

+ (RIProductRatings *)parseRatingWithDictionay:(NSDictionary *)dictionary
{
    NSDictionary *metadata = [dictionary objectForKey:@"metadata"];
    NSDictionary *dic = [metadata objectForKey:@"data"];
    
    RIProductRatings *newProductRatings = [[RIProductRatings alloc] init];
    
    if ([dic objectForKey:@"product"]) {
        
        NSDictionary* product = [dic objectForKey:@"product"];
        if (VALID_NOTEMPTY(product, NSDictionary)) {
            if ([product objectForKey:@"sku"]) {
                newProductRatings.productSku = [dic objectForKey:@"sku"];
            }
            if ([product objectForKey:@"name"]) {
                newProductRatings.productName = [dic objectForKey:@"name"];
            }
        }
    }
    
    if ([dic objectForKey:@"reviews"])
    {
        NSDictionary *reviewsJSON = [dic objectForKey:@"reviews"];
        if (VALID_NOTEMPTY(reviewsJSON, NSDictionary)) {
            if([reviewsJSON objectForKey:@"pagination"]){
                
                NSDictionary *paginationJSON = [reviewsJSON objectForKey:@"pagination"];
                if(VALID_NOTEMPTY(paginationJSON, NSDictionary)){
                    if ([paginationJSON objectForKey:@"current_page"]) {
                        newProductRatings.currentPage = [paginationJSON objectForKey:@"current_page"];
                    }
                    
                    if([paginationJSON objectForKey:@"total_pages"]){
                        newProductRatings.totalPages = [paginationJSON objectForKey:@"total_pages"];
                    }
                }
            }
        }
    }
    
    if ([dic objectForKey:@"ratings"]) {
        
        NSDictionary* ratingInfoJSON = [dic objectForKey:@"ratings"];
        if (VALID_NOTEMPTY(ratingInfoJSON, NSDictionary)) {
            
            newProductRatings.ratingInfo = [RIRatingInfo parseRatingInfo:ratingInfoJSON];
        }
    }
    
    if ([dic objectForKey:@"reviews"]) {
        
        NSDictionary* reviewsJSON = [dic objectForKey:@"reviews"];
        if (VALID_NOTEMPTY(reviewsJSON, NSDictionary)) {
            
            newProductRatings.reviews = [RIReview parseReviews:reviewsJSON];
        }
    }

    return newProductRatings;
}

@end
