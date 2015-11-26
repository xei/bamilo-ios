//
//  RISellerReviewInfo.h
//  Jumia
//
//  Created by Telmo Pinto on 27/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RISellerReview : NSObject

@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* dateString;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSNumber* average;

@end

@interface RISellerReviewInfo : NSObject

@property (strong, nonatomic) NSString *sellerName;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSArray *reviews;
@property (strong, nonatomic) NSNumber *minDeliveryTime;
@property (strong, nonatomic) NSNumber *maxDeliveryTime;
@property (nonatomic, strong) NSNumber* averageReviews;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, strong) NSNumber *totalPages;


+ (NSString *)getSellerReviewForProductWithTargetString:(NSString *)targetString
                                               pageSize:(NSInteger)pageSize
                                             pageNumber:(NSInteger)pageNumber
                                           successBlock:(void (^)(RISellerReviewInfo *sellerReviewInfo))successBlock
                                        andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

@end
