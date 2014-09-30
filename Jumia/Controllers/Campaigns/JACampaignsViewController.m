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

@property (nonatomic, strong)NSMutableArray* campaignPages;
@property (nonatomic, strong)JAPickerScrollView* pickerScrollView;
@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JACampaignsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pickerScrollView = [[JAPickerScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                                 self.view.bounds.origin.y,
                                                                                 self.view.bounds.size.width,
                                                                                 44.0f)];
    self.pickerScrollView.delegate = self;
    [self.view addSubview:self.pickerScrollView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                     CGRectGetMaxY(self.pickerScrollView.frame),
                                                                     self.view.bounds.size.width,
                                                                     self.view.bounds.size.height - self.pickerScrollView.frame.size.height - 64.0f)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = NO;
    [self.view addSubview:self.scrollView];
    
    CGFloat currentX = 0.0f;
    
    NSInteger startingIndex = 0;
    self.campaignPages = [NSMutableArray new];
    NSMutableArray* optionList = [NSMutableArray new];
    if (VALID_NOTEMPTY(self.campaignTeasers, NSArray)) {
        for (int i = 0; i < self.campaignTeasers.count; i++) {
            RITeaser* teaser = [self.campaignTeasers objectAtIndex:i];
            if (VALID_NOTEMPTY(teaser.teaserTexts, NSOrderedSet)) {
                RITeaserText* teaserText = [teaser.teaserTexts firstObject];
                if (VALID_NOTEMPTY(teaserText, RITeaserText)) {

                    [optionList addObject:teaserText.name];
                    
                    if ([teaserText.name isEqualToString:self.startingTitle]) {
                        startingIndex = i;
                    }
                    
                    JACampaignPageView* campaignPage = [[JACampaignPageView alloc] initWithFrame:CGRectMake(currentX,
                                                                                                            self.scrollView.bounds.origin.y,
                                                                                                            self.scrollView.bounds.size.width,
                                                                                                            self.scrollView.bounds.size.height)];
                    [self.campaignPages addObject:campaignPage];
                    [self.scrollView addSubview:campaignPage];
                    [campaignPage loadWithCampaignUrl:teaserText.url];
                    currentX += campaignPage.frame.size.width;
                }
            }
        }
    }
    
    self.pickerScrollView.startingIndex = startingIndex;
    
    //this will trigger load methods
    [self.pickerScrollView setOptions:optionList];
    
    [self.scrollView setContentSize:CGSizeMake(currentX, self.scrollView.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
}

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{
    JACampaignPageView* campaignPageView = [self.campaignPages objectAtIndex:index];
    [self.scrollView scrollRectToVisible:campaignPageView.frame animated:YES];
}

- (IBAction)swipeLeft:(id)sender
{
    [self.pickerScrollView scrollLeft];
}

- (IBAction)swipeRight:(id)sender
{
    [self.pickerScrollView scrollRight];
}

@end
