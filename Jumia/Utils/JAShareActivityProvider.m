//
//  JAShareActivityProvider.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAShareActivityProvider.h"
#import "RIImage.h"

@interface JAShareActivityProvider ()

@property (nonatomic, strong) RIProduct *product;
@property (nonatomic, assign) BOOL productShare;
@property (nonatomic, assign) BOOL appShare;

@end

@implementation JAShareActivityProvider

@synthesize product = _product;

- (id)initForProductShare:(RIProduct *)product
{
    self = [super init];
    
    if(self)
    {
        self.product = product;
        self.productShare = YES;
        self.appShare = NO;
    }
    
    return self;
}

- (id)initForAppShare
{
    self = [super init];
    
    if(self)
    {
        self.productShare = NO;
        self.appShare = YES;
    }
    
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType
{
    NSString *shareObject = @"";
    if(self.productShare)
    {
        NSString *productUrl = @"";
        NSString *productName = @"";
        NSString *productDescription = @"";
        NSString *productImageUrl = @"";
        
        if(VALID_NOTEMPTY(self.product, RIProduct))
        {
            if(VALID_NOTEMPTY(self.product.url, NSString))
            {
                productUrl = self.product.url;
                
                if(NSNotFound != [productUrl rangeOfString:RI_MOBAPI_PREFIX].location)
                {
                    productUrl = [productUrl stringByReplacingOccurrencesOfString:RI_MOBAPI_PREFIX withString:@""];
                }
                
                if(NSNotFound != [productUrl rangeOfString:RI_API_VERSION].location)
                {
                    productUrl = [productUrl stringByReplacingOccurrencesOfString:RI_API_VERSION withString:@""];
                }
            }
            
            if(VALID_NOTEMPTY(self.product.name, NSString))
            {
                productName = self.product.name;
            }
            
            if(VALID_NOTEMPTY(self.product.descriptionString, NSString))
            {
                productDescription = self.product.descriptionString;
            }
            
            if(self.product.images.count > 0)
            {
                RIImage *image = [self.product.images firstObject];
                productImageUrl = image.url;
            }
        }
        
        if ([activityType isEqualToString:UIActivityTypeMessage])
        {
            NSString *smsShare = [NSString stringWithFormat:@"%@: %@", STRING_SHARE_PRODUCT_MESSAGE, productUrl];
            
            shareObject = smsShare;
        }
        
        else if ([activityType isEqualToString:UIActivityTypeMail])
        {
            productUrl = [productUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/mobapi"]
                                                               withString:@""];
            
            NSString *emailShare = [NSString stringWithFormat:@"<html><body>%@:<br><br><a href='%@'><img src='%@'></a><br><br><a href='%@'>%@</a></body></html>", STRING_SHARE_PRODUCT_MESSAGE, productUrl, productImageUrl, productUrl, productName];
            
            shareObject = emailShare;
        }
        
        else
        {
            NSString *socialShare = [NSString stringWithFormat:@"%@: %@ \n\n%@", STRING_SHARE_PRODUCT_MESSAGE, productName, productUrl];
            
            shareObject = socialShare;
        }
        
        shareObject = productUrl;
    }
    else if(self.appShare)
    {
        if ([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
        {
            shareObject = [NSString stringWithFormat:@"%@ %@", [NSString stringWithFormat:STRING_INSTALL_APP, APP_NAME], kAppStoreUrl];
            
        }else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
        {
            shareObject = [NSString stringWithFormat:@"%@ %@", [NSString stringWithFormat:STRING_INSTALL_APP, APP_NAME], kAppStoreUrlDaraz];
            
        }else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
        {
            shareObject = [NSString stringWithFormat:@"%@ %@", [NSString stringWithFormat:STRING_INSTALL_APP, APP_NAME], kAppStoreUrlShop];
            
        }else if ([[APP_NAME uppercaseString] isEqualToString:@"BAMILO"])
        {
            shareObject = [NSString stringWithFormat:@"%@ %@", [NSString stringWithFormat:STRING_INSTALL_APP, APP_NAME], kAppStoreUrlBamilo];
        }
    }
    
    return shareObject;
}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

@end
