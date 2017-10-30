//
//  OrderListTableViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderListTableViewCell.h"
#import "NSDate+Extensions.h"

@interface OrderListTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) Order *order;
@end

@implementation OrderListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.priceLabel applyStyle:[Theme font:kFontVariationBold size:11.0f] color:[Theme color:kColorGreen1]];
    [self.orderNumLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorGray5]];
    [self.orderDateLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorGray5]];
}

- (void)updateWithModel:(id)model {
    if (![model isKindOfClass:[Order class]]) {
        return;
    }
    self.priceLabel.text = [NSString stringWithFormat:@"%@: %@", STRING_TOTAL_COST, ((Order *)model).formattedPrice ?: STRING_ZERO_COST];
    
    self.order = model;
    self.orderNumLabel.text = [[NSString stringWithFormat:@"%@: %@", STRING_ORDER_ID ,self.order.orderId] numbersToPersian];
    NSString *dateString = [[self.order.creationDate convertToJalali] numbersToPersian];
    self.orderDateLabel.text = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_DATE, dateString];
}


- (void)prepareForReuse {
    self.priceLabel.text = nil;
    self.orderDateLabel.text = nil;
    self.orderNumLabel.text = nil;
}

@end
