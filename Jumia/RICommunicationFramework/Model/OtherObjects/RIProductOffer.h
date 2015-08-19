//
//  RIProductOffer.h
//  Jumia
//
//  Created by Telmo Pinto on 23/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RISeller;

@interface RIProductOffer : NSObject

@property (nonatomic, strong) NSString* productSku;
@property (nonatomic, strong) NSString* simpleSku;
@property (nonatomic, strong) NSNumber* price;
@property (nonatomic, strong) NSString* priceFormatted;
@property (nonatomic, strong) NSNumber* priceEuroConverted;
@property (nonatomic, strong) NSNumber* specialPrice;
@property (nonatomic, strong) NSString* specialPriceFormatted;
@property (nonatomic, strong) NSNumber* specialPriceEuroConverted;
@property (nonatomic, strong) NSNumber* minDeliveryTime;
@property (nonatomic, strong) NSNumber* maxDeliveryTime;
@property (nonatomic, strong) RISeller* seller;

+ (NSString*)getProductOffersForProductUrl:(NSString*)productUrl
                              successBlock:(void (^)(NSArray *productOffers))successBlock
                           andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

@end
