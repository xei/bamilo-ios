//
//  JAShopWebViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 06/02/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAShopWebViewController.h"
#import "GTMNSString+HTML.h"

@interface JAShopWebViewController ()

@property (nonatomic, strong)UIWebView* webView;
@property (nonatomic, assign)BOOL isLoaded;

@end

@implementation JAShopWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView = [UIWebView new];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    self.isLoaded = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.webView setFrame:self.view.bounds];
    
    if (NO == self.isLoaded) {
        NSURL* url = [NSURL URLWithString:@"http://alice-staging.jumia.com.ng/mobapi/v1.6/main/getstatic/?key=lego_shop"];
        [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:url parameters:nil httpMethodPost:YES cacheType:RIURLCacheNoCache cacheTime:RIURLCacheDefaultTime successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
            NSDictionary *metadata = [jsonObject objectForKey:@"metadata"];
            NSArray *data = [metadata objectForKey:@"data"];
            NSString *html = [[data firstObject] gtm_stringByUnescapingFromHTML];
            NSString *html2 = [html gtm_stringByUnescapingFromHTML];
            
            self.isLoaded = YES;
            [self.webView loadHTMLString:html2 baseURL:url];
        } failureBlock:^(RIApiResponse apiResponse, NSDictionary *errorJsonObject, NSError *errorObjectt) {
            
        }];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.webView setFrame:self.view.bounds];
}

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{    
    NSString* url = [request.URL absoluteString];
    NSArray *parts = [url componentsSeparatedByString: @"::"];
    
    if (VALID_NOTEMPTY(parts, NSArray) && 2 == parts.count) {
        NSString* identifier = [parts objectAtIndex:0];
        NSString* url = [parts objectAtIndex:1];
        if (VALID_NOTEMPTY(identifier, NSString) && VALID_NOTEMPTY(url, NSString)) {

            if ([identifier isEqualToString:@"pdv"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                                    object:nil
                                                                  userInfo:@{ @"url" : url,
                                                                              @"show_back_button_title" : STRING_BACK}];
                
            } else if ([identifier isEqualToString:@"catalog"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithCatalogUrlNofication
                                                                    object:nil
                                                                  userInfo:@{ @"url" : url,
                                                                              @"show_back_button_title" : STRING_BACK}];
                
            } else if ([identifier isEqualToString:@"campaign"]) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectCampaignNofication
                                                                    object:nil
                                                                  userInfo:@{ @"campaign_url" : url,
                                                                              @"show_back_button_title" : STRING_BACK}];
                
            }
            
        }
    }
    
    
    return YES;
}

@end
