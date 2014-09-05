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

@end

@implementation JAShareActivityProvider

@synthesize product = _product;

- (id)initWithProduct:(RIProduct *)product
{
    self = [super init];
    
    if(self)
    {
        self.product = product;
    }
    
    return self;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
         itemForActivityType:(NSString *)activityType
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
        NSString *smsShare = [NSString stringWithFormat:@"Hello! Look I found something great which might interest you: %@", productUrl];
        
        return smsShare;
    }
    
    else if ([activityType isEqualToString:UIActivityTypeMail])
    {
        productUrl = [productUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"mobapi/"]
                                                           withString:@""];
        
        productUrl = [productUrl stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"mobapi/%@", RI_API_VERSION]
                                                           withString:@""];
        
        NSString *emailShare = [NSString stringWithFormat:@"<html><body>Hello! Look I found something great which might interest you:<br><br><a href='%@'><img src='%@'></a><br><br><a href='%@'>%@</a></body></html>", productUrl, productImageUrl, productUrl, productName];
        
        return emailShare;
    }
    
    else
    {
        NSString *socialShare = [NSString stringWithFormat:@"Great product at Jumia: %@ \n\n%@", productName, productUrl];
        
        return socialShare;
    }
    
    return productUrl;
}

- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return @"";
}

@end
