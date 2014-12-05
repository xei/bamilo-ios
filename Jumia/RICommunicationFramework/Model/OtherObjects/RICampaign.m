//
//  RICampaign.m
//  Jumia
//
//  Created by Telmo Pinto on 25/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICampaign.h"

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


@implementation RICampaign

+ (NSString *)getCampaignsWithUrl:(NSString*)url
                     successBlock:(void (^)(NSString *name, NSArray* campaigns, NSString* bannerImageUrl))successBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:url]
                                                            parameters:nil
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  NSDictionary* data = [metadata objectForKey:@"data"];
                                                                  
                                                                  NSString* bannerImageUrl;
                                                                  
                                                                  NSDictionary* cms = [data objectForKey:@"cms"];
                                                                  if (VALID_NOTEMPTY(cms, NSDictionary))
                                                                  {
                                                                      NSString *campaignsImageKey = @"mobile_banner";
                                                                      if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                                                                      {
                                                                          campaignsImageKey = @"desktop_banner";
                                                                      }

                                                                      NSArray* bannerArray = [cms objectForKey:campaignsImageKey];
                                                                      if (VALID_NOTEMPTY(bannerArray, NSArray)) {
                                                                          bannerImageUrl = [bannerArray firstObject];
                                                                      }
                                                                  }
                                                                  
                                                                  NSDictionary* campaign = [data objectForKey:@"campaign"];
                                                                  NSString* name = [campaign objectForKey:@"name"];
                                                                  NSArray* campaignData = [campaign objectForKey:@"data"];
                                                                  
                                                                  if (VALID_NOTEMPTY(campaignData, NSArray)) {
                                                                      NSArray* campaignsArray = [RICampaign parseCampaigns:campaignData country:configuration];
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          successBlock(name, campaignsArray, bannerImageUrl);
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

+ (NSString *)getCampaignsWitId:(NSString*)campaignId
                   successBlock:(void (^)(NSString *name, NSArray* campaigns, NSString* bannerImageUrl))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
{
    NSString *campaignUrl = [NSString stringWithFormat:RI_GET_CAMPAIGN, campaignId];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, campaignUrl]];
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url
                                                            parameters:nil
                                                        httpMethodPost:NO
                                                             cacheType:RIURLCacheDBCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                                                                  
                                                                  NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                  NSDictionary* data = [metadata objectForKey:@"data"];
                                                                  
                                                                  NSString* bannerImageUrl;
                                                                  
                                                                  NSDictionary* cms = [data objectForKey:@"cms"];
                                                                  if (VALID_NOTEMPTY(cms, NSDictionary))
                                                                  {
                                                                      NSString *campaignsImageKey = @"mobile_banner";
                                                                      if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                                                                      {
                                                                          campaignsImageKey = @"desktop_banner";
                                                                      }
                                                                      
                                                                      NSArray* bannerArray = [cms objectForKey:campaignsImageKey];
                                                                      if (VALID_NOTEMPTY(bannerArray, NSArray)) {
                                                                          bannerImageUrl = [bannerArray firstObject];
                                                                      }
                                                                  }
                                                                  
                                                                  NSDictionary* campaign = [data objectForKey:@"campaign"];
                                                                  if(VALID_NOTEMPTY(campaign, NSDictionary))
                                                                  {
                                                                      NSString* name = [campaign objectForKey:@"name"];
                                                                      NSArray* campaignData = [campaign objectForKey:@"data"];
                                                                      
                                                                      if (VALID_NOTEMPTY(campaignData, NSArray)) {
                                                                          NSArray* campaignsArray = [RICampaign parseCampaigns:campaignData country:configuration];
                                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                                              successBlock(name, campaignsArray, bannerImageUrl);
                                                                          });
                                                                      }
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

+ (NSArray*)parseCampaigns:(NSArray*)campaignsJSON
                   country:(RICountryConfiguration*)country
{
    NSMutableArray* campaigns = [NSMutableArray new];
    
    for (NSDictionary* singleCampaignJSON in campaignsJSON) {
        if (VALID_NOTEMPTY(singleCampaignJSON, NSDictionary)) {
            RICampaign* campaign = [RICampaign parseCampaign:singleCampaignJSON country:country];
            [campaigns addObject:campaign];
        }
    }
    
    return campaigns;
}

+ (RICampaign*)parseCampaign:(NSDictionary*)campaignJSON
                     country:(RICountryConfiguration*)country
{
    RICampaign* campaign = [[RICampaign alloc] init];
    
    if (VALID_NOTEMPTY(campaignJSON, NSDictionary)) {
        
        if ([campaignJSON objectForKey:@"save_price"]) {
            if (![[campaignJSON objectForKey:@"save_price"] isKindOfClass:[NSNull class]]) {
                campaign.savePrice = [campaignJSON objectForKey:@"save_price"];
                campaign.savePriceFormatted = [RICountryConfiguration formatPrice:campaign.savePrice country:country];
            }
        }
        if ([campaignJSON objectForKey:@"save_price_euroConverted"]) {
            if (![[campaignJSON objectForKey:@"save_price_euroConverted"] isKindOfClass:[NSNull class]]) {
                campaign.savePriceEuroConverted = [campaignJSON objectForKey:@"save_price_euroConverted"];
            }
        }
        if ([campaignJSON objectForKey:@"special_price"]) {
            if (![[campaignJSON objectForKey:@"special_price"] isKindOfClass:[NSNull class]]) {
                campaign.specialPrice = [campaignJSON objectForKey:@"special_price"];
                campaign.specialPriceFormatted = [RICountryConfiguration formatPrice:campaign.specialPrice country:country];
            }
        }
        if ([campaignJSON objectForKey:@"special_price_euroConverted"]) {
            if (![[campaignJSON objectForKey:@"special_price_euroConverted"] isKindOfClass:[NSNull class]]) {
                campaign.specialPriceEuroConverted = [campaignJSON objectForKey:@"special_price_euroConverted"];
            }
        }
        if ([campaignJSON objectForKey:@"max_special_price"]) {
            if (![[campaignJSON objectForKey:@"max_special_price"] isKindOfClass:[NSNull class]]) {
                campaign.maxSpecialPrice = [campaignJSON objectForKey:@"max_special_price"];
                campaign.maxSpecialPriceFormatted = [RICountryConfiguration formatPrice:campaign.maxSpecialPrice country:country];
            }
        }
        if ([campaignJSON objectForKey:@"max_special_price_euroConverted"]) {
            if (![[campaignJSON objectForKey:@"max_special_price_euroConverted"] isKindOfClass:[NSNull class]]) {
                campaign.maxSpecialPriceEuroConverted = [campaignJSON objectForKey:@"max_special_price_euroConverted"];
            }
        }
        if ([campaignJSON objectForKey:@"price"]) {
            if (![[campaignJSON objectForKey:@"price"] isKindOfClass:[NSNull class]]) {
                campaign.price = [campaignJSON objectForKey:@"price"];
                campaign.priceFormatted = [RICountryConfiguration formatPrice:campaign.price country:country];
            }
        }
        if ([campaignJSON objectForKey:@"price_euroConverted"]) {
            if (![[campaignJSON objectForKey:@"price_euroConverted"] isKindOfClass:[NSNull class]]) {
                campaign.priceEuroConverted = [campaignJSON objectForKey:@"price_euroConverted"];
            }
        }
        if ([campaignJSON objectForKey:@"max_price"]) {
            if (![[campaignJSON objectForKey:@"max_price"] isKindOfClass:[NSNull class]]) {
                campaign.maxPrice = [campaignJSON objectForKey:@"max_price"];
                campaign.maxPriceFormatted = [RICountryConfiguration formatPrice:campaign.maxPrice country:country];
            }
        }
        if ([campaignJSON objectForKey:@"max_price_euroConverted"]) {
            if (![[campaignJSON objectForKey:@"max_price_euroConverted"] isKindOfClass:[NSNull class]]) {
                campaign.maxPriceEuroConverted = [campaignJSON objectForKey:@"max_price_euroConverted"];
            }
        }
        if ([campaignJSON objectForKey:@"sku"]) {
            if (![[campaignJSON objectForKey:@"sku"] isKindOfClass:[NSNull class]]) {
                campaign.sku = [campaignJSON objectForKey:@"sku"];
            }
        }
        if ([campaignJSON objectForKey:@"brand"]) {
            if (![[campaignJSON objectForKey:@"brand"] isKindOfClass:[NSNull class]]) {
                campaign.brand = [campaignJSON objectForKey:@"brand"];
            }
        }
        if ([campaignJSON objectForKey:@"name"]) {
            if (![[campaignJSON objectForKey:@"name"] isKindOfClass:[NSNull class]]) {
                campaign.name = [campaignJSON objectForKey:@"name"];
            }
        }
        if ([campaignJSON objectForKey:@"stock_percentage"]) {
            if (![[campaignJSON objectForKey:@"stock_percentage"] isKindOfClass:[NSNull class]]) {
                campaign.stockPercentage = [campaignJSON objectForKey:@"stock_percentage"];
            }
        }
        if ([campaignJSON objectForKey:@"max_saving_percentage"]) {
            if (![[campaignJSON objectForKey:@"max_saving_percentage"] isKindOfClass:[NSNull class]]) {
                campaign.maxSavingPercentage = [campaignJSON objectForKey:@"max_saving_percentage"];
            }
        }
        
        if ([campaignJSON objectForKey:@"remaining_time"]) {
            if (![[campaignJSON objectForKey:@"remaining_time"] isKindOfClass:[NSNull class]]) {
                campaign.remainingTime = [campaignJSON objectForKey:@"remaining_time"];
            }
        }
        
        if ([campaignJSON objectForKey:@"images"]) {
            
            NSMutableArray* imagesArray = [NSMutableArray new];
            
            NSArray* imagesJSON = [campaignJSON objectForKey:@"images"];
            if (VALID_NOTEMPTY(imagesJSON, NSArray)) {
                for (NSString* imageUrl in imagesJSON) {
                    if (VALID_NOTEMPTY(imageUrl, NSString)) {
                        [imagesArray addObject:imageUrl];
                    }
                }
            }
            
            campaign.imagesUrls = [imagesArray copy];
        }
        
        NSArray* sizesArray = [campaignJSON objectForKey:@"sizes"];
        if (VALID_NOTEMPTY(sizesArray, NSArray)) {
            
            NSMutableArray* productSimples = [NSMutableArray new];
            
            for (NSDictionary* sizeJSON in sizesArray) {
                
                if (VALID_NOTEMPTY(sizeJSON, NSDictionary)) {
                    
                    RICampaignProductSimple* campaignProductSimple = [RICampaignProductSimple parseCampaignProductSimple:sizeJSON
                                                                                                                 country:country];
                    [productSimples addObject:campaignProductSimple];
                }
            }
            
            campaign.productSimples = [productSimples copy];
        }
    }
    
    return campaign;
}

@end