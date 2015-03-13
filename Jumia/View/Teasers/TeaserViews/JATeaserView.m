//
//  JATeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATeaserView.h"

@implementation JATeaserView

-(void)load;
{
    self.backgroundColor = [UIColor clearColor];
    
    if (ISEMPTY(self.teasers)) {
        return;
    }
}

- (void)teaserPressedWithTeaserImage:(RITeaserImage*)teaserImage
                          targetType:(NSInteger)targetType;
{
    NSString* notificationName = kTeaserNotificationPushCatalogWithUrl;
    if (1 == targetType) {
        notificationName = kTeaserNotificationPushPDVWithUrl;
    } else if (4 == targetType) {
        notificationName = kTeaserNotificationPushShopWithUrl;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjects:@[teaserImage.url,teaserImage.teaserDescription,STRING_HOME] forKeys:@[@"url",@"title",@"show_back_button_title"]]];
}

- (void)teaserPressedWithTeaserText:(RITeaserText*)teaserText
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTeaserNotificationPushCatalogWithUrl
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjects:@[teaserText.url,teaserText.name] forKeys:@[@"url",@"title"]]];
}

- (void)teaserPressedWithTeaserProduct:(RITeaserProduct*)teaserProduct
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTeaserNotificationPushPDVWithUrl
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjects:@[teaserProduct.url, STRING_HOME] forKeys:@[@"url", @"show_back_button_title"]]];
}

- (void)teaserPressedWithTitle:(NSString*)title
             inCampaignTeasers:(NSArray*)campaignTeasers;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTeaserNotificationPushCatalogWithUrlForCampaigns
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjects:@[title,campaignTeasers] forKeys:@[@"title",@"campaignTeasers"]]];
}

- (void)teaserAllCategoriesPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTeaserNotificationPushAllCategories
                                                        object:nil
                                                      userInfo:nil];
}

@end
