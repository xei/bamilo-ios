//
//  JACartProductsView.h
//  Jumia
//
//  Created by Jose Mota on 11/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RICart.h"
#import "RICartItem.h"

@protocol JACartProductsProtocol <NSObject>

- (void)removeCartItem:(RICartItem *)cartItem;
- (void)quantitySelection:(RICartItem *)cartItem;

@end

@interface JACartProductsView : UIView

@property (strong, nonatomic) RICart *cart;
@property (strong, nonatomic) id<JACartProductsProtocol> delegate;

- (CGFloat)maxHeight;

@end
