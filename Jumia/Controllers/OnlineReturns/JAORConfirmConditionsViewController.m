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
#import "JAButton.h"

#define kLateralMargin 8.f
#define kSpaceBetweenTitleAndBody 2.f

@interface JAORConfirmConditionsViewController () <UIWebViewDelegate>

@property (nonatomic, strong) JAProductInfoHeaderLine *titleHeaderView;
@property (nonatomic, strong) JAButton *submitButton;
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

- (JAButton *)submitButton
{
    if (!VALID(_submitButton, JAButton)) {
        _submitButton = [[JAButton alloc] initButtonWithTitle:[STRING_OK_GOT_IT uppercaseString]];
        [_submitButton addTarget:self action:@selector(goToNext) forControlEvents:UIControlEventTouchUpInside];
        [_submitButton setFrame:CGRectMake(kLateralMargin, 0, self.view.width-2*kLateralMargin, kBottomDefaultHeight)];
        [_submitButton setYBottomAligned:0.f];
    }
    return _submitButton;
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
    [self.view addSubview:self.submitButton];
    
    [self showLoading];
    [self.webView loadHTMLString:self.html baseURL:[NSURL URLWithString:[RITarget getURLStringforTargetString:self.targetString]]];
}

- (void)goToNext
{
    [[JACenterNavigationController sharedInstance] goToOnlineReturnsReasonsScreenForItems:self.items order:self.order];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.titleHeaderView setWidth:self.view.width];
    [self.webView setWidth:self.view.width - 2*kLateralMargin];
    [self.webView setHeight:self.viewBounds.size.height - self.titleHeaderView.height - kSpaceBetweenTitleAndBody - self.submitButton.height - 2*kLateralMargin];
    [self.submitButton setX:kLateralMargin];
    [self.submitButton setWidth:self.view.width-2*kLateralMargin];
    [self.submitButton setYBottomAligned:kLateralMargin];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.submitButton setWidth:self.view.width];
    [self.submitButton setYBottomAligned:0.f];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webView.scrollView.scrollEnabled = TRUE;
    [self.webView setWidth:self.view.width - 2*kLateralMargin];
    [self.webView setHeight:self.viewBounds.size.height - self.titleHeaderView.height - kSpaceBetweenTitleAndBody - self.submitButton.height - 2*kLateralMargin];
    [self hideLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoading];
    [self onErrorResponse:RIApiResponseUnknownError messages:nil showAsMessage:NO selector:@selector(viewWillAppear:) objects:nil];
}

@end
