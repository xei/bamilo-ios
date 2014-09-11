//
//  JAHomeViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAHomeViewController.h"
#import "RITeaserCategory.h"
#import "JATeaserPageView.h"
#import "JATeaserView.h"

@interface JAHomeViewController ()

@property (nonatomic, strong) NSArray* teaserCategories;
@property (weak, nonatomic) IBOutlet JAPickerScrollView *teaserCategoryScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *teaserPagesScrollView;
@property (nonatomic, strong) NSMutableArray* teaserPageViews;

@end

@implementation JAHomeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.teaserCategoryScrollView.delegate = self;
    self.teaserPagesScrollView.pagingEnabled = YES;
    self.teaserPagesScrollView.scrollEnabled = NO;
    self.teaserPagesScrollView.delegate = self;
    
    self.teaserPagesScrollView.frame = CGRectMake(self.teaserPagesScrollView.frame.origin.x,
                                                  CGRectGetMaxY(self.teaserCategoryScrollView.frame),
                                                  self.teaserPagesScrollView.frame.size.width,
                                                  self.view.frame.size.height - self.teaserCategoryScrollView.frame.size.height - 64.0f);
    
    [RITeaserCategory getTeaserCategoriesWithSuccessBlock:^(id teaserCategories) {
        
        self.teaserCategories = teaserCategories;
        
        NSMutableArray* titles = [NSMutableArray new];
        self.teaserPageViews = [NSMutableArray new];
        
        CGFloat currentPageX = self.teaserPagesScrollView.bounds.origin.x;
        
        for (RITeaserCategory* teaserCategory in teaserCategories) {
            [titles addObject:teaserCategory.homePageTitle];
            
            JATeaserPageView* teaserPageView = [[JATeaserPageView alloc] initWithFrame:CGRectMake(currentPageX,
                                                                                                  self.teaserPagesScrollView.bounds.origin.y,
                                                                                                  self.teaserPagesScrollView.bounds.size.width,
                                                                                                  self.teaserPagesScrollView.bounds.size.height)];
            teaserPageView.teaserCategory = teaserCategory;
            [self.teaserPagesScrollView addSubview:teaserPageView];
            [self.teaserPageViews addObject:teaserPageView];
            
            currentPageX += teaserPageView.frame.size.width;
        }
        
        [self.teaserCategoryScrollView setOptions:titles];
        
        [self.teaserPagesScrollView setContentSize:CGSizeMake(currentPageX,
                                                              self.teaserPagesScrollView.frame.size.height)];
        
    } andFailureBlock:^(NSArray *errorMessage) {
        
    }];
}

- (void)stopLoading
{
    [self hideLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addNotifications];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeNotifications];
}

- (void)addNotifications
{
    //we do this to make sure no notification is added more than once
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushCatalogWithUrl:)
                                                 name:kTeaserNotificationPushCatalogWithUrl
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushPDVWithUrl:)
                                                 name:kTeaserNotificationPushPDVWithUrl
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushAllCategories)
                                                 name:kTeaserNotificationPushAllCategories
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushCampaigns:)
                                                 name:kTeaserNotificationPushCatalogWithUrlForCampaigns
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - JATeaserCategoryScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{
    //check if teaser page at said index is loaded
    
    JATeaserPageView* teaserPageView = [self.teaserPageViews objectAtIndex:index];
    
    if (NO ==  teaserPageView.isLoaded) {
        [teaserPageView loadTeasers];
    }
    
    if (index + 1 < self.teaserPageViews.count) {
        
        JATeaserPageView* nextTeaserPageView = [self.teaserPageViews objectAtIndex:index + 1];
        
        if (NO ==  nextTeaserPageView.isLoaded) {
            [nextTeaserPageView loadTeasers];
        }
    }
    
    [self.teaserPagesScrollView scrollRectToVisible:teaserPageView.frame animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)swipeRight:(id)sender
{
    [self removeNotifications];
    [self.teaserCategoryScrollView scrollRight];
}

- (IBAction)swipeLeft:(id)sender
{
    [self removeNotifications];
    [self.teaserCategoryScrollView scrollLeft];
}

#pragma mark - UIScrollViewDelegate

//this depends on animation existing. if in the future there is a case where no animation
//happens on the scroll view, we have to move this to another scrollviewdelegate method
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self addNotifications];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}

#pragma mark - Teaser actions

- (void)pushCatalogWithUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithCatalogUrlNofication
                                                        object:notification.object
                                                      userInfo:notification.userInfo];
}

- (void)pushPDVWithUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:notification.object
                                                      userInfo:notification.userInfo];
}

- (void)pushCampaigns:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectCampaignNofication
                                                        object:notification.object
                                                      userInfo:notification.userInfo];
}

- (void)pushAllCategories
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithAllCategoriesNofication
                                                        object:nil
                                                      userInfo:nil];
}

@end
