//
//  RICampaign.m
//  Jumia
//
//  Created by Telmo Pinto on 25/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICampaign.h"
#import "RITarget.h"

@implementation RICampaign

+ (NSString *)getCampaignWithTargetString:(NSString*)targetString
                             successBlock:(void (^)(RICampaign* campaign))successBlock
                          andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    NSString* url = [RITarget getURLStringforTargetString:targetString];
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]    
                                                            parameters:nil
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  NSDictionary* data = [metadata objectForKey:@"data"];
                                                                  
                                                                  if (VALID_NOTEMPTY(data, NSDictionary)) {
                                                                      RICampaign* campaign = [RICampaign parseCampaign:data country:configuration];
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          successBlock(campaign);
                                                                      });
                                                                  }
                                                                  else
                                                                  {
                                                                      failureBlock(RIApiResponseAPIError, nil);
                                                                  }
                                                                  
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorCodes:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

+ (NSString *)getCampaignWithId:(NSString*)campaignId
                   successBlock:(void (^)(RICampaign* campaign))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    NSString *campaignUrl = [NSString stringWithFormat:RI_GET_CAMPAIGN, campaignId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, campaignUrl]];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:nil
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  NSDictionary* data = [metadata objectForKey:@"data"];
                                                                  
                                                                  if (VALID_NOTEMPTY(data, NSDictionary)) {
                                                                      RICampaign* campaign = [RICampaign parseCampaign:data country:configuration];
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          successBlock(campaign);
                                                                      });
                                                                  }
                                                                  else
                                                                  {
                                                                      failureBlock(RIApiResponseAPIError, nil);
                                                                  }
                                                                  
                                                              } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                                                  failureBlock(apiResponse, nil);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
    
}

+ (RICampaign*)parseCampaign:(NSDictionary*)campaignJSON
                     country:(RICountryConfiguration*)country
{
    RICampaign* newCampaign = [[RICampaign alloc] init];
    
    NSDictionary* cms = [campaignJSON objectForKey:@"cms"];
    if (VALID_NOTEMPTY(cms, NSDictionary))
    {
        NSString *campaignsImageKey = @"mobile_banner";
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            campaignsImageKey = @"desktop_banner";
        }
        
        NSArray* bannerArray = [cms objectForKey:campaignsImageKey];
        if (VALID_NOTEMPTY(bannerArray, NSArray)) {
            NSString* bannerImageURL = [bannerArray firstObject];
            if (VALID_NOTEMPTY(bannerImageURL, NSString)) {
                newCampaign.bannerImageURL = [bannerImageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
        }
    }
    
    NSDictionary* campaignData = [campaignJSON objectForKey:@"campaign_entity"];
    if (VALID_NOTEMPTY(campaignData, NSDictionary)) {
        newCampaign.name = [campaignData objectForKey:@"name"];

        NSArray* campaignProductsData = [campaignData objectForKey:@"products"];
        NSMutableArray* campaignProducts = [NSMutableArray new];
        
        for (NSDictionary* singleCampaignProductJSON in campaignProductsData) {
            if (VALID_NOTEMPTY(singleCampaignProductJSON, NSDictionary)) {
                RICampaignProduct* campaignProduct = [RICampaignProduct parseCampaignProduct:singleCampaignProductJSON country:country];
                [campaignProducts addObject:campaignProduct];
            }
        }
        
        newCampaign.campaignProducts = campaignProducts;
    }

    return newCampaign;
}

@end

@implementation RICampaignProduct

+ (RICampaignProduct*)parseCampaignProduct:(NSDictionary*)campaignProductJSON
                                   country:(RICountryConfiguration*)country
{
    RICampaignProduct* campaignProduct = [[RICampaignProduct alloc] init];
    
    if (VALID_NOTEMPTY(campaignProductJSON, NSDictionary)) {
        
        if ([campaignProductJSON objectForKey:@"save_price"]) {
            if (![[campaignProductJSON objectForKey:@"save_price"] isKindOfClass:[NSNull class]]) {
                campaignProduct.savePrice = [campaignProductJSON objectForKey:@"save_price"];
                campaignProduct.savePriceFormatted = [RICountryConfiguration formatPrice:campaignProduct.savePrice country:country];
            }
        }
        if ([campaignProductJSON objectForKey:@"save_price_converted"]) {
            if (![[campaignProductJSON objectForKey:@"save_price_converted"] isKindOfClass:[NSNull class]]) {
                campaignProduct.savePriceEuroConverted = [campaignProductJSON objectForKey:@"save_price_converted"];
            }
        }
        if ([campaignProductJSON objectForKey:@"special_price"]) {
            if (![[campaignProductJSON objectForKey:@"special_price"] isKindOfClass:[NSNull class]]) {
                campaignProduct.specialPrice = [campaignProductJSON objectForKey:@"special_price"];
                campaignProduct.specialPriceFormatted = [RICountryConfiguration formatPrice:campaignProduct.specialPrice country:country];
            }
        }
        if ([campaignProductJSON objectForKey:@"special_price_converted"]) {
            if (![[campaignProductJSON objectForKey:@"special_price_converted"] isKindOfClass:[NSNull class]]) {
                campaignProduct.specialPriceEuroConverted = [campaignProductJSON objectForKey:@"special_price_converted"];
            }
        }
        if ([campaignProductJSON objectForKey:@"price"]) {
            if (![[campaignProductJSON objectForKey:@"price"] isKindOfClass:[NSNull class]]) {
                campaignProduct.price = [campaignProductJSON objectForKey:@"price"];
                campaignProduct.priceFormatted = [RICountryConfiguration formatPrice:campaignProduct.price country:country];
            }
        }
        if ([campaignProductJSON objectForKey:@"price_converted"]) {
            if (![[campaignProductJSON objectForKey:@"price_converted"] isKindOfClass:[NSNull class]]) {
                campaignProduct.priceEuroConverted = [campaignProductJSON objectForKey:@"price_converted"];
            }
        }
        if ([campaignProductJSON objectForKey:@"brand"]) {
            if (![[campaignProductJSON objectForKey:@"brand"] isKindOfClass:[NSNull class]]) {
                campaignProduct.brand = [campaignProductJSON objectForKey:@"brand"];
            }
        }
        if ([campaignProductJSON objectForKey:@"name"]) {
            if (![[campaignProductJSON objectForKey:@"name"] isKindOfClass:[NSNull class]]) {
                campaignProduct.name = [campaignProductJSON objectForKey:@"name"];
            }
        }
        if ([campaignProductJSON objectForKey:@"stock_percentage"]) {
            if (![[campaignProductJSON objectForKey:@"stock_percentage"] isKindOfClass:[NSNull class]]) {
                campaignProduct.stockPercentage = [campaignProductJSON objectForKey:@"stock_percentage"];
            }
        }
        if ([campaignProductJSON objectForKey:@"max_saving_percentage"]) {
            if (![[campaignProductJSON objectForKey:@"max_saving_percentage"] isKindOfClass:[NSNull class]]) {
                if (VALID_NOTEMPTY([campaignProductJSON objectForKey:@"max_saving_percentage"], NSString)) {
                    NSString* maxSavingPercentageString = [campaignProductJSON objectForKey:@"max_saving_percentage"];
                    campaignProduct.maxSavingPercentage = [NSNumber numberWithInteger:[maxSavingPercentageString integerValue]];
                }
                if (VALID_NOTEMPTY([campaignProductJSON objectForKey:@"max_saving_percentage"], NSNumber)) {
                    campaignProduct.maxSavingPercentage = [campaignProductJSON objectForKey:@"max_saving_percentage"];    
                }
            }
        }
        
        if ([campaignProductJSON objectForKey:@"remaining_time"]) {
            if (![[campaignProductJSON objectForKey:@"remaining_time"] isKindOfClass:[NSNull class]]) {
                campaignProduct.remainingTime = [campaignProductJSON objectForKey:@"remaining_time"];
            }
        }
        
        if ([campaignProductJSON objectForKey:@"image"]) {
            if (![[campaignProductJSON objectForKey:@"image"] isKindOfClass:[NSNull class]])
                campaignProduct.imagesUrl = [campaignProductJSON objectForKey:@"image"];
        }
        
        if ([campaignProductJSON objectForKey:@"target"] && VALID_NOTEMPTY([campaignProductJSON objectForKey:@"target"], NSString)) {
            campaignProduct.targetString = [campaignProductJSON objectForKey:@"target"];
        }
        
        NSArray* sizesArray = [campaignProductJSON objectForKey:@"sizes"];
        if (VALID_NOTEMPTY(sizesArray, NSArray)) {
            
            NSMutableArray* productSimples = [NSMutableArray new];
            
            for (NSDictionary* sizeJSON in sizesArray) {
                
                if (VALID_NOTEMPTY(sizeJSON, NSDictionary)) {
                    
                    RICampaignProductSimple* campaignProductSimple = [RICampaignProductSimple parseCampaignProductSimple:sizeJSON
                                                                                                                 country:country];
                    [productSimples addObject:campaignProductSimple];
                }
            }
            
            campaignProduct.productSimples = [productSimples copy];
        }
    }
    
    return campaignProduct;
}

@end

@implementation RICampaignProductSimple

+ (RICampaignProductSimple*)parseCampaignProductSimple:(NSDictionary*)campaignProductSimpleJSON
                                               country:(RICountryConfiguration*)country
{
    RICampaignProductSimple* campaignProductSimple = [[RICampaignProductSimple alloc] init];
    
    if ([campaignProductSimpleJSON objectForKey:@"save_price"]) {
        if (![[campaignProductSimpleJSON objectForKey:@"save_price"] isKindOfClass:[NSNull class]]) {
            campaignProductSimple.savePrice = [campaignProductSimpleJSON objectForKey:@"save_price"];
            campaignProductSimple.savePriceFormatted = [RICountryConfiguration formatPrice:campaignProductSimple.savePrice country:country];
        }
    }
    if ([campaignProductSimpleJSON objectForKey:@"price"]) {
        if (![[campaignProductSimpleJSON objectForKey:@"price"] isKindOfClass:[NSNull class]]) {
            campaignProductSimple.price = [campaignProductSimpleJSON objectForKey:@"price"];
            campaignProductSimple.priceFormatted = [RICountryConfiguration formatPrice:campaignProductSimple.price country:country];
        }
    }
    if ([campaignProductSimpleJSON objectForKey:@"sku"]) {
        if (![[campaignProductSimpleJSON objectForKey:@"sku"] isKindOfClass:[NSNull class]]) {
            campaignProductSimple.sku = [campaignProductSimpleJSON objectForKey:@"sku"];
        }
    }
    if ([campaignProductSimpleJSON objectForKey:@"size"]) {
        if (![[campaignProductSimpleJSON objectForKey:@"size"] isKindOfClass:[NSNull class]]) {
            campaignProductSimple.size = [campaignProductSimpleJSON objectForKey:@"size"];
        }
    }
    
    return campaignProductSimple;
}

@end