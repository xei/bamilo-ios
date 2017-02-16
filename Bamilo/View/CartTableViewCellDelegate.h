//
//  CartTableViewCellDelegate.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RICart.h"

@protocol CartTableViewCellDelegate <NSObject>
@optional - (void)quantityWillChangeTo:(int)newValue withCell:(id)cartCell;
@optional - (void)quantityHasBeenChangedTo:(int)newValue withNewCart:(RICart *)cart withCell:(id)cartCell;
@optional - (void)quantityHasBeenChangedTo:(int)newValue withErrorMessages:(NSArray *)errorMsgs withCell:(id)cartCell;
@optional - (void)wantsToRemoveCartItem:(RICartItem *)cartItem byCell:(id)cartCell;
@optional - (void)wantsToLikeCartItem:(RICartItem *)cartItem byCell:(id)cartCell;
@end
