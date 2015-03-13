//
//  JAPDVViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "RIProduct.h"
#import "RICategory.h"
#import "JAPDVImageSection.h"

@interface JAPDVViewController : JABaseViewController <JAPDVImageSectionDelegate>

@property (strong, nonatomic) RIProduct *product;
@property (strong, nonatomic) NSString* productUrl;
@property (strong, nonatomic) NSString* productSku;
@property (strong, nonatomic) RICategory *category;
@property (assign, nonatomic) BOOL fromCatalogue;
@property (strong, nonatomic) NSString *previousCategory;
@property (strong, nonatomic) NSString *preSelectedSize;
@property (assign, nonatomic) BOOL showBackButton;

@property (nonatomic, retain) NSString* A4SViewControllerAlias;

@end
