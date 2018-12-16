//
//  JAExternalPaymentsViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAExternalPaymentsViewController.h"
#import "RICart.h"
#import "RIPaymentInformation.h"
#import "SuccessPaymentViewController.h"
#import "Bamilo-Swift.h"

@interface JAExternalPaymentsViewController () /*<UIWebViewDelegate>*/
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic) BOOL successfulPayment;
//@property (weak, nonatomic) IBOutlet UIWebView *webView;
//@property (strong, nonatomic) NSURLRequest  *originalRequest;
@end

@implementation JAExternalPaymentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.messageLabel applyStyle:[Theme font:kFontVariationRegular size:14] color:[Theme color:kColorGray1]];
    self.messageLabel.text = STRING_LOADING;
    [self loadPaymentMethodRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(checkPaymentResult) name:@"appDidEnterForeground" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)checkPaymentResult {
    if (self.isComingFromBank) {
        if (self.successfulPayment) {
            [self performSegueWithIdentifier:@"showSuccessPaymentViewController" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"showFailPaymentViewController" sender:nil];
        }
        self.isComingFromBank = NO;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)paymentHappend:(BOOL)success {
    self.successfulPayment = success;
}

- (void)loadPaymentMethodRequest {
    if (self.cart.paymentBrowserUrl.length) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?ResNum=%@&setDevice=mobile", self.cart.paymentBrowserUrl, self.cart.orderNr]]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"showSuccessPaymentViewController"]) {
        SuccessPaymentViewController *viewCtrl = (SuccessPaymentViewController *)segue.destinationViewController;
        viewCtrl.cart = self.cart;
    } else if ([segue.identifier isEqualToString: @"showFailPaymentViewController"]) {
        FailPaymentViewController *viewCtrl = (FailPaymentViewController *)segue.destinationViewController;
        viewCtrl.cart = self.cart;
    }
}

#pragma mark - ScreenTrackerProtocol
-(NSString *)getScreenName {
    return @"ExternalPayment";
}

#pragma mark: -NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_CHECKOUT;
}
@end
