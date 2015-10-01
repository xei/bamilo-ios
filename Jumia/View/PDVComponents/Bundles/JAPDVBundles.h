//
//  JAPDVBundles.h
//  Jumia
//
//  Created by epacheco on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProduct.h"
#import "JAPDVBundleSingleItem.h"

@interface JAPDVBundles : UIView

@property (nonatomic) NSString *headerText;
@property (nonatomic) RIProduct *product;

- (instancetype)initWithFrame:(CGRect)frame withSize:(BOOL)withSize;
- (void)addBundleItemView:(JAPDVBundleSingleItem *)itemView;

@end
