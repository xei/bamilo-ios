//
//  RecieptViewCartTableViewCell.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReceiptView.h"
#import "CartEntitySummeryViewControl.h"

@interface RecieptViewCartTableViewCell : ReceiptView
+ (CGFloat)cellHeightByModel:(CartEntity *)cartEntity;
@end
