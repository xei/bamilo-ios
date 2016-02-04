//
//  JAPDVProductInfo.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RIProduct;

@interface JAPDVProductInfo : UIView

@property (nonatomic) NSString *sizesText;

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize;

- (void)setSpecialPrice:(NSString*)special andPrice:(NSString*)price andMaxSavingPercentage:(NSString*)maxSavingPercentage shouldForceFlip:(BOOL)forceFlip;

- (CGFloat)getSellerInfoYPosition;

- (void)addVariationsTarget:(id)target action:(SEL)action;

- (void)addSizeTarget:(id)target action:(SEL)action;

- (void)addReviewsTarget:(id)target action:(SEL)action;

- (void)addSellerCatalogTarget:(id)target action:(SEL)action;

- (void)addSellerLinkTarget:(id)target action:(SEL)action;

- (void)addSellerReviewsTarget:(id)target action:(SEL)action;

- (void)addOtherOffersTarget:(id)target action:(SEL)action;

- (void)addSpecificationsTarget:(id)target action:(SEL)action;

- (void)addDescriptionTarget:(id)target action:(SEL)action;

@end
