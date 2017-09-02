//
//  JAORConfirmationScreenViewController.m
//  Jumia
//
//  Created by Jose Mota on 03/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAORConfirmationScreenViewController.h"
#import "JABottomSubmitView.h"
#import "JAOptionResumeView.h"
#import "JAProductInfoHeaderLine.h"
#import "JAORProductView.h"
#import "Bamilo-Swift.h"

#define kLateralMargin 16.f

@interface JAORConfirmationScreenViewController ()

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) JAProductInfoHeaderLine *headerLine;
@property (nonatomic, strong) JAOptionResumeView *reasonOptionView;
@property (nonatomic, strong) JAOptionResumeView *methodOptionView;
@property (nonatomic, strong) JAOptionResumeView *paymentMethodOptionView;
@property (nonatomic, strong) UIView *productsView;
@property (nonatomic, strong) UILabel *confirmationLabel;
@property (nonatomic, strong) JABottomSubmitView *submitView;
@property (nonatomic, strong) NSArray* itemViewsArray;

@end

@implementation JAORConfirmationScreenViewController

- (UIScrollView *)mainScrollView
{
    if (!VALID(_mainScrollView, UIScrollView)) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self.view addSubview:_mainScrollView];
    }
    return _mainScrollView;
}

- (JAProductInfoHeaderLine *)headerLine
{
    if (!VALID(_headerLine, JAProductInfoHeaderLine)) {
        _headerLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kProductInfoHeaderLineHeight)];
        [_headerLine setTitle:[STRING_RETURN_FINISH_TITLE uppercaseString]];
        [self.mainScrollView addSubview:_headerLine];
    }
    return _headerLine;
}

- (JAOptionResumeView *)reasonOptionView
{
    if (!VALID(_reasonOptionView, JAOptionResumeView)) {
        _reasonOptionView = [[JAOptionResumeView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.headerLine.frame) + 16.f, self.view.width - 2*kLateralMargin, 0)];
        [_reasonOptionView setHidden:YES];
        [_reasonOptionView setTitle:[STRING_RETURN_REASON uppercaseString]];
        [_reasonOptionView.editButton addTarget:self action:@selector(goToReasonStep) forControlEvents:UIControlEventTouchUpInside];
        [self.mainScrollView addSubview:_reasonOptionView];
    }
    return _reasonOptionView;
}

- (JAOptionResumeView *)methodOptionView
{
    if (!VALID(_methodOptionView, JAOptionResumeView)) {
        _methodOptionView = [[JAOptionResumeView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.headerLine.frame) + 16.f, self.view.width - 2*kLateralMargin, 0)];
        [_methodOptionView setTitle:[STRING_RETURN_METHOD uppercaseString]];
        [_methodOptionView.editButton addTarget:self action:@selector(goToMethodStep) forControlEvents:UIControlEventTouchUpInside];
        [self.mainScrollView addSubview:_methodOptionView];
    }
    return _methodOptionView;
}

- (JAOptionResumeView *)paymentMethodOptionView
{
    if (!VALID(_paymentMethodOptionView, JAOptionResumeView)) {
        _paymentMethodOptionView = [[JAOptionResumeView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.methodOptionView.frame) + 10.f, self.view.width - 2*kLateralMargin, 0)];
        [_paymentMethodOptionView setTitle:[STRING_RETURN_PAYMENT_METHOD uppercaseString]];
        [_paymentMethodOptionView.editButton addTarget:self action:@selector(goToPaymentMethodStep) forControlEvents:UIControlEventTouchUpInside];
        [self.mainScrollView addSubview:_paymentMethodOptionView];
    }
    return _paymentMethodOptionView;
}

- (UIView *)productsView
{
    if (!VALID(_productsView, UIView)) {
        _productsView  = [[UIView alloc] initWithFrame:CGRectMake(0.f, CGRectGetMaxY(self.paymentMethodOptionView.frame), self.view.width, 1)];
        [self.mainScrollView addSubview:_productsView];
    }
    return _productsView;
}

- (UILabel *)confirmationLabel
{
    if (!VALID(_confirmationLabel, UILabel)) {
        _confirmationLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.productsView.frame) + 20.f, self.view.width - 2*kLateralMargin, 12)];
        [_confirmationLabel setText:STRING_IF_EVERYTHING_LOOKS_GOOD];
        [_confirmationLabel setTextAlignment:NSTextAlignmentCenter];
        [_confirmationLabel setFont:JABodyFont];
        [_confirmationLabel setTextColor:JABlack800Color];
        [_confirmationLabel setSizeForcingMaxSize:CGSizeMake(self.view.width - 2*kLateralMargin, CGFLOAT_MAX)];
        [self.mainScrollView addSubview:_confirmationLabel];
    }
    return _confirmationLabel;
}

- (JABottomSubmitView *)submitView
{
    if (!VALID(_submitView, JABottomSubmitView)) {
        _submitView = [[JABottomSubmitView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, [JABottomSubmitView defaultHeight])];
        _submitView.button = [[JAButton alloc] initButtonWithTitle:STRING_CONTINUE];
        [_submitView.button addTarget:self action:@selector(goToNext) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_submitView];
    }
    return _submitView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:JAWhiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadAll];
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    [self reloadAll];
}

- (void)reloadAll
{
    [self.mainScrollView setWidth:self.view.width];
    [self.mainScrollView setY:0.f];
    [self.headerLine setWidth:self.mainScrollView.width];
    [self.reasonOptionView setWidth:self.mainScrollView.width - 2*kLateralMargin];
    [self.reasonOptionView setYBottomOf:self.headerLine at:16.f];
    [self.methodOptionView setYBottomOf:self.headerLine at:16.f];
    if (VALID_NOTEMPTY(self.items, NSArray) && self.items.count == 1) {
        [self.reasonOptionView setHidden:NO];
        [self.methodOptionView setYBottomOf:self.reasonOptionView at:16.f];
    }else{
        [self.reasonOptionView setHidden:YES];
    }
    [self.methodOptionView setWidth:self.mainScrollView.width - 2*kLateralMargin];
    [self.paymentMethodOptionView setYBottomOf:self.methodOptionView at:10.f];
    [self.paymentMethodOptionView setWidth:self.mainScrollView.width - 2*kLateralMargin];
    
    [self.productsView setYBottomOf:self.paymentMethodOptionView at:0.f];
    [self.productsView setWidth:self.mainScrollView.width - 2*kLateralMargin];
    [self.confirmationLabel setYBottomOf:self.productsView at:20.f];
    [self.confirmationLabel setWidth:self.mainScrollView.width - 2*kLateralMargin];
    [self.submitView setWidth:self.view.width];
    [self.submitView setYBottomAligned:0.f];
    [self.mainScrollView setHeight:self.viewBounds.size.height - self.submitView.height];
    [self loadItems];
}

- (void)loadItems
{
    [self.productsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.productsView setHeight:0];
    [self.productsView setWidth:self.mainScrollView.width];
    
    [self.methodOptionView setOption:[self.stateInfoLabels objectForKey:@"return_method[method]"]];
    [self.paymentMethodOptionView setOption:[self.stateInfoLabels objectForKey:@"refund_method[method]"]];
    
    for (RIItemCollection *item in self.items) {
        
        UIView *sepatator = [[UIView alloc] initWithFrame:CGRectMake(kLateralMargin, self.productsView.height + 16.f, self.productsView.width - 2*kLateralMargin, 1.f)];
        [sepatator setBackgroundColor:JABlack400Color];
        [self.productsView addSubview:sepatator];
        
        JAORProductView* productView = [[JAORProductView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                         self.productsView.height + 16,
                                                                                         self.productsView.width,
                                                                                         1.0f)];
        [productView setupWithItemCollection:item order:self.order];
        [productView setQtyToReturn:[self.stateInfoLabels objectForKey:[NSString stringWithFormat:@"return_detail[%@][quantity]", item.sku]]];
        [self.productsView addSubview:productView];
        
        [self.productsView setHeight:CGRectGetMaxY(productView.frame)];
        
        if (self.items.count == 1) {
            [self.reasonOptionView setOption:[self.stateInfoLabels objectForKey:[NSString stringWithFormat:@"return_detail[%@][reason]", item.sku]]];
            break;
        }
        
        JAOptionResumeView *reasonOptionView = [[JAOptionResumeView alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(productView.frame), self.productsView.width - 2*kLateralMargin, 0)];
        [reasonOptionView setTitle:[STRING_RETURN_REASON uppercaseString]];
        [reasonOptionView setOption:[self.stateInfoLabels objectForKey:[NSString stringWithFormat:@"return_detail[%@][reason]", item.sku]]];
        [reasonOptionView.editButton addTarget:self action:@selector(goToReasonStep) forControlEvents:UIControlEventTouchUpInside];
        [self.productsView addSubview:reasonOptionView];
        
        [self.productsView setHeight:CGRectGetMaxY(reasonOptionView.frame)];
    }
    [self.mainScrollView addSubview:self.productsView];
    
    [self.confirmationLabel setYBottomOf:self.productsView at:20.f];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, CGRectGetMaxY(self.confirmationLabel.frame) + 16.f)];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (void)goToNext
{
    [self showLoading];
    [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_RETURN_FINISH]]
                                                     parameters:[self.stateInfoValues copy]
                                                     httpMethod:HttpVerbPOST
                                                      cacheType:RIURLCacheNoCache
                                                      cacheTime:RIURLCacheNoTime
                                             userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                   successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                       NSArray *successMessage = @[];
                                                       if (VALID_NOTEMPTY([jsonObject objectForKey:@"messages"], NSDictionary)) {
                                                           NSDictionary *messages = [jsonObject objectForKey:@"messages"];
                                                           if (VALID_NOTEMPTY([messages objectForKey:@"success"], NSArray)) {
                                                               NSArray *success = [messages objectForKey:@"success"];
                                                               if (VALID_NOTEMPTY([success valueForKey:@"message"], NSArray)) {
                                                                   successMessage = [success valueForKey:@"message"];
                                                               }
                                                           }
                                                       }
                                                       [self onSuccessResponse:apiResponse messages:successMessage showMessage:YES];
                                                       [self hideLoading];
//                                                       BOOL done = [[MainTabBarViewController topNavigationController] closeScreensToStackClass:[JAMyOrderDetailViewController class] animated:YES];
//                                                       if (!done) {
//                                                           done = [[MainTabBarViewController topNavigationController] closeScreensToStackClass:[JAMyOrdersViewController class] animated:YES];
//                                                       }
                                                   } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObject) {
                                                       NSArray *errorMessages = @[];
                                                       if(NOTEMPTY(errorJsonObject))
                                                       {
                                                           errorMessages = [RIError getErrorMessages:errorJsonObject];
                                                       } else if(NOTEMPTY(errorObject)) {
                                                           errorMessages = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                       }
                                                       [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:nil objects:nil];
                                                       [self hideLoading];
                                                   }];
}

- (void)goToReasonStep
{
    [[MainTabBarViewController topNavigationController] goToOnlineReturnsReasonsScreenForItems:self.items order:self.order];
}

- (void)goToMethodStep
{
    [[MainTabBarViewController topNavigationController] goToOnlineReturnsWaysScreenForItems:self.items order:self.order];
}

- (void)goToPaymentMethodStep
{
    [[MainTabBarViewController topNavigationController] goToOnlineReturnsPaymentScreenForItems:self.items order:self.order];
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_MY_ORDERS;
}


@end
