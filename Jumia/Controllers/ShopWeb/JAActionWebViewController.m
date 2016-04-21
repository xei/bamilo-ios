//
//  JAActionWebViewController.m
//  Jumia
//
//  Created by Jose Mota on 20/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAActionWebViewController.h"
#import "JAButton.h"

@interface JAActionWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView* webView;
@property (nonatomic, assign) BOOL isLoaded;
@property (nonatomic, strong) JAButton *button;

@end

@implementation JAActionWebViewController

- (UIWebView *)webView
{
    if (!VALID_NOTEMPTY(_webView, UIWebView)) {
        _webView = [UIWebView new];
        _webView.delegate = self;
        _webView.scrollView.scrollEnabled = NO;
    }
    return _webView;
}

- (JAButton *)button
{
    if (!VALID_NOTEMPTY(_button, JAButton)) {
        _button = [[JAButton alloc] initButtonWithTitle:STRING_GO target:self action:@selector(go)];
        [_button setFrame:CGRectMake(0, 0, self.view.width, kBottomDefaultHeight)];
        [_button setYBottomAligned:0.f];
    }
    return _button;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.button];
    
    self.isLoaded = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (NO == self.isLoaded) {
        [self showLoading];
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [self.webView loadHTMLString:self.htmlString baseURL:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification
                                                         object:nil];
}

- (void)viewWillLayoutSubviews
{
    [self.webView setFrame:CGRectMake(0, 0, self.view.width, self.view.height-self.button.height)];
    [self.button setWidth:self.view.width];
    [self.button setYBottomAligned:0.f];
    [super viewWillLayoutSubviews];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.isLoaded = YES;
    [self hideLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoading];
    [self onErrorResponse:RIApiResponseUnknownError messages:nil showAsMessage:NO selector:@selector(viewWillAppear:) objects:nil];
}

- (void)go
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[RITarget getURLStringforTargetString:self.targetString]]];
}

@end
