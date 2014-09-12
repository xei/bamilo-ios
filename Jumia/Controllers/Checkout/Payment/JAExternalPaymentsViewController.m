//
//  JAExternalPaymentsViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAExternalPaymentsViewController.h"
#import "RIPaymentInformation.h"

@interface JAExternalPaymentsViewController ()
<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation JAExternalPaymentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showCartButton = NO;
    
    [self.webView setDelegate:self];
    
    [self loadPaymentMethodRequest];
}


-(void)loadPaymentMethodRequest
{
    if(VALID_NOTEMPTY(self.paymentInformation, RIPaymentInformation))
    {
        if(RIPaymentInformationCheckoutShowWebviewWithUrl == self.paymentInformation.type && VALID_NOTEMPTY(self.paymentInformation.url, NSString))
        {
            NSURL *url = [NSURL URLWithString:self.paymentInformation.url];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            BOOL isPOST = NO;
            if(VALID_NOTEMPTY(self.paymentInformation.method, NSString))
            {
                if([@"post" isEqualToString:[self.paymentInformation.method lowercaseString]])
                {
                    isPOST = YES;
                }
                [request setHTTPMethod:self.paymentInformation.method];
            }
            
            [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
            
            [self showLoading];
            
            [self.webView loadRequest:request];
        }
        else if(RIPaymentInformationCheckoutShowWebviewWithForm == self.paymentInformation.type && VALID_NOTEMPTY(self.paymentInformation.form, RIForm) && VALID_NOTEMPTY(self.paymentInformation.form.action, NSString))
        {
            NSURL *url = [NSURL URLWithString:self.paymentInformation.form.action];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            
            BOOL isPOST = NO;
            if(VALID_NOTEMPTY(self.paymentInformation.form.method, NSString))
            {
                if([@"post" isEqualToString:[self.paymentInformation.method lowercaseString]])
                {
                    isPOST = YES;
                }
                [request setHTTPMethod:self.paymentInformation.form.method];
            }
            
            [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
            
            NSDictionary *parameters = [RIForm getParametersForForm:self.paymentInformation.form];
            if(VALID_NOTEMPTY(parameters, NSDictionary))
            {
                if (!isPOST)
                {
                    NSString *urlWithParameters = [NSString stringWithFormat:@"%@?%@", [url absoluteString], [self getParametersString:parameters]];
                    [request setURL:[NSURL URLWithString:urlWithParameters]];
                }
                else
                {
                    NSError *error = nil;
                    
                    [request setValue:RI_HTTP_CONTENT_TYPE_HEADER_FORM_DATA_VALUE forHTTPHeaderField:RI_HTTP_CONTENT_TYPE_HEADER_NAME];
                    [request setHTTPBody:[[self getParametersString:parameters] dataUsingEncoding:NSUTF8StringEncoding]];
                    
//                    [request setValue:RI_HTTP_CONTENT_TYPE_HEADER_JSON_VALUE forHTTPHeaderField:RI_HTTP_CONTENT_TYPE_HEADER_NAME];
//                    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error]];

//                    [request setValue:RI_HTTP_CONTENT_TYPE_HEADER_PLIST_VALUE forHTTPHeaderField:RI_HTTP_CONTENT_TYPE_HEADER_NAME];
//                    [request setHTTPBody:[NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error]];
                    
                    if (error)
                    {
                        NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
                    }
                }
            }
            
            [self showLoading];
            
            [self.webView loadRequest:request];
        }
    }
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

#pragma mark UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"didFailLoadWithError");
    [self hideLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
    [self hideLoading];
}

@end
