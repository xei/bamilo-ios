//
//  JAORPickupStationWebViewController.m
//  Jumia
//
//  Created by telmopinto on 20/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORPickupStationWebViewController.h"

@interface JAORPickupStationWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView* webView;

@end

@implementation JAORPickupStationWebViewController

- (UIWebView *)webView
{
    if (!VALID_NOTEMPTY(_webView, UIWebView)) {
        _webView = [UIWebView new];
        _webView.delegate = self;
        _webView.scrollView.scrollEnabled = NO;
    }
    return _webView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:JAWhiteColor];
    [self.view addSubview:self.webView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.webView.frame = self.view.bounds;
    if (VALID_NOTEMPTY(self.cmsBlock, NSString)) {
        [self.webView loadHTMLString:self.cmsBlock baseURL:nil];
    }
}


#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_MY_ORDERS;
}
@end
