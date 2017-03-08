//
//  OrderListTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
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
    
    [self.priceLabel applyStyle:kFontRegularName fontSize:11 color:cLIGHT_GRAY_COLOR];
    [self.orderNumLabel applyStyle:kFontRegularName fontSize:11 color:cLIGHT_GRAY_COLOR];
    [self.orderDateLabel applyStyle:kFontRegularName fontSize:11 color:cEXTRA_DARK_GRAY_COLOR];
}

- (void)updateWithModel:(id)model {
    if (![model isKindOfClass:[Order class]]) {
        return;
    }
    self.priceLabel.text = [NSString stringWithFormat:@"%@: %@", STRING_TOTAL_COST, ((Order *)model).formattedPrice];
    
    self.order = model;
    self.orderNumLabel.text = [[NSString stringWithFormat:@"%@: %@", STRING_ORDER_ID ,self.order.orderId] numbersToPersian];
    NSString *dateString = [[self.order.creationDate convertToJalali] numbersToPersian];
    self.orderDateLabel.text = [NSString stringWithFormat:@"%@ %@", STRING_ORDER_DATE, dateString];
}

- (IBAction)stateButtonTapped:(id)sender {
    [self.delegate stateButtonTappedForOrder:self.order byCell:self];
}


- (void)prepareForReuse {
    self.priceLabel.text = nil;
    self.orderDateLabel.text = nil;
    self.orderNumLabel.text = nil;
}

@end
