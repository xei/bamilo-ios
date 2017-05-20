//
//  OrderProductListTableViewCell.h
//  Bamilo
//
//  Created by Ali Saeedifar on 3/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "OrderProduct.h"

@protocol OrderProductListTableViewCellDelegate
- (void)needsToShowProductReviewForProduct:(OrderProduct *)product;
@end

@interface OrderProductListTableViewCell : BaseTableViewCell
@property (nonatomic, weak) id<OrderProductListTableViewCellDelegate>delegate;
@end
