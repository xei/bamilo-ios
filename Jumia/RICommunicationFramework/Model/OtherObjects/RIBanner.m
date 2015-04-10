//
//  RIBanner.m
//  Jumia
//
//  Created by epacheco on 10/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RIBanner.h"

@implementation RIBanner

+(RIBanner *)parseBanner:(NSDictionary *)bannerJSON
{
    RIBanner *newBanner = [[RIBanner alloc] init];
    
    if(VALID_NOTEMPTY(bannerJSON, NSDictionary)){
        
        NSDictionary *metadataBanner = [bannerJSON objectForKey:@"metadata"];
        
        if(VALID_NOTEMPTY(metadataBanner, NSDictionary))
        {
            NSDictionary *banner = [metadataBanner objectForKey:@"banner"];
            if(VALID_NOTEMPTY(banner, NSDictionary)){
                if([banner objectForKey:@"phone_image"])
                {
                    newBanner.iPhoneImageUrl = [banner objectForKey:@"phone_image"];
                }
                
                if([banner objectForKey:@"tablet_image"])
                {
                    newBanner.iPadImageUrl = [banner objectForKey:@"tablet_image"];
                }
                
                if([banner objectForKey:@"target_type"])
                {
                    newBanner.targetType = [banner objectForKey:@"target_type"];
                }
                
                if([banner objectForKey:@"title"])
                {
                    newBanner.title = [banner objectForKey:@"title"];
                }
                
                if([banner objectForKey:@"url"])
                {
                    newBanner.url = [banner objectForKey:@"url"];
                }
            }
        }
    }
    
    return newBanner;
    
}

@end
