//
//  RICampaign.h
//  Jumia
//
//  Created by Telmo Pinto on 25/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RICampaign : NSObject

@property (nonatomic, strong) NSNumber* savePrice;
@property (nonatomic, strong) NSString* savePriceFormatted;
@property (nonatomic, strong) NSNumber* specialPrice;
@property (nonatomic, strong) NSString* specialPriceFormatted;
@property (nonatomic, strong) NSNumber* maxSpecialPrice;
@property (nonatomic, strong) NSString* maxSpecialPriceFormatted;
@property (nonatomic, strong) NSNumber* price;
@property (nonatomic, strong) NSString* priceFormatted;
@property (nonatomic, strong) NSNumber* maxPrice;
@property (nonatomic, strong) NSString* maxPriceFormatted;
@property (nonatomic, strong) NSNumber* stockPercentage;
@property (nonatomic, strong) NSNumber* maxSavingPercentage;
@property (nonatomic, strong) NSString* sku;
@property (nonatomic, strong) NSString* brand;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSArray* imagesUrls;

+ (NSString *)getCampaignsWithUrl:(NSString*)url
                     successBlock:(void (^)(NSArray* campaigns))successBlock
                  andFailureBlock:(void (^)(NSArray *error))failureBlock;

@end
