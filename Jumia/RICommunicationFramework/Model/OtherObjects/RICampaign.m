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
                     successBlock:(void (^)(NSArray* campaigns, NSString* bannerImageUrl))successBlock
                  andFailureBlock:(void (^)(NSArray *error))failureBlock;
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
                                                                  if (VALID_NOTEMPTY(cms, NSDictionary)) {
                                                                      NSArray* bannerArray = [cms objectForKey:@"mobile_banner"];
                                                                      if (VALID_NOTEMPTY(bannerArray, NSArray)) {
                                                                          bannerImageUrl = [bannerArray firstObject];
                                                                      }
                                                                  }
                                                                  
                                                                  NSDictionary* campaign = [data objectForKey:@"campaign"];
                                                                  NSArray* campaignData = [campaign objectForKey:@"data"];
                                                                  
                                                                  if (VALID_NOTEMPTY(campaignData, NSArray)) {
                                                                      NSArray* campaignsArray = [RICampaign parseCampaigns:campaignData country:configuration];
                                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                                          successBlock(campaignsArray, bannerImageUrl);
                                                                      });
                                                                  }
                                                                  
                                                              } andFailureBlock:^(NSArray *errorMessages) {
                                                                  failureBlock(nil);
                                                              }];
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
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
        if ([campaignJSON objectForKey:@"special_price"]) {
            if (![[campaignJSON objectForKey:@"special_price"] isKindOfClass:[NSNull class]]) {
                campaign.specialPrice = [campaignJSON objectForKey:@"special_price"];
                campaign.specialPriceFormatted = [RICountryConfiguration formatPrice:campaign.specialPrice country:country];
            }
        }
        if ([campaignJSON objectForKey:@"max_special_price"]) {
            if (![[campaignJSON objectForKey:@"max_special_price"] isKindOfClass:[NSNull class]]) {
                campaign.maxSpecialPrice = [campaignJSON objectForKey:@"max_special_price"];
                campaign.maxSpecialPriceFormatted = [RICountryConfiguration formatPrice:campaign.maxSpecialPrice country:country];
            }
        }
        if ([campaignJSON objectForKey:@"price"]) {
            if (![[campaignJSON objectForKey:@"price"] isKindOfClass:[NSNull class]]) {
                campaign.price = [campaignJSON objectForKey:@"price"];
                campaign.priceFormatted = [RICountryConfiguration formatPrice:campaign.price country:country];
            }
        }
        if ([campaignJSON objectForKey:@"max_price"]) {
            if (![[campaignJSON objectForKey:@"max_price"] isKindOfClass:[NSNull class]]) {
                campaign.maxPrice = [campaignJSON objectForKey:@"max_price"];
                campaign.maxPriceFormatted = [RICountryConfiguration formatPrice:campaign.maxPrice country:country];
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
