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

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize;

- (void)addSizeTarget:(id)target action:(SEL)action;

- (void)addReviewsTarget:(id)target action:(SEL)action;

- (void)addSellerReviewsTarget:(id)target action:(SEL)action;

- (void)addOtherOffersTarget:(id)target action:(SEL)action;

- (void)addSpecificationsTarget:(id)target action:(SEL)action;

@end
