//
//  CartTableViewCell.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "RICartItem.h"
#import "RICart.h"
#import "CartTableViewCellDelegate.h"


@interface CartTableViewCell : BaseTableViewCell

@property (strong, nonatomic) RICartItem *cartItem;
@property (weak, nonatomic) id<CartTableViewCellDelegate> delegate;

- (void)quantityChangeTo:(int)newQuantity;

@end
