//
//  RICampaign.h
//  Jumia
//
//  Created by Telmo Pinto on 25/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RICampaign : NSObject

@property (nonatomic, strong)NSString* bannerImageURL;
@property (nonatomic, strong)NSString* name;
@property (nonatomic, strong)NSArray* campaignProducts;

+ (NSString *)getCampaignWithUrl:(NSString*)url
                    successBlock:(void (^)(RICampaign* campaign))successBlock
                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

+ (NSString *)getCampaignWithId:(NSString*)campaignId
                   successBlock:(void (^)(RICampaign* campaign))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

@end

@interface RICampaignProduct : NSObject

@property (nonatomic, strong) NSNumber* savePrice;
@property (nonatomic, strong) NSString* savePriceFormatted;
@property (nonatomic, strong) NSNumber* savePriceEuroConverted;
@property (nonatomic, strong) NSNumber* specialPrice;
@property (nonatomic, strong) NSString* specialPriceFormatted;
@property (nonatomic, strong) NSNumber* specialPriceEuroConverted;
@property (nonatomic, strong) NSNumber* maxSpecialPrice;
@property (nonatomic, strong) NSString* maxSpecialPriceFormatted;
@property (nonatomic, strong) NSNumber* maxSpecialPriceEuroConverted;
@property (nonatomic, strong) NSNumber* price;
@property (nonatomic, strong) NSString* priceFormatted;
@property (nonatomic, strong) NSNumber* priceEuroConverted;
@property (nonatomic, strong) NSNumber* maxPrice;
@property (nonatomic, strong) NSString* maxPriceFormatted;
@property (nonatomic, strong) NSNumber* maxPriceEuroConverted;
@property (nonatomic, strong) NSNumber* stockPercentage;
@property (nonatomic, strong) NSNumber* maxSavingPercentage;
@property (nonatomic, strong) NSString* sku;
@property (nonatomic, strong) NSString* brand;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* imagesUrl;
@property (nonatomic, strong) NSArray* productSimples;
@property (nonatomic, strong) NSNumber* remainingTime;

+ (RICampaignProduct*)parseCampaignProduct:(NSDictionary*)campaignProductJSON
                                   country:(RICountryConfiguration*)country;
@end

@interface RICampaignProductSimple : NSObject

@property (nonatomic, strong)NSString* sku;
@property (nonatomic, strong)NSNumber* price;
@property (nonatomic, strong)NSString* priceFormatted;
@property (nonatomic, strong)NSNumber* savePrice;
@property (nonatomic, strong)NSString* savePriceFormatted;
@property (nonatomic, strong)NSString* size;

+ (RICampaignProductSimple*)parseCampaignProductSimple:(NSDictionary*)campaignProductSimpleJSON
                                               country:(RICountryConfiguration*)country;

@end