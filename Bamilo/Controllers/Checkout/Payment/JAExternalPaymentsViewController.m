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

@interface JAExternalPaymentsViewController () /*<UIWebViewDelegate>*/
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
//@property (weak, nonatomic) IBOutlet UIWebView *webView;
//@property (strong, nonatomic) NSURLRequest  *originalRequest;
@end

@implementation JAExternalPaymentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.webView.translatesAutoresizingMaskIntoConstraints = YES;
//    [self.webView setDelegate:self];
//    self.originalRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[RIApi getCountryUrlInUse]]];
    [self.messageLabel applyStyle:[Theme font:kFontVariationRegular size:14] color:[Theme color:kColorGray1]];
    self.messageLabel.text = STRING_LOADING;
    [self loadPaymentMethodRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self publishScreenLoadTime];
}
//
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self.webView setFrame:self.view.bounds];
}

- (void)paymentHappend:(BOOL)success {
    
}

-(void)loadPaymentMethodRequest {
    if (self.cart.paymentBrowserUrl.length) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?ResNum=%@&setDevice=mobile", self.cart.paymentBrowserUrl, self.cart.orderNr]]];
    }
    
//    else if(VALID_NOTEMPTY(self.cart.paymentInformation, RIPaymentInformation)) {
//        if(RIPaymentInformationCheckoutShowWebviewWithUrl == self.cart.paymentInformation.type && VALID_NOTEMPTY(self.cart.paymentInformation.url, NSString)) {
//            NSLog(@"RIPaymentInformationCheckoutShowWebviewWithUrl %@", self.cart.paymentInformation.url);
//            [self.webView loadRequest:[self createRequestWithUrl:self.cart.paymentInformation.url]];
//        } else if(RIPaymentInformationCheckoutShowWebviewWithForm == self.cart.paymentInformation.type && VALID_NOTEMPTY(self.cart.paymentInformation.form, RIForm) && VALID_NOTEMPTY(self.cart.paymentInformation.form.action, NSString)) {
//            NSLog(@"RIPaymentInformationCheckoutShowWebviewWithForm %@", self.cart.paymentInformation.form.action);
//            NSMutableURLRequest *request = [self createRequestWithUrl:self.cart.paymentInformation.form.action];
//            BOOL isPOST = NO;
//            if(VALID_NOTEMPTY(self.cart.paymentInformation.form.method, NSString) && [@"post" isEqualToString:[self.cart.paymentInformation.method lowercaseString]]) {
//                isPOST = YES;
//            }
//            NSDictionary *parameters = [RIForm getParametersForForm:self.cart.paymentInformation.form];
//            if(VALID_NOTEMPTY(parameters, NSDictionary)) {
//                if (!isPOST) {
//                    NSString *urlWithParameters = [NSString stringWithFormat:@"%@?%@", self.cart.paymentInformation.form.action, [self getParametersString:parameters]];
//                    [request setURL:[NSURL URLWithString:urlWithParameters]];
//                } else {
//                    NSError *error = nil;
//                    [request setHTTPBody:[[self getParametersString:parameters] dataUsingEncoding:NSUTF8StringEncoding]];
//                    if (error) {
//                        NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
//                    }
//                }
//            }
//            [self.webView loadRequest:request];
//        }
//    }
}

//- (NSMutableURLRequest *)createRequestWithUrl:(NSString*)url {
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
//
//    if(VALID_NOTEMPTY(self.cart.paymentInformation.form.method, NSString) && [@"post" isEqualToString:[self.cart.paymentInformation.method lowercaseString]]) {
//        [request setHTTPMethod:RI_HTTP_METHOD_POST];
//    }
//
//    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
//    [request setHTTPShouldHandleCookies:YES];
//
//    return request;
//}

//- (NSString *) getParametersString:(NSDictionary *)parameters {
//    NSMutableArray *encodedParameters = [NSMutableArray array];
//
//    NSArray *parametersKeys=[parameters allKeys];
//    if(NOTEMPTY(parametersKeys)) {
//        for(NSString *parameterKey in parametersKeys) {
//            if(NOTEMPTY([parameters objectForKey:parameterKey])) {
//                NSString *parameterValue = [parameters objectForKey:parameterKey];
//                [encodedParameters addObject:[NSString stringWithFormat:@"%@=%@", parameterKey, [self encodeParameter:parameterValue]]];
//            }
//        }
//    }
//
//    return [encodedParameters componentsJoinedByString:@"&"];
//}

//- (NSString *) encodeParameter:(NSString *) string{
//    NSMutableString *output = [NSMutableString string];
//    const unsigned char *source = (const unsigned char *)[string UTF8String];
//    NSInteger sourceLen = strlen((const char *)source);
//    for (int i = 0; i < sourceLen; ++i) {
//        const unsigned char thisChar = source[i];
//        if (thisChar == ' '){
//            [output appendString:@"+"];
//        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
//                   (thisChar >= 'a' && thisChar <= 'z') ||
//                   (thisChar >= 'A' && thisChar <= 'Z') ||
//                   (thisChar >= '0' && thisChar <= '9')) {
//            [output appendFormat:@"%c", thisChar];
//        } else {
//            [output appendFormat:@"%%%02X", thisChar];
//        }
//    }
//    return output;
//}

//- (void) checkAppObject {
//    NSString *jsonAppObjectString = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('jsonAppObject').innerHTML"];
//
//    NSError *error;
//    NSData *jsonAppObjectData = [jsonAppObjectString dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:jsonAppObjectData
//                                                                 options:kNilOptions
//                                                                   error:&error];
//
//    if(VALID_NOTEMPTY(jsonResponse, NSDictionary) && ISEMPTY(error)) {
//        NSString *orderNumber = [jsonResponse objectForKey:@"order_nr"];
//        if(!VALID_NOTEMPTY(orderNumber, NSString)) {
//            orderNumber = [jsonResponse objectForKey:@"orderNr"];
//        }
//
//        if(VALID_NOTEMPTY(orderNumber, NSString)) {
//            NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[orderNumber, self.cart] forKeys:@[@"order_number", kCart]];
//
//            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutThanksScreenNotification
//                                                                object:nil
//                                                              userInfo:userInfo];
//        }
//    }
//}

//#pragma mark UIWebViewDelegate
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSURL *url = [request URL];
//    NSString *existingAuthValue = [request valueForHTTPHeaderField:@"Authorization"];
//    if ([[url host] isEqualToString:[[self.originalRequest URL] host]] && existingAuthValue == nil) {
//        NSMutableURLRequest *newRequest = [request mutableCopy];
//        NSString *authStr = [NSString stringWithFormat:@"%@:%@", RI_USERNAME, RI_PASSWORD];
//        NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
//        [newRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
//
//        request = newRequest;
//    }
//    return YES;
//}

//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    [self hideLoading];
//}
//
//-(void)webViewDidStartLoad:(UIWebView *)webView {
//    [self showLoading];
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [self hideLoading];
//    [self checkAppObject];
//}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getScreenName {
    return @"ExternalPayment";
}

#pragma mark: -NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_CHECKOUT;
}
@end
