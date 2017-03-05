//
//  OrderListTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderListTableViewCell.h"
#import "Order.h"

@interface OrderListTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@end

@implementation OrderListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.priceLabel applyStyle:kFontRegularName fontSize:11 color:cLIGHT_GRAY_COLOR];
}

- (void)updateWithModel:(id)model {
    if (![model isKindOfClass:[Order class]]) {
        return;
    }
    self.priceLabel.text = [NSString stringWithFormat:@"%@ %@", STRING_TOTAL_COST, ((Order *)model).formatedPrice];
}

@end
