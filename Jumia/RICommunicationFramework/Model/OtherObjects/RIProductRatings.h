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
@property (nonatomic, strong) NSDictionary* averageRatingsByTypeTitle;
@property (nonatomic, strong) NSDictionary* numberOfRatingsByStar;

@end

@interface RIProductRatings : NSObject

@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productSku;
@property (strong, nonatomic) NSArray *reviews;
@property (nonatomic, strong) RIRatingInfo* ratingInfo;

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
                          andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 *  Method to cancel the request
 *
 *  @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

/**
 *  Method to send a rating for one product
 *
 *  @param the product SKU
 *  @param the number of stars that the user give to the product
 *  @param user id, it's 0 case the user it's not logged in
 *  @param the rating author's name
 *  @param the rating title
 *  @param the comment
 *  @param the success block containing sucess or not
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)sendRatingWithSku:(NSString *)sku
                          stars:(NSString *)stars
                         userId:(NSString *)userId
                           name:(NSString *)name
                          title:(NSString *)title
                        comment:(NSString *)comment
                   successBlock:(void (^)(BOOL success))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

@end
