//
//  RIProductReview.m
//  Comunication Project
//
//  Created by Miguel Chaves on 17/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIProductReview.h"

@implementation RIReviewCommentsOptions

@end

@implementation RIReviewComments

@end


@implementation RIProductReview

#pragma mark - Get costumer

+ (NSString*)getReviewForProductWithSku:(NSString *)sku
                           successBlock:(void (^)(id review))successBlock
                        andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock
{
    NSString *operationID = nil;
    if (VALID_NOTEMPTY(sku, NSString)) {
        NSDictionary *dic = @{@"sku": sku };
        operationID = [[RICommunicationWrapper sharedInstance]
                       sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_RATING_OPTIONS]]
                       parameters:dic
                       httpMethodPost:YES
                       cacheType:RIURLCacheDBCache
                       cacheTime:RIURLCacheDefaultTime
                       successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                           
                           successBlock([RIProductReview parseReviewWithDictionay:jsonObject]);
                           
                       } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                           
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
                       }];
    } else {
        failureBlock(nil);
    }
    
    return operationID;
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Parse Review

+ (RIProductReview *)parseReviewWithDictionay:(NSDictionary *)json
{
    RIProductReview *returnReview = [[RIProductReview alloc] init];
    
    if ([json objectForKey:@"product_sku"]) {
        returnReview.productSku = [json objectForKey:@"product_sku"];
    }
    
    if ([json objectForKey:@"product_name"]) {
        returnReview.productName = [json objectForKey:@"product_name"];
    }
    
    if ([json objectForKey:@"commentsCount"]) {
        returnReview.commentsCount = [NSNumber numberWithInt:[[json objectForKey:@"commentsCount"] intValue]];
    }
    
    if ([json objectForKey:@"comments"]) {
        
        NSArray *comments = [json objectForKey:@"comments"];
        NSMutableArray *tempArray = [NSMutableArray new];
        
        for (NSDictionary *comment in comments) {
            [tempArray addObject:[RIProductReview parseReviewComment:comment]];
        }
        
        returnReview.comments = [tempArray copy];
    }
    
    return returnReview;
}

+ (RIReviewComments *)parseReviewComment:(NSDictionary *)json
{
    RIReviewComments *reviewComment = [[RIReviewComments alloc] init];
    
    if ([json objectForKey:@"title"]) {
        reviewComment.title = [json objectForKey:@"title"];
    }
    
    if ([json objectForKey:@"detail"]) {
        reviewComment.detail = [json objectForKey:@"detail"];
    }
    
    if ([json objectForKey:@"nickname"]) {
        reviewComment.nickName = [json objectForKey:@"nickname"];
    }
    
    if ([json objectForKey:@"created_at"]) {
        reviewComment.createdAt = [json objectForKey:@"created_at"];
    }
    
    if ([json objectForKey:@"options"]) {
        
        NSArray *optionsArray = [json objectForKey:@"options"];
        NSMutableArray *returnArray = [NSMutableArray new];
        
        for (NSDictionary *option in optionsArray) {
            [returnArray addObject:[RIProductReview parseReviewCommentsOptions:option]];
        }
        
        reviewComment.options = [returnArray copy];
    }
    
    return reviewComment;
}

+ (RIReviewCommentsOptions *)parseReviewCommentsOptions:(NSDictionary *)json
{
    RIReviewCommentsOptions *commentsOptions = [[RIReviewCommentsOptions alloc] init];
    
    if ([json objectForKey:@"type_id"]) {
        commentsOptions.typeId = [json objectForKey:@"type_id"];
    }
    
    if ([json objectForKey:@"type_code"]) {
        commentsOptions.typeCode = [json objectForKey:@"type_code"];
    }
    
    if ([json objectForKey:@"type_title"]) {
        commentsOptions.typeTitle = [json objectForKey:@"type_title"];
    }
    
    if ([json objectForKey:@"option_code"]) {
        commentsOptions.optionCode = [json objectForKey:@"optionCode"];
    }
    
    if ([json objectForKey:@"size_stars_back"]) {
        commentsOptions.sizeStarsBack = [NSNumber numberWithInt:[[json objectForKey:@"size_stars_back"] intValue]];
    }
    
    if ([json objectForKey:@"size_stars_fore"]) {
        commentsOptions.sizeStarsFore = [NSNumber numberWithInt:[[json objectForKey:@"size_stars_fore"] intValue]];
    }
    
    return commentsOptions;
}

@end
