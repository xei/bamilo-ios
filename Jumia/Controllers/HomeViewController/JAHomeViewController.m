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

@interface JAHomeViewController ()

@property (nonatomic, strong) NSArray* teaserCategories;
@property (weak, nonatomic) IBOutlet JATeaserCategoryScrollView *teaserCategoryScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *teaserPagesScrollView;
@property (nonatomic, strong) NSMutableArray* teaserPageViews;


@end

@implementation JAHomeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.teaserCategoryScrollView.delegate = self;
    self.teaserPagesScrollView.pagingEnabled = YES;
    self.teaserPagesScrollView.scrollEnabled = NO;
    
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
        
        [self.teaserCategoryScrollView setCategories:titles];
        
        [self.teaserPagesScrollView setContentSize:CGSizeMake(currentPageX,
                                                              self.teaserPagesScrollView.frame.size.height)];
        
    } andFailureBlock:^(NSArray *errorMessage) {
        
    }];
}

#pragma mark - JATeaserCategoryScrollViewDelegate

- (void)teaserCategorySelectedAtIndex:(NSInteger)index
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
    
    [self.teaserPagesScrollView scrollRectToVisible:teaserPageView.frame animated:NO];
}

@end
