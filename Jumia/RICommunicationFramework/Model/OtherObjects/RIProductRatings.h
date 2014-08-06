//
//  RIProductRatings.h
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIRatingOption : NSObject

@property (strong, nonatomic) NSString *optionValue;
@property (strong, nonatomic) NSString *typeTitle;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *percentageRating;

@end

@interface RIRatingComment : NSObject

@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSString *idReview;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *nickname;
@property (strong, nonatomic) NSString *idAggregated;
@property (strong, nonatomic) NSNumber *avgRating;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSArray *options;

@end

@interface RIProductRatings : NSObject

@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSString *productSku;
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
+ (NSString *)getRatingsForProductWithUrl:(NSString *)url
                             successBlock:(void (^)(RIProductRatings *ratings))successBlock
                          andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 *  Method to cancel the request
 *
 *  @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

@end
