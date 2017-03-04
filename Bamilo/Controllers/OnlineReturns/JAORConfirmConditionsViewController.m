//
//  JAORConfirmConditionsViewController.m
//  Jumia
//
//  Created by Jose Mota on 03/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORConfirmConditionsViewController.h"
#import "JAProductInfoHeaderLine.h"
#import "JACenterNavigationController.h"
#import "JABottomSubmitView.h"
#import "ViewControllerManager.h"

#define kLateralMargin 8.f
#define kSpaceBetweenTitleAndBody 2.f

@interface JAORConfirmConditionsViewController () <UIWebViewDelegate>

@property (nonatomic, strong) JAProductInfoHeaderLine *titleHeaderView;
@property (nonatomic, strong) JABottomSubmitView *submitView;
@property (nonatomic, strong) UIWebView* webView;

@end

@implementation JAORConfirmConditionsViewController

- (JAProductInfoHeaderLine *)titleHeaderView
{
    if (!VALID(_titleHeaderView, JAProductInfoHeaderLine)) {
        _titleHeaderView = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kProductInfoHeaderLineHeight)];
        [_titleHeaderView.label setNumberOfLines:2];
        [_titleHeaderView setTitle:[STRING_ORDER_RETURN_CONDITIONS_TITLE uppercaseString]];
    }
    return _titleHeaderView;
}

- (UIWebView *)webView
{
    if (!VALID_NOTEMPTY(_webView, UIWebView)) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.titleHeaderView.frame) + kSpaceBetweenTitleAndBody, self.view.width - kLateralMargin*2, 0)];
        _webView.delegate = self;
        _webView.scrollView.scrollEnabled = NO;
        [_webView setBackgroundColor:JAWhiteColor];
    }
    return _webView;
}

- (JABottomSubmitView *)submitView
{
    if (!VALID(_submitView, JABottomSubmitView)) {
        _submitView = [[JABottomSubmitView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [JABottomSubmitView defaultHeight])];
        
        _submitView.button = [[JAButton alloc] initButtonWithTitle:[STRING_OK_GOT_IT uppercaseString]];
        [_submitView.button addTarget:self action:@selector(goToNext) forControlEvents:UIControlEventTouchUpInside];
        [_submitView setYBottomAligned:0.f];
    }
    return _submitView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = NO;
    [self.navBarLayout setTitle:STRING_MY_ORDERS];
    
    [self.view setBackgroundColor:JAWhiteColor];
    
    [self.view addSubview:self.titleHeaderView];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.submitView];
    
    [self showLoading];
    [self.webView loadHTMLString:self.html baseURL:[NSURL URLWithString:[RITarget getURLStringforTargetString:self.targetString]]];
}

- (void)goToNext
{
    [[ViewControllerManager centerViewController] goToOnlineReturnsReasonsScreenForItems:self.items order:self.order];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.titleHeaderView setWidth:self.view.width];
    [self.webView setWidth:self.view.width - 2*kLateralMargin];
    [self.webView setHeight:self.viewBounds.size.height - self.titleHeaderView.height - kSpaceBetweenTitleAndBody - self.submitView.height - kLateralMargin];
    [self.submitView setX:0];
    [self.submitView setWidth:self.view.width];
    [self.submitView setYBottomAligned:0.f];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.submitView setWidth:self.view.width];
    [self.submitView setYBottomAligned:0.f];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webView.scrollView.scrollEnabled = TRUE;
    [self.webView setWidth:self.view.width - 2*kLateralMargin];
    [self.webView setHeight:self.viewBounds.size.height - self.titleHeaderView.height - kSpaceBetweenTitleAndBody - self.submitView.height - kLateralMargin];
    [self hideLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoading];
    [self onErrorResponse:RIApiResponseUnknownError messages:nil showAsMessage:NO selector:@selector(viewWillAppear:) objects:nil];
}

@end
