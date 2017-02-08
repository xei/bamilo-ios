//
//  ReceiptItemView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ReceiptItemView.h"
#import "ReceiptItemModel.h"

#define cDARK_GRAY_COLOR [UIColor withRGBA:115 green:115 blue:115 alpha:1.0f]

@interface ReceiptItemView()
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemCurrencyLabel;
@end

@implementation ReceiptItemView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self.itemNameLabel applyStyle:kFontRegularName fontSize:11.0f color:cDARK_GRAY_COLOR];
    [self.itemPriceLabel applyStyle:kFontRegularName fontSize:11.0f color:cDARK_GRAY_COLOR];
    [self.itemCurrencyLabel applyStyle:kFontRegularName fontSize:11.0f color:cDARK_GRAY_COLOR];
}

#pragma mark - Overrides
+(CGFloat)cellHeight {
    return 30.0f;
}

+(NSString *)nibName {
    return @"ReceiptItemView";
}

-(void)updateWithModel:(id)model {
    ReceiptItemModel *receiptItemModel = (ReceiptItemModel *)model;
    
    self.itemNameLabel.text = receiptItemModel.itemName;
    self.itemPriceLabel.text = receiptItemModel.itemPrice;
    self.itemCurrencyLabel.text = receiptItemModel.itemCurrency;
}

@end
