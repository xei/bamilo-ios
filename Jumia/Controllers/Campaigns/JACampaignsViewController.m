//
//  JACampaignsViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 25/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignsViewController.h"
#import "RITeaser.h"
#import "RITeaserText.h"
#import "JACampaignPageView.h"

@interface JACampaignsViewController ()

@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JACampaignsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                     self.view.bounds.origin.y,
                                                                     self.view.bounds.size.width,
                                                                     self.view.bounds.size.height)];
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    CGFloat currentX = 0.0f;
    
    if (VALID_NOTEMPTY(self.campaignTeasers, NSArray)) {
        for (RITeaser* teaser in self.campaignTeasers) {
            if (VALID_NOTEMPTY(teaser.teaserTexts, NSOrderedSet)) {
                RITeaserText* teaserText = [teaser.teaserTexts firstObject];
                if (VALID_NOTEMPTY(teaserText, RITeaserText)) {
                    
                    JACampaignPageView* campaignPage = [[JACampaignPageView alloc] initWithFrame:CGRectMake(currentX,
                                                                                                            self.scrollView.bounds.origin.y,
                                                                                                            self.scrollView.bounds.size.width,
                                                                                                            self.scrollView.bounds.size.height)];
                    [self.scrollView addSubview:campaignPage];
                    [campaignPage loadWithCampaignUrl:teaserText.url];
                    currentX += campaignPage.frame.size.width;
                }
            }
        }
    }
    
    [self.scrollView setContentSize:CGSizeMake(currentX, self.scrollView.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
