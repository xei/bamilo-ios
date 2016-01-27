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
#import "RITarget.h"

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
    
    [[RITrackingWrapper sharedInstance] trackStaticPage:self.targetString];
    
    [self.scrollView setFrame:[self viewBounds]];
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.webView setFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                      self.scrollView.bounds.origin.y,
                                      self.scrollView.bounds.size.width,
                                      1.0f)];
    
    if (NO == self.isLoaded) {
        [self showLoading];
        [RIHtmlShop getHtmlShopForTargetString:self.targetString successBlock:^(RIHtmlShop *htmlShop) {
            self.htmlShop = htmlShop;
            self.isLoaded = YES;
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
            [self.webView loadHTMLString:self.htmlShop.html baseURL:[NSURL URLWithString:[RITarget getURLStringforTargetString:self.targetString]]];
            
        } failureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(viewWillAppear:) objects:nil];
            [self hideLoading];
        }];
    } else {
        [self loadViews];
    }
}

- (void)loadViews
{
    self.webView.frame = CGRectMake(0.0f,
                                    0.0f,
                                    self.webView.scrollView.contentSize.width,
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
    [self.webView loadHTMLString:self.htmlShop.html baseURL:[NSURL URLWithString:[RITarget getURLStringforTargetString:self.targetString]]];
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{    
    NSString* targetString = [request.URL absoluteString];

    RITarget* target = [RITarget parseTarget:targetString];
    if (VALID_NOTEMPTY(target.type, NSString)) {
        NSString* notificationName;
        
        if ([target.type isEqualToString:@"catalog"]) {
            
            notificationName = kDidSelectTeaserWithCatalogUrlNofication;
            
        } else if ([target.type isEqualToString:@"product_detail"]) {
            
            notificationName = kDidSelectTeaserWithPDVUrlNofication;
            
        } else if ([target.type isEqualToString:@"static_page"]) {
            
            notificationName = kDidSelectTeaserWithShopUrlNofication;
            
        } else if ([target.type isEqualToString:@"campaign"]) {
            
            notificationName = kDidSelectCampaignNofication;
            
        }
        
        NSMutableDictionary* userInfo = [NSMutableDictionary new];
        [userInfo setObject:STRING_BACK forKey:@"show_back_button_title"];
        
        if (self.teaserTrackingInfo) {
            [userInfo setObject:self.teaserTrackingInfo forKey:@"teaserTrackingInfo"];
        }
        [userInfo setObject:targetString forKey:@"targetString"];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:nil
                                                          userInfo:userInfo];
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoading];
    [self.scrollView setFrame:[self viewBounds]];
    [self.webView setFrame:CGRectMake(self.scrollView.bounds.origin.x,
                                      self.scrollView.bounds.origin.y,
                                      self.scrollView.bounds.size.width,
                                      1.0f)];
    [self loadViews];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoading];
    [self onErrorResponse:RIApiResponseUnknownError messages:nil showAsMessage:NO selector:@selector(viewWillAppear:) objects:nil];
}

@end
