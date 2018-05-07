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
#import "JAScreenTarget.h"
#import "JACenterNavigationController.h"
#import "Bamilo-Swift.h"

@interface JAShopWebViewController () <SearchViewControllerDelegate>

@property (nonatomic, strong)RIHtmlShop* htmlShop;
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, strong)UIWebView* webView;
@property (nonatomic, strong)NSMutableArray* topSellerTeaserViewsArray;
@property (nonatomic, assign)BOOL isLoaded;

@end

@implementation JAShopWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [UIWebView new];
    [self.webView setBackgroundColor:[UIColor whiteColor]];
    self.webView.delegate = self;
    self.isLoaded = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (NO == self.isLoaded) {
        [self showLoading];
        [RIHtmlShop getHtmlShopForTargetString:self.targetString successBlock:^(RIHtmlShop *htmlShop) {
            self.htmlShop = htmlShop;
            self.isLoaded = YES;
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
            [self.webView loadHTMLString:self.htmlShop.html baseURL:[NSURL URLWithString:@"http://"]];
            if (self.htmlShop.featuredBoxesArray.count == 0) {
                self.webView.scrollView.scrollEnabled = YES;
                [self.webView setFrame:[self viewBounds]];
                [self.view addSubview:self.webView];
            } else {
                self.scrollView = [UIScrollView new];
                [self.scrollView setBackgroundColor:[UIColor whiteColor]];
                [self.view addSubview:self.scrollView];
                [self.scrollView addSubview:self.webView];
                self.webView.scrollView.scrollEnabled = NO;
            }
        } failureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(viewWillAppear:) objects:nil];
            [self hideLoading];
        }];
    }
}

- (void)loadViews {
    CGRect frame = self.webView.frame;
    frame.size.height = 1;
    self.webView.frame = frame;
    CGSize fittingSize = [self.webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    self.webView.frame = frame;
    
    for (JATopSellersTeaserView* topSellersTeaserView in self.topSellerTeaserViewsArray) {
        [topSellersTeaserView removeFromSuperview];
    }
    
    CGFloat yPosition = CGRectGetMaxY(self.webView.frame);
    self.topSellerTeaserViewsArray = [NSMutableArray new];
    for (RIFeaturedBoxTeaserGrouping* featuredBox in self.htmlShop.featuredBoxesArray) {
        JATopSellersTeaserView* topSellersTeaserView = [[JATopSellersTeaserView alloc] initWithFrame:CGRectMake(0.0f, yPosition, self.scrollView.frame.size.width, 1)]; //height is set by the view itself
        [self.scrollView addSubview:topSellersTeaserView];
        topSellersTeaserView.featuredBoxTeaserGrouping = featuredBox;
        [topSellersTeaserView load];
        
        [self.topSellerTeaserViewsArray addObject:topSellersTeaserView];
        yPosition += topSellersTeaserView.frame.size.height;
    }
    if (self.htmlShop.featuredBoxesArray.count > 0) {
        yPosition += 6.0f;
    }
    self.scrollView.contentSize = CGSizeMake(self.webView.scrollView.contentSize.width, yPosition);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.webView loadHTMLString:self.htmlShop.html baseURL:[NSURL URLWithString:[RITarget getURLStringforTargetString:self.targetString]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType: (UIWebViewNavigationType)navigationType {
    RITarget *target = [RITarget parseTarget:[request.URL absoluteString]];
    return ![[MainTabBarViewController topNavigationController] openScreenTarget:target purchaseInfo:self.purchaseTrackingInfo];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideLoading];
    if (self.htmlShop.featuredBoxesArray.count) {
        [self publishScreenLoadTimeWithName:[self getScreenName] withLabel: self.title];
        [self.scrollView setFrame:[self viewBounds]];
        [self.webView setFrame:self.scrollView.bounds];
        [self loadViews];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideLoading];
    [self onErrorResponse:RIApiResponseUnknownError messages:nil showAsMessage:NO selector:@selector(viewWillAppear:) objects:nil];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"StaticPage";
}

- (NavBarButtonType)navBarleftButton {
    return NavBarButtonTypeSearch;
}

@end
