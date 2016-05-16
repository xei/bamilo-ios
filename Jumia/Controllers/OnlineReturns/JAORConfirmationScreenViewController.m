//
//  JAORConfirmationScreenViewController.m
//  Jumia
//
//  Created by Jose Mota on 03/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORConfirmationScreenViewController.h"
#import "JACenterNavigationController.h"
#import "JABottomSubmitView.h"
#import "JAOptionResumeView.h"
#import "JAProductInfoHeaderLine.h"

#define kLateralMargin 16.f

@interface JAORConfirmationScreenViewController ()

@property (nonatomic, strong) JAProductInfoHeaderLine *headerLine;
@property (nonatomic, strong) JAOptionResumeView *reasonOptionView;
@property (nonatomic, strong) JAOptionResumeView *methodOptionView;
@property (nonatomic, strong) JAOptionResumeView *paymentMethodOptionView;
@property (nonatomic, strong) UIView *productsView;
@property (nonatomic, strong) UILabel *confirmationLabel;
@property (nonatomic, strong) JABottomSubmitView *submitView;

@end

@implementation JAORConfirmationScreenViewController

- (JAProductInfoHeaderLine *)headerLine
{
    if (!VALID(_headerLine, JAProductInfoHeaderLine)) {
        _headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kProductInfoHeaderLineHeight)];
#warning STRING TODO
        [_headerLine setTitle:[@"Confirm your return request details" uppercaseString]];
    }
    return _headerLine;
}

- (JAOptionResumeView *)reasonOptionView
{
    if (!VALID(_reasonOptionView, JAOptionResumeView)) {
        _reasonOptionView = [[JAOptionResumeView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.headerLine.frame) + 16.f, self.view.width - 2*kLateralMargin, 0)];
#warning STRING TODO
        [_reasonOptionView setTitle:[@"Return Reason" uppercaseString]];
        [_reasonOptionView.editButton addTarget:self action:@selector(goToReasonStep) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reasonOptionView;
}

- (JAOptionResumeView *)methodOptionView
{
    if (!VALID(_methodOptionView, JAOptionResumeView)) {
        _methodOptionView = [[JAOptionResumeView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.reasonOptionView.frame) + 10.f, self.view.width - 2*kLateralMargin, 0)];
#warning STRING TODO
        [_methodOptionView setTitle:[@"Return Method" uppercaseString]];
    }
    return _methodOptionView;
}

- (JAOptionResumeView *)paymentMethodOptionView
{
    if (!VALID(_paymentMethodOptionView, JAOptionResumeView)) {
        _paymentMethodOptionView = [[JAOptionResumeView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.methodOptionView.frame) + 10.f, self.view.width - 2*kLateralMargin, 0)];
#warning STRING TODO
        [_paymentMethodOptionView setTitle:[@"Return Payment Method" uppercaseString]];
    }
    return _paymentMethodOptionView;
}

- (UIView *)productsView
{
    if (!VALID(_productsView, UIView)) {
        _productsView  = [[UIView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.paymentMethodOptionView.frame) + 16.f, self.view.width - 2*kLateralMargin, 1)];
        [_productsView setBackgroundColor:JABlack300Color];
    }
    return _productsView;
}

- (UILabel *)confirmationLabel
{
    if (!VALID(_confirmationLabel, UILabel)) {
        _confirmationLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.productsView.frame) + 20.f, self.view.width - 2*kLateralMargin, 12)];
#warning STRING TODO
        [_confirmationLabel setText:@"If everything looks good, tap \"SEND\"."];
        [_confirmationLabel setTextAlignment:NSTextAlignmentCenter];
        [_confirmationLabel setFont:JABodyFont];
        [_confirmationLabel setTextColor:JABlack800Color];
        [_confirmationLabel setSizeForcingMaxSize:CGSizeMake(self.view.width - 2*kLateralMargin, CGFLOAT_MAX)];
    }
    return _confirmationLabel;
}

- (JABottomSubmitView *)submitView
{
    if (!VALID(_submitView, JABottomSubmitView)) {
        _submitView = [[JABottomSubmitView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [JABottomSubmitView defaultHeight])];
        _submitView.button = [[JAButton alloc] initButtonWithTitle:STRING_CONTINUE];
        [_submitView.button addTarget:self action:@selector(goToNext) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = NO;
    
    [self.view setBackgroundColor:JAWhiteColor];
    
    [self.view addSubview:self.headerLine];
    [self.view addSubview:self.reasonOptionView];
    [self.view addSubview:self.methodOptionView];
    [self.view addSubview:self.paymentMethodOptionView];
    [self.view addSubview:self.productsView];
    [self.view addSubview:self.confirmationLabel];
    [self.view addSubview:self.submitView];
    
#warning replace these content
    [self.reasonOptionView setOption:@"Item received is not what i ordered"];
    [self.methodOptionView setOption:@"Drop it off at a Jumia Return Station"];
    [self.paymentMethodOptionView setOption:@"Bank Deposit"];
    
    [self.submitView setYBottomAligned:0.f];
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.headerLine setWidth:self.view.width];
    [self.reasonOptionView setWidth:self.view.width - 2*kLateralMargin];
    [self.methodOptionView setYBottomOf:self.reasonOptionView at:10.f];
    [self.methodOptionView setWidth:self.view.width - 2*kLateralMargin];
    [self.paymentMethodOptionView setYBottomOf:self.methodOptionView at:10.f];
    [self.paymentMethodOptionView setWidth:self.view.width - 2*kLateralMargin];
    
    [self.productsView setYBottomOf:self.paymentMethodOptionView at:16.f];
    [self.productsView setWidth:self.view.width - 2*kLateralMargin];
    [self.confirmationLabel setYBottomOf:self.productsView at:20.f];
    [self.confirmationLabel setWidth:self.view.width - 2*kLateralMargin];
    [self.submitView setWidth:self.view.width];
    [self.submitView setYBottomAligned:0.f];
}

- (void)goToNext
{
}

- (void)goToReasonStep
{
    [[JACenterNavigationController sharedInstance] goToOnlineReturnsReasonsScreenForItems:self.items order:self.order];
}

@end
