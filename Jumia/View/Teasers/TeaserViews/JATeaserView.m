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
    
    if (ISEMPTY(self.teaserGrouping)) {
        return;
    }
}

- (void)teaserPressed:(UIControl*)control
{
    NSInteger index = control.tag;
    
    [self teaserPressedForIndex:index];
}

- (void)teaserPressedForIndex:(NSInteger)index
{
    RITeaserComponent* teaserComponent = [self.validTeaserComponents objectAtIndex:index];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setObject:STRING_HOME forKey:@"show_back_button_title"];
    if (VALID_NOTEMPTY(teaserComponent.name, NSString)) {
        [userInfo setObject:teaserComponent.name forKey:@"title"];
    } else if (VALID_NOTEMPTY(teaserComponent.title, NSString)) {
        [userInfo setObject:teaserComponent.title forKey:@"title"];
    }
    
    NSString* notificationName;
    
    if ([teaserComponent.targetType isEqualToString:@"catalog"]) {
        
        notificationName = kDidSelectTeaserWithCatalogUrlNofication;
        
    } else if ([teaserComponent.targetType isEqualToString:@"product_detail"]) {
        
        notificationName = kDidSelectTeaserWithPDVUrlNofication;
        
    } else if ([teaserComponent.targetType isEqualToString:@"static_page"]) {
        
        notificationName = kDidSelectTeaserWithShopUrlNofication;
        
    } else if ([teaserComponent.targetType isEqualToString:@"campaign"]) {
        
        notificationName = kDidSelectCampaignNofication;
        
        //for the campaigns teaserGrouping we need all the campaign components
        if ([self.teaserGrouping.type isEqualToString:@"campaigns"]) {
            [userInfo setObject:self.teaserGrouping forKey:@"teaserGrouping"];
        }
    }
    
    if (VALID_NOTEMPTY(teaserComponent.url, NSString)) {
        [userInfo setObject:teaserComponent.url forKey:@"url"];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:nil
                                                          userInfo:userInfo];
    }

}

@end
