//
//  JAShopWebViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 06/02/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAShopWebViewController.h"
#import "RIHtmlShop.h"
#import "RIFeaturedBoxTeaserGrouping.h"
#import "JATopSellersTeaserView.h"

@interface JAShopWebViewController ()

@property (nonatomic, strong)RIHtmlShop* htmlShop;

@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIWebView* webView;
@property (nonatomic, strong)NSMutableArray* topSellerTeaserViewsArray;
@property (nonatomic, assign)BOOL isLoaded;

@end

@implementation JAShopWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchBarIsVisible = YES;
    
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
    
    self.webView = [UIWebView new];
    self.webView.delegate = self;
    self.webView.scrollView.scrollEnabled = NO;
    [self.scrollView addSubview:self.webView];
    
    self.isLoaded = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.scrollView setFrame:[self viewBounds]];
    [self.webView setFrame:self.scrollView.bounds];
    
    if (NO == self.isLoaded) {
        
        [RIHtmlShop getHtmlShopForUrlString:self.url successBlock:^(RIHtmlShop *htmlShop) {
            self.htmlShop = htmlShop;
            self.isLoaded = YES;
            
            [self removeErrorView];
            [self.webView loadHTMLString:self.htmlShop.html baseURL:[NSURL URLWithString:self.url]];
            
        } failureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            if (RIApiResponseNoInternetConnection == apiResponse) {
                [self showErrorView:YES startingY:0.0f selector:@selector(viewWillAppear:) objects:nil];
            } else {
                [self showErrorView:NO startingY:0.0f selector:@selector(viewWillAppear:) objects:nil];
            }
        }];
    } else {
        [self loadViews];
    }
}

- (void)loadViews
{
    self.webView.frame = CGRectMake(0.0f,
                                    0.0f,
                                    self.scrollView.frame.size.width,
                                    self.webView.scrollView.contentSize.height);
    
    for (JATopSellersTeaserView* topSellersTeaserView in self.topSellerTeaserViewsArray) {
        [topSellersTeaserView removeFromSuperview];
    }
    
    CGFloat yPosition = CGRectGetMaxY(self.webView.frame);
    self.topSellerTeaserViewsArray = [NSMutableArray new];
    for (RIFeaturedBoxTeaserGrouping* featuredBox in self.htmlShop.featuredBoxesArray) {
        
        JATopSellersTeaserView* topSellersTeaserView = [[JATopSellersTeaserView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                                                yPosition,
                                                                                                                self.scrollView.frame.size.width,
                                                                                                                1)]; //height is set by the view itself
        [self.scrollView addSubview:topSellersTeaserView];
        topSellersTeaserView.featuredBoxTeaserGrouping = featuredBox;
        [topSellersTeaserView load];
        
        [self.topSellerTeaserViewsArray addObject:topSellersTeaserView];
        yPosition += topSellersTeaserView.frame.size.height;
    }
    
    if (self.htmlShop.featuredBoxesArray.count > 0) {
        yPosition += 6.0f;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.webView.scrollView.contentSize.width,
                                             yPosition);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.webView loadHTMLString:self.htmlShop.html baseURL:[NSURL URLWithString:self.url]];
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{    
    NSString* url = [request.URL absoluteString];
    NSArray *parts = [url componentsSeparatedByString: @"::"];
    
    if (VALID_NOTEMPTY(parts, NSArray) && 2 == parts.count) {
        NSString* identifier = [parts objectAtIndex:0];
        NSString* url = [parts objectAtIndex:1];
        
        if (VALID_NOTEMPTY(identifier, NSString) && VALID_NOTEMPTY(url, NSString)) {

            NSMutableDictionary* userInfo = [NSMutableDictionary new];
            [userInfo setObject:url forKey:@"url"];
            [userInfo setObject:STRING_BACK forKey:@"show_back_button_title"];
            
            if (self.teaserTrackingInfo) {
                [userInfo setObject:self.teaserTrackingInfo forKey:@"teaserTrackingInfo"];
            }
            
            if ([identifier isEqualToString:@"pdv"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                                    object:nil
                                                                  userInfo:userInfo];
                
            } else if ([identifier isEqualToString:@"catalog"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithCatalogUrlNofication
                                                                    object:nil
                                                                  userInfo:userInfo];
                
            } else if ([identifier isEqualToString:@"campaign"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectCampaignNofication
                                                                    object:nil
                                                                  userInfo:userInfo];
                
            }
            
        }
    }
    
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.scrollView setFrame:[self viewBounds]];
    [self.webView setFrame:self.scrollView.bounds];
    [self loadViews];
}

@end
