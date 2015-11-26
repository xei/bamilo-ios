//
//  RIHtmlShop.m
//  Jumia
//
//  Created by Telmo Pinto on 16/07/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RIHtmlShop.h"
#import "RIFeaturedBoxTeaserGrouping.h"
#import "RICountry.h"
#import "GTMNSString+HTML.h"
#import "RITarget.h"

@implementation RIHtmlShop

+ (NSString*)getHtmlShopForTargetString:(NSString*)targetString
                           successBlock:(void (^)(RIHtmlShop *htmlShop))sucessBlock
                           failureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    NSString* urlString = [RITarget getURLStringforTargetString:targetString];
    NSURL* url = [NSURL URLWithString:urlString];
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url parameters:nil httpMethodPost:YES cacheType:RIURLCacheNoCache cacheTime:RIURLCacheDefaultTime userAgentInjection:[RIApi getCountryUserAgentInjection] successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
        
        [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
            NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
            if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                NSDictionary *data = [metadata objectForKey:@"data"];
                if (VALID_NOTEMPTY(data, NSDictionary)) {
                    RIHtmlShop* htmlShop = [RIHtmlShop parseHtmlShop:data country:configuration];
                    sucessBlock(htmlShop);
                }
            }
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            failureBlock(apiResponse, nil);
        }];
    } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
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

+ (RIHtmlShop*)parseHtmlShop:(NSDictionary*)json
                     country:(RICountryConfiguration*)country;
{
    RIHtmlShop* newHtmlStore = [[RIHtmlShop alloc] init];
    
    if (VALID_NOTEMPTY(json, NSDictionary)) {
        NSString* htmlRaw = [json objectForKey:@"html"];
        if (VALID_NOTEMPTY(htmlRaw, NSString)) {
            NSString *htmlStep = [htmlRaw gtm_stringByUnescapingFromHTML];
            NSString *htmlFinal = [htmlStep gtm_stringByUnescapingFromHTML];
            
            newHtmlStore.html = htmlFinal;
        }
        
        NSArray* featuredBoxesJson = [json objectForKey:@"featured_box"];
        if (VALID_NOTEMPTY(featuredBoxesJson, NSArray)) {
            
            NSMutableArray* featuredBoxesArray = [NSMutableArray new];
            for (NSDictionary* featuredBoxJson in featuredBoxesJson) {
                if (VALID_NOTEMPTY(featuredBoxJson, NSDictionary)) {
                    RIFeaturedBoxTeaserGrouping* featuredBox = [RIFeaturedBoxTeaserGrouping parseFeaturedBox:featuredBoxJson country:country];
                    [featuredBoxesArray addObject:featuredBox];
                }
            }
            newHtmlStore.featuredBoxesArray = [featuredBoxesArray copy];
        }
    }
    return newHtmlStore;
}

@end
