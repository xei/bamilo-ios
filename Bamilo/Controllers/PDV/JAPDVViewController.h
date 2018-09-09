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
#import "MPCoachMarks.h"
#import "EmarsysPredictProtocol.h"
#import "DataServiceProtocol.h"

@protocol JAPDVViewControllerDelegate <NSObject>
- (void)addToWishList:(NSString *)sku add:(BOOL)add;
@end

@interface JAPDVViewController : JABaseViewController <JAPDVImageSectionDelegate, EmarsysPredictProtocol, DataServiceProtocol>

@property (nonatomic, weak) id<JAPDVViewControllerDelegate> delegate;
@property (strong, nonatomic) RIProduct *product;
@property (strong, nonatomic) NSString *productSku;
@property (strong, nonatomic) RICategory *category;
@property (strong, nonatomic) NSString *preSelectedSize;
@property (strong, nonatomic) NSString *richRelevanceParameter;
@property (nonatomic, strong) NSString *purchaseTrackingInfo;

@end
