//
//  RIProductReview.h
//  Comunication Project
//
//  Created by Miguel Chaves on 17/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIReviewCommentsOptions : NSObject

@property (strong, nonatomic) NSString *typeId;
@property (strong, nonatomic) NSString *typeCode;
@property (strong, nonatomic) NSString *typeTitle;
@property (strong, nonatomic) NSString *optionCode;
@property (strong, nonatomic) NSNumber *sizeStarsBack;
@property (strong, nonatomic) NSNumber *sizeStarsFore;

@end

@interface RIReviewComments : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *nickName;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSArray *options;

@end

@interface RIProductReview : NSObject

@property (strong, nonatomic) NSString *productSku;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSArray *comments;

/**
 *  Method to review for a product given it's sku
 *
 *  @param the product SKU
 *  @param the success block containing the obtained review
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getReviewForProductWithSku:(NSString *)sku
                            successBlock:(void (^)(id review))successBlock
                         andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 *  Method to cancel the request
 *
 *  @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

@end
