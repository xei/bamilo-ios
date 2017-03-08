//
//  OrderListTableViewCell.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "Order.h"

@protocol OrderListTableViewCellDelegate
- (void)stateButtonTappedForOrder:(Order *)order byCell:id;
@end

@interface OrderListTableViewCell : BaseTableViewCell

@property (weak, nonatomic) id<OrderListTableViewCellDelegate> delegate;
@end
