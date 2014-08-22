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

@protocol JAPDVViewControllerDelegate <NSObject>

- (void)changedFavoriteStateOfProduct:(RIProduct*)product;

@end

@interface JAPDVViewController : JABaseViewController

@property (strong, nonatomic) RIProduct *product;
@property (strong, nonatomic) NSString* productUrl;
@property (assign, nonatomic) BOOL fromCatalogue;
@property (strong, nonatomic) NSArray *arrayWithRelatedItems;
@property (strong, nonatomic) NSString *previousCategory;
@property (nonatomic, assign) id<JAPDVViewControllerDelegate>delegate;


@end
