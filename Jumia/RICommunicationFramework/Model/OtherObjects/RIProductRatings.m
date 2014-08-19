//
//  RIProductRatings.m
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIProductRatings.h"

@implementation RIRatingOption

@end

@implementation RIRatingComment

@end

@implementation RIProductRatings

#pragma mark - Send request

+ (NSString *)getRatingsForProductWithUrl:(NSString *)url
                             successBlock:(void (^)(RIProductRatings *ratings))successBlock
                          andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    NSString *operationID = nil;
    
    if (VALID_NOTEMPTY(url, NSString))
    {
        operationID = [[RICommunicationWrapper sharedInstance]
                       sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@", url]]
                       parameters:nil
                       httpMethodPost:YES
                       cacheType:RIURLCacheDBCache
                       cacheTime:RIURLCacheDefaultTime
                       successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               successBlock([RIProductRatings parseRatingWithDictionay:jsonObject]);
                           });
                           
                       } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if(NOTEMPTY(errorJsonObject))
                               {
                                   failureBlock([RIError getErrorMessages:errorJsonObject]);
                               } else if(NOTEMPTY(errorObject))
                               {
                                   NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                   failureBlock(errorArray);
                               } else
                               {
                                   failureBlock(nil);
                               }
                           });
                       }];
    } else {
        failureBlock(nil);
    }
    
    return operationID;
}

+ (NSString *)sendRatingWithSku:(NSString *)sku
                          stars:(NSString *)stars
                         userId:(NSString *)userId
                           name:(NSString *)name
                          title:(NSString *)title
                        comment:(NSString *)comment
                   successBlock:(void (^)(BOOL success))successBlock
                andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    NSString *operationID = nil;
    
    if (VALID_NOTEMPTY(sku, NSString))
    {
        NSString *url = [NSString stringWithFormat:@"%@%@rating/add/?rating-costumer=%@&rating-option--1=%@cenas&rating-catalog-sku=%@&RatingForm[comment]=%@&RatingForm[title]=%@&RatingForm[name]=%@", [RIApi getCountryUrlInUse], RI_API_VERSION, userId, stars, sku, comment, title, name];
        operationID = [[RICommunicationWrapper sharedInstance]
                       sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@", url]]
                       parameters:nil
                       httpMethodPost:YES
                       cacheType:RIURLCacheDBCache
                       cacheTime:RIURLCacheDefaultTime
                       successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               successBlock(YES);
                           });
                           
                       } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               if(NOTEMPTY(errorJsonObject))
                               {
                                   failureBlock([RIError getErrorMessages:errorJsonObject]);
                               } else if(NOTEMPTY(errorObject))
                               {
                                   NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                   failureBlock(errorArray);
                               } else
                               {
                                   failureBlock(nil);
                               }
                           });
                       }];
    }
    else
    {
        failureBlock(nil);
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
    
    RIProductRatings *productRatings = [[RIProductRatings alloc] init];
    
    if ([dic objectForKey:@"product_name"]) {
        productRatings.productName = [dic objectForKey:@"product_name"];
    }
    
    if ([dic objectForKey:@"product_sku"]) {
        productRatings.productSku = [dic objectForKey:@"product_sku"];
    }
    
    if ([dic objectForKey:@"commentsCount"]) {
        productRatings.commentsCount = [dic objectForKey:@"commentsCount"];
    }
    
    if ([dic objectForKey:@"comments"]) {
        NSArray *arrayOfComments = [dic objectForKey:@"comments"];
        NSMutableArray *tempArray = [NSMutableArray new];
        
        for (NSDictionary *commentDic in arrayOfComments) {
            [tempArray addObject:[RIProductRatings parseRatingCommentWithDic:commentDic]];
        }
        
        productRatings.comments = [tempArray copy];
    }
    
    return productRatings;
}

+ (RIRatingComment *)parseRatingCommentWithDic:(NSDictionary *)dic
{    
    RIRatingComment *ratingComment = [[RIRatingComment alloc] init];
    
    if ([dic objectForKey:@"created_at"]) {
        ratingComment.createdAt = [dic objectForKey:@"created_at"];
    }
    
    if ([dic objectForKey:@"id_review"]) {
        ratingComment.idReview = [dic objectForKey:@"id_review"];
    }
    
    if ([dic objectForKey:@"title"]) {
        ratingComment.title = [dic objectForKey:@"title"];
    }
    
    if ([dic objectForKey:@"detail"]) {
        ratingComment.detail = [dic objectForKey:@"detail"];
    }
    
    if ([dic objectForKey:@"email"]) {
        ratingComment.email = [dic objectForKey:@"email"];
    }
    
    if ([dic objectForKey:@"nickname"]) {
        ratingComment.nickname = [dic objectForKey:@"nickname"];
    }
    
    if ([dic objectForKey:@"id_aggregated"]) {
        ratingComment.idAggregated = [dic objectForKey:@"id_aggregated"];
    }
    
    if ([dic objectForKey:@"avg_rating"]) {
        ratingComment.avgRating = [dic objectForKey:@"avg_rating"];
    }
    
    if ([dic objectForKey:@"dateString"]) {
        ratingComment.dateString = [dic objectForKey:@"dateString"];
    }
    
    if ([dic objectForKey:@"options"]) {
        NSArray *arrayOfoptions = [dic objectForKey:@"options"];
        NSMutableArray *tempArray = [NSMutableArray new];
        
        for (NSDictionary *optionDic in arrayOfoptions) {
            [tempArray addObject:[RIProductRatings parseOptionWithDictionary:optionDic]];
        }
        
        ratingComment.options = [tempArray copy];
    }
    
    return ratingComment;
}

+ (RIRatingOption *)parseOptionWithDictionary:(NSDictionary *)dic
{
    RIRatingOption *option = [[RIRatingOption alloc] init];
    
    if ([dic objectForKey:@"option_value"]) {
        option.optionValue = [dic objectForKey:@"option_value"];
    }
    
    if ([dic objectForKey:@"type_title"]) {
        option.typeTitle = [dic objectForKey:@"type_title"];
    }
    
    if ([dic objectForKey:@"title"]) {
        option.title = [dic objectForKey:@"title"];
    }
    
    if ([dic objectForKey:@"percentage_rating"]) {
        option.percentageRating = [dic objectForKey:@"percentage_rating"];
    }
    
    return option;
}

@end
