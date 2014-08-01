//
//  JATeaserPageView.m
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATeaserPageView.h"
#import "RITeaserGroup.h"
#import "JAMainTeaserView.h"
#import "JATopSellersTeaserView.h"

@interface JATeaserPageView()

@property (nonatomic, assign)CGFloat currentY;

@end

@implementation JATeaserPageView

- (void)loadTeasers;
{
    if (NOTEMPTY(self.teaserCategory)) {
        
        self.currentY = self.bounds.origin.y; //shared between methods
        
        [self loadMainTeasers];
        [self loadBrandTeasersOrTopSellers];
        [self loadSmallTeasers];
        [self loadCampaigns];
        [self loadPopularCategories];
        [self loadTopBrands];
        
        self.isLoaded = YES;
    }
}

- (void)loadMainTeasers
{    
    for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {

        if (0 == [teaserGroup.type integerValue]) {
            
            //found it
            
            JAMainTeaserView* mainTeaserView = [[JAMainTeaserView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                                                  self.currentY,
                                                                                                  self.bounds.size.width,
                                                                                                  1)]; //height is set by the view itself
            [self addSubview:mainTeaserView];
            [mainTeaserView setTeasers:teaserGroup.teasers];
            [mainTeaserView load];
            
            self.currentY += mainTeaserView.frame.size.height;
            
            break;
        }
    }
}

- (void)loadBrandTeasersOrTopSellers
{
    if ([[self.teaserCategory.homePageLayout lowercaseString] isEqualToString:@"fashion"]) {

        //brand teasers
        
    } else if ([[self.teaserCategory.homePageLayout lowercaseString] isEqualToString:@"gm"]) {
        
        //top sellers
        for (RITeaserGroup* teaserGroup in self.teaserCategory.teaserGroups) {
            
            if (2 == [teaserGroup.type integerValue]) {
                
                //found it
                
                JATopSellersTeaserView* topSellersTeaserView = [[JATopSellersTeaserView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                                                                        self.currentY,
                                                                                                                        self.bounds.size.width,
                                                                                                                        1)]; //height is set by the view itself
                [self addSubview:topSellersTeaserView];
                [topSellersTeaserView setTeasers:teaserGroup.teasers];
                [topSellersTeaserView load];
                
                self.currentY += topSellersTeaserView.frame.size.height;
                
                break;
            }
        }
        
    }

}

- (void)loadSmallTeasers
{}

- (void)loadCampaigns
{}

- (void)loadPopularCategories
{}

- (void)loadTopBrands
{}

@end
