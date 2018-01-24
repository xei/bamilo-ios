//
//  JAORCallToReturnViewController.m
//  Jumia
//
//  Created by Jose Mota on 10/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORCallToReturnViewController.h"
#import "JAProductInfoHeaderLine.h"
#import "JAButton.h"
#import "JAUtils.h"
#import "RICustomer.h"
#import "Bamilo-Swift.h"

#define kLateralMargin 16.f

@interface JAORCallToReturnViewController ()

@property (nonatomic, strong) JAProductInfoHeaderLine *titleHeaderLineView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *orderNumberLabel;
@property (nonatomic, strong) UILabel *body1Label;
@property (nonatomic, strong) UILabel *body2Label;
@property (nonatomic, strong) JAButton *callButton;
@property (nonatomic, strong) JAButton *backButton;

@property (nonatomic, strong) NSString *phoneNumber;
@end

@implementation JAORCallToReturnViewController

- (JAProductInfoHeaderLine *)titleHeaderLineView
{
    if (!VALID(_titleHeaderLineView, JAProductInfoHeaderLine)) {
        _titleHeaderLineView = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kProductInfoHeaderLineHeight)];
        [_titleHeaderLineView setTitle:[STRING_CALL_TO_RETURN uppercaseString]];
    }
    return _titleHeaderLineView;
}

- (UILabel *)titleLabel
{
    if (!VALID(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.titleHeaderLineView.frame) + 16.f, self.view.width-2*kLateralMargin, 10)];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setFont:JADisplay2Font];
        [_titleLabel setTextColor:JABlackColor];
    }
    return _titleLabel;
}

- (UILabel *)orderNumberLabel
{
    if (!VALID(_orderNumberLabel, UILabel)) {
        _orderNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.titleLabel.frame) + 16.f, self.view.width-2*kLateralMargin, 30)];
        [_orderNumberLabel setTextAlignment:NSTextAlignmentCenter];
        [_orderNumberLabel setBackgroundColor:JAYellow2Color];
        [_orderNumberLabel.layer setBorderColor:JAYellow1Color.CGColor];
        [_orderNumberLabel.layer setBorderWidth:1];
        [_orderNumberLabel setFont:JABodyFont];
        [_orderNumberLabel setTextColor:JABlackColor];
    }
    return _orderNumberLabel;
}

- (UILabel *)body1Label
{
    if (!VALID(_body1Label, UILabel)) {
        _body1Label = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.orderNumberLabel.frame) + 16.f, self.view.width-2*kLateralMargin, 20)];
        [_body1Label setTextAlignment:NSTextAlignmentCenter];
        [_body1Label setNumberOfLines:0];
        [_body1Label setFont:JABodyFont];
        [_body1Label setTextColor:JABlack800Color];
    }
    return _body1Label;
}

- (UILabel *)body2Label
{
    if (!VALID(_body2Label, UILabel)) {
        _body2Label = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.body1Label.frame) + 6.f, self.view.width-2*kLateralMargin, 20)];
        [_body2Label setTextAlignment:NSTextAlignmentCenter];
        [_body2Label setNumberOfLines:0];
        [_body2Label setFont:JABodyFont];
        [_body2Label setTextColor:JABlackColor];
    }
    return _body2Label;
}

- (JAButton *)callButton
{
    if (!VALID(_callButton, JAButton)) {
        _callButton = [[JAButton alloc] initButtonWithTitle:STRING_CALL_NOW];
        [_callButton setFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.body2Label.frame) + 6.f, self.view.width-2*kLateralMargin, kBottomDefaultHeight)];
        [_callButton addTarget:self action:@selector(callToReturn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callButton;
}

- (JAButton *)backButton
{
    if (!VALID(_backButton, JAButton)) {
        _backButton = [[JAButton alloc] initAlternativeButtonWithTitle:STRING_CONTINUE_SHOPPING];
        [_backButton setFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.callButton.frame) + 16.f, self.view.width-2*kLateralMargin, kBottomDefaultHeight)];
        [_backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:JAWhiteColor];
    
    [self.view setBackgroundColor:JAWhiteColor];
    
    [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
        
        if([[UIDevice currentDevice].model isEqualToString:@"iPhone"])
        {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", configuration.phoneNumber]]])
            {
                [self.callButton setEnabled:YES];
            }
            else
            {
                [self.callButton setEnabled:NO];
                [self.callButton setTitle:[[NSString stringWithFormat:STRING_PLEASE_CALL_TO, configuration.phoneNumber] uppercaseString] forState:UIControlStateNormal];
            }
        }
        else
        {
            [self.callButton setEnabled:NO];
            [self.callButton setTitle:[[NSString stringWithFormat:STRING_PLEASE_CALL_TO, configuration.phoneNumber] uppercaseString] forState:UIControlStateNormal];
        }
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        
    }];
    
    if (VALID(self.item, RIItemCollection)) {
        [self.titleLabel setText:self.item.callReturnTextTitle];
        [self.body1Label setText:self.item.callReturnTextBody1];
        [self.body2Label setText:self.item.callReturnTextBody2];
        [self.orderNumberLabel setText:[NSString stringWithFormat:STRING_ORDER_NO, self.orderNumber]];
    }
    
    [self.view addSubview:self.titleHeaderLineView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.orderNumberLabel];
    [self.view addSubview:self.body1Label];
    [self.view addSubview:self.body2Label];
    [self.view addSubview:self.callButton];
    [self.view addSubview:self.backButton];
    [self setup];
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    [self setup];
}

- (void)setup
{
    [self.titleHeaderLineView setWidth:self.view.width];
    [self.titleHeaderLineView setXCenterAligned];
    CGFloat bodyWidth = self.view.width-2*kLateralMargin;
    
    [self.titleLabel setSizeForcingMaxSize:CGSizeMake(bodyWidth, CGFLOAT_MAX)];
    [self.titleLabel setXCenterAligned];
    
    [self.orderNumberLabel setYBottomOf:self.titleLabel at:16.f];
    [self.orderNumberLabel setSizeForcingMaxSize:CGSizeMake(bodyWidth, CGFLOAT_MAX)];
    self.orderNumberLabel.height += 6.f;
    self.orderNumberLabel.width += (self.orderNumberLabel.width + 6.f) > bodyWidth ? 0 : 6.f;
    [self.orderNumberLabel setXCenterAligned];
    
    [self.body1Label setYBottomOf:self.orderNumberLabel at:16.f];
    [self.body1Label setSizeForcingMaxSize:CGSizeMake(bodyWidth, CGFLOAT_MAX)];
    [self.body1Label setXCenterAligned];
    
    [self.body2Label setYBottomOf:self.body1Label at:6.f];
    [self.body2Label setSizeForcingMaxSize:CGSizeMake(bodyWidth, CGFLOAT_MAX)];
    [self.body2Label setXCenterAligned];
    
    [self.callButton setWidth:bodyWidth];
    [self.callButton setYBottomOf:self.body2Label at:16.f];
    [self.callButton setXCenterAligned];
    
    [self.backButton setWidth:bodyWidth];
    [self.backButton setYBottomOf:self.callButton at:16.f];
    [self.backButton setXCenterAligned];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (void)callToReturn
{
    if (VALID_NOTEMPTY(self.phoneNumber, NSString)) {
        [self trackingEventCallToReturn];
        
        NSString *phoneNumber = [@"tel://" stringByAppendingString:self.phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (void)goBack
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

- (void)trackingEventCallToReturn {
    [TrackerManager postEventWithSelector:[EventSelectors callToOrderTappedSelector] attributes:[EventAttributes callToOrderTapped]];
//    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
//    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
//    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
//    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
//
//    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCallToOrder]
//                                              data:[trackingDictionary copy]];
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_CALL_TO_RETURN;
}


@end
