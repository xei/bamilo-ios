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
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjects:@[teaserImage.url,teaserImage.teaserDescription] forKeys:@[@"url",@"title"]]];
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
                                                      userInfo:[NSDictionary dictionaryWithObjects:@[teaserProduct.url] forKeys:@[@"url"]]];
}

- (void)teaserPressedWithTeaserTextForCampaigns:(RITeaserText *)teaserText
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTeaserNotificationPushCatalogWithUrlForCampaigns
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjects:@[teaserText.url,teaserText.name] forKeys:@[@"url",@"title"]]];
}

- (void)teaserAllCategoriesPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTeaserNotificationPushAllCategories
                                                        object:nil
                                                      userInfo:nil];
}

@end