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

@interface JAPDVViewController : JABaseViewController

@property (strong, nonatomic) RIProduct *product;
@property (assign, nonatomic) BOOL fromCatalogue;
@property (strong, nonatomic) NSArray *arrayWithRelatedItems;
@property (strong, nonatomic) NSString *previousCategory;

@end
