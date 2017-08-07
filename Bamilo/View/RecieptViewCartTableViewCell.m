//
//  RecieptViewCartTableViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "RecieptViewCartTableViewCell.h"

@interface RecieptViewCartTableViewCell()
@property (weak, nonatomic) IBOutlet CartEntitySummaryViewControl *summeryView;
@end

@implementation RecieptViewCartTableViewCell

const CGFloat cellBottomPadding = 10;
const CGFloat summeryViewHeight = 45;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView setBackgroundColor:[Theme color:kColorVeryLightGray]];
}

- (void)updateWithModel:(id)model {
    if(![model isKindOfClass:CartEntity.class]) {
        return;
    }
    [self.summeryView updateWithModel:model];
    NSMutableArray *receiptViewItems = [NSMutableArray arrayWithArray:@[
                                                                        [ReceiptItemModel withName:@"جمع کل:"
                                                                                             value: [((CartEntity *)model).cartUnreducedValueFormatted numbersToPersian]],
                                                                        [ReceiptItemModel withName:@"تخفیف کالاها:"
                                                                                             value:[((CartEntity *)model).onlyProductsDiscountFormated numbersToPersian]]
                                                                        ]];

    [((CartEntity *)model).priceRules enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [receiptViewItems addObject:[ReceiptItemModel withName:[(NSString *)key numbersToPersian] value:[(NSString *)obj numbersToPersian]]];
    }];
    
    if (((CartEntity *)model).couponCode) {
        [receiptViewItems addObject:[ReceiptItemModel withName:STRING_COUPON value:((CartEntity *)model).couponMoneyValueFormatted]];
    }
    
    if(((CartEntity *)model).shippingValue.intValue > 0) {
        [receiptViewItems addObject:[ReceiptItemModel withName:STRING_SHIPPING_COST value:((CartEntity *)model).shippingValueFormatted]];
    }
    
    [super updateWithModel:receiptViewItems];
}


+ (CGFloat)cellHeightByModel:(CartEntity *)cartEntity {
    int reciptItemViewCount = (int)((cartEntity.priceRules.allKeys.count) + (cartEntity.couponCode.length > 0) + (cartEntity.shippingValue.intValue > 0) + 2);
    return ([ReceiptItemView cellHeight] * reciptItemViewCount) + summeryViewHeight + cellBottomPadding;
}

+ (NSString *)nibName {
    return @"RecieptViewCartTableViewCell";
}

- (void)layoutSubviews {
    self.summeryView.backgroundColor = [UIColor whiteColor];
    [self.summeryView applyColor:[Theme color:kColorGreen]];
}

@end
