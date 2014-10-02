//
//  RIPromotion.h
//  Jumia
//
//  Created by Telmo Pinto on 02/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPromotion : NSObject

@property (nonatomic, strong)NSString* title;
@property (nonatomic, strong)NSString* descriptionMessage;
@property (nonatomic, strong)NSString* couponCode;
@property (nonatomic, strong)NSString* termsAndConditions;
@property (nonatomic, strong)NSString* endDate;

+ (NSString *)getPromotionWithSuccessBlock:(void (^)(RIPromotion* promotion))successBlock
                           andFailureBlock:(void (^)(NSArray *error))failureBlock;

@end
