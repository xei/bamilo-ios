//
//  JATeaserView.h
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RITeaser.h"
#import "RITeaserProduct.h"
#import "RITeaserImage.h"
#import "RITeaserText.h"

#define kTeaserNotificationPushCatalogWithUrl @"TEASER_NOTIFICATION_PUSH_CATALOG_WITH_URL"
#define kTeaserNotificationPushPDVWithUrl @"TEASER_NOTIFICATION_PUSH_PDV_WITH_URL"
#define kTeaserNotificationPushAllCategories @"TEASER_NOTIFICATION_PUSH_ALL_CATEGORIES"
#define kTeaserNotificationPushCatalogWithUrlForCampaigns @"TEASER_NOTIFICATION_PUSH_PDV_WITH_URL_FOR_CAMPAIGNS"

@interface JATeaserView : UIView

@property (nonatomic, strong)NSOrderedSet* teasers;
@property (strong, nonatomic) NSString *groupTitle;

- (void)load;

- (void)teaserPressedWithTeaserImage:(RITeaserImage*)teaserImage
                          targetType:(NSInteger)targetType;
- (void)teaserPressedWithTeaserText:(RITeaserText*)teaserText;
- (void)teaserPressedWithTeaserProduct:(RITeaserProduct*)teaserProduct;
- (void)teaserPressedWithTitle:(NSString*)title
             inCampaignTeasers:(NSArray*)campaignTeasers;
- (void)teaserAllCategoriesPressed;

@end
