//
//  RIRatings.h
//  Comunication Project
//
//  Created by Miguel Chaves on 17/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIRatingsOptions : NSObject

@property (strong, nonatomic) NSString *idRatingOption;
@property (strong, nonatomic) NSString *fkRatingType;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *value;
@property (strong, nonatomic) NSString *position;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSString *createdBy;

@end

@interface RIRatingsDetails : NSObject

@property (strong, nonatomic) NSString *idRatingType;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *position;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSString *hasEmail;
@property (strong, nonatomic) NSString *createdBy;
@property (strong, nonatomic) NSArray *options;

@end

@interface RIRatings : NSObject

@property (strong, nonatomic) NSArray *ratingsDetails;

/**
 *  Method to get rating configuration
 *
 *  @param the success block containing the ratings object
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
//+ (NSString *)getRatingsWithSuccessBlock:(void (^)(NSArray* ratings))successBlock
//                         andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

/**
 *  Method to cancel the request
 *
 *  @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

@end
