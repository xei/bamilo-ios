//
//  JAExternalPaymentsViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAExternalPaymentsViewController.h"
#import "RIPaymentInformation.h"
#import "RICheckout.h"

@interface JAExternalPaymentsViewController ()
<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURLRequest  *originalRequest;

@end

@implementation JAExternalPaymentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"ExternalPayment";
    
    self.navBarLayout.showCartButton = NO;
    
    self.navBarLayout.title = STRING_CHECKOUT;
    
    [self.webView setDelegate:self];
    
    self.originalRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[RIApi getCountryUrlInUse]]];

    [self loadPaymentMethodRequest];
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}


-(void)loadPaymentMethodRequest
{
    if(VALID_NOTEMPTY(self.paymentInformation, RIPaymentInformation))
    {
        if(RIPaymentInformationCheckoutShowWebviewWithUrl == self.paymentInformation.type && VALID_NOTEMPTY(self.paymentInformation.url, NSString))
        {
            NSLog(@"RIPaymentInformationCheckoutShowWebviewWithUrl %@", self.paymentInformation.url);
            [self.webView loadRequest:[self createRequestWithUrl:self.paymentInformation.url]];
        }
        else if(RIPaymentInformationCheckoutShowWebviewWithForm == self.paymentInformation.type && VALID_NOTEMPTY(self.paymentInformation.form, RIForm) && VALID_NOTEMPTY(self.paymentInformation.form.action, NSString))
        {
            NSLog(@"RIPaymentInformationCheckoutShowWebviewWithForm %@", self.paymentInformation.form.action);
            
            NSMutableURLRequest *request = [self createRequestWithUrl:self.paymentInformation.form.action];
            
            BOOL isPOST = NO;
            if(VALID_NOTEMPTY(self.paymentInformation.form.method, NSString) && [@"post" isEqualToString:[self.paymentInformation.method lowercaseString]])
            {
                isPOST = YES;
            }
            
            NSDictionary *parameters = [RIForm getParametersForForm:self.paymentInformation.form];
            if(VALID_NOTEMPTY(parameters, NSDictionary))
            {
                if (!isPOST)
                {
                    NSString *urlWithParameters = [NSString stringWithFormat:@"%@?%@", self.paymentInformation.form.action, [self getParametersString:parameters]];
                    [request setURL:[NSURL URLWithString:urlWithParameters]];
                }
                else
                {
                    NSError *error = nil;
                    
                    [request setHTTPBody:[[self getParametersString:parameters] dataUsingEncoding:NSUTF8StringEncoding]];
                    
                    if (error)
                    {
                        NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
                    }
                }
            }
            
            [self.webView loadRequest:request];
        }
    }
}

- (NSMutableURLRequest *)createRequestWithUrl:(NSString*)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    if(VALID_NOTEMPTY(self.paymentInformation.form.method, NSString) && [@"post" isEqualToString:[self.paymentInformation.method lowercaseString]])
    {
        [request setHTTPMethod:RI_HTTP_METHOD_POST];
    }
    
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setHTTPShouldHandleCookies:YES];
    
    return request;
}

- (NSString *) getParametersString:(NSDictionary *)parameters {
    NSMutableArray *encodedParameters = [NSMutableArray array];
    
    NSArray *parametersKeys=[parameters allKeys];
    if(NOTEMPTY(parametersKeys)) {
        for(NSString *parameterKey in parametersKeys) {
            if(NOTEMPTY([parameters objectForKey:parameterKey])) {
                NSString *parameterValue = [parameters objectForKey:parameterKey];
                [encodedParameters addObject:[NSString stringWithFormat:@"%@=%@", parameterKey, [self encodeParameter:parameterValue]]];
            }
        }
    }
    
    return [encodedParameters componentsJoinedByString:@"&"];
}

- (NSString *) encodeParameter:(NSString *) string{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (void) checkAppObject
{
    NSString *jsonAppObjectString = [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('jsonAppObject').innerHTML"];
    
    NSError *error;
    NSData *jsonAppObjectData = [jsonAppObjectString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:jsonAppObjectData
                                                                 options:kNilOptions
                                                                   error:&error];
    
    if(VALID_NOTEMPTY(jsonResponse, NSDictionary) && ISEMPTY(error))
    {
        NSString *orderNumber = [jsonResponse objectForKey:@"order_nr"];
        if(!VALID_NOTEMPTY(orderNumber, NSString))
        {
            orderNumber = [jsonResponse objectForKey:@"orderNr"];
        }
        
        if(VALID_NOTEMPTY(orderNumber, NSString))
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[orderNumber, self.checkout] forKeys:@[@"order_number", @"checkout"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutThanksScreenNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }
    }
}

#pragma mark UIWebViewDelegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    
    BOOL shouldNavigate = NO;
    
    NSString *existingAuthValue = [request valueForHTTPHeaderField:@"Authorization"];
    if ([[url host] isEqualToString:[[self.originalRequest URL] host]] && existingAuthValue == nil)
    {
        NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:url];
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", RI_USERNAME, RI_PASSWORD];
        NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
        [newRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
        
        //Append any other info from the old request
        [webView loadRequest:newRequest];
    }
    else
    {
        shouldNavigate = YES;
    }
    
    
    return shouldNavigate;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoading];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoading];
    
    [self checkAppObject];
}

@end
