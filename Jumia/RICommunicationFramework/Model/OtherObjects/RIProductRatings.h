//
//  RIProductRatings.h
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIReview : NSObject

@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* dateString;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSArray* ratingStars;
@property (nonatomic, strong) NSArray* ratingTitles;

@end

@interface RIRatingInfo : NSObject

@property (nonatomic, strong) NSNumber* basedOn;
@property (nonatomic, strong) NSArray* averageRatingsArray;
@property (nonatomic, strong) NSArray* typesArray;
@property (nonatomic, strong) NSDictionary* numberOfRatingsByStar;

@end

@interface RIProductRatings : NSObject

@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productSku;
@property (strong, nonatomic) NSArray *reviews;
@property (nonatomic, strong) RIRatingInfo* ratingInfo;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, strong) NSNumber *totalPages;

/**
 *  Method to review for a product given it's sku
 *
 *  @param the product SKU
 *  @param the success block containing the obtained review
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getRatingsForProductWithSku:(NSString *)sku
                              allowRating:(NSInteger) allowRating
                               pageNumber:(NSInteger) pageNumber
                             successBlock:(void (^)(RIProductRatings *ratings))successBlock
                          andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

+ (NSString *)getRatingsDetails:(NSString *)sku
                   successBlock:(void (^)(NSDictionary* ratingsDictionary))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

/**
 *  Method to cancel the request
 *
 *  @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

@end
