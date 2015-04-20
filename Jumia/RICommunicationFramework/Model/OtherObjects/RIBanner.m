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
        
    
                if([bannerJSON objectForKey:@"phone_image"])
                {
                    newBanner.iPhoneImageUrl = [bannerJSON objectForKey:@"phone_image"];
                }
                
                if([bannerJSON objectForKey:@"tablet_image"])
                {
                    newBanner.iPadImageUrl = [bannerJSON objectForKey:@"tablet_image"];
                }
                
                if([bannerJSON objectForKey:@"target_type"])
                {
                    newBanner.targetType = [bannerJSON objectForKey:@"target_type"];
                }
                
                if([bannerJSON objectForKey:@"title"])
                {
                    newBanner.title = [bannerJSON objectForKey:@"title"];
                }
                
                if([bannerJSON objectForKey:@"url"])
                {
                    newBanner.url = [bannerJSON objectForKey:@"url"];
                }
            }
    
    
    return newBanner;
    
}

@end
