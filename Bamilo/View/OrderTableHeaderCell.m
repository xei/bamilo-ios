//
//  OrderTableHeaderCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderTableHeaderCell.h"

@implementation OrderTableHeaderCell

- (void)updateWithModel:(id)model {
    if (![model isKindOfClass:[Order class]]) {
        return;
    }
    Order *order = model;
    self.titleString = [[NSString stringWithFormat:@"%@ %@", STRING_ORDER_ID ,order.orderId] numbersToPersian];
    self.leftTitleString = [order.creationDate numbersToPersian];
}

+ (CGFloat)cellHeight {
    return 30.0f;
}

@end
