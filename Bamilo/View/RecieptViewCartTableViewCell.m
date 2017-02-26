//
//  RecieptViewCartTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "RecieptViewCartTableViewCell.h"

@interface RecieptViewCartTableViewCell()
@property (weak, nonatomic) IBOutlet CartEntitySummaryViewControl *summeryView;
@end

@implementation RecieptViewCartTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView setBackgroundColor:[UIColor withHexString:@"EEF2F6"]];
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
        [receiptViewItems insertObject:[ReceiptItemModel withName:[(NSString *)key numbersToPersian]
                                                            value:[(NSString *)obj numbersToPersian]] atIndex: receiptViewItems.count];
    }];
    [super updateWithModel:receiptViewItems];
}


+ (CGFloat)cellHeightByModel:(CartEntity *)cartEntity {
    return ([ReceiptItemView cellHeight] * ((cartEntity.priceRules.allKeys.count) + 2)) + 45 + 10;
}

+ (NSString *)nibName {
    return @"RecieptViewCartTableViewCell";
}

- (void)layoutSubviews {
    self.summeryView.backgroundColor = [UIColor whiteColor];
    [self.summeryView applyColor:cGREEN_COLOR];
}

@end
