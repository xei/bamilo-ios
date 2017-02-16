//
//  ReceiptItemView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ReceiptItemView.h"
#import "ReceiptItemModel.h"

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

-(void)applyColor:(UIColor *)color {
    [self.itemNameLabel applyStyle:self.itemNameLabel.font.fontName fontSize:self.itemNameLabel.font.pointSize color:color];
    [self.itemPriceLabel applyStyle:self.itemPriceLabel.font.fontName fontSize:self.itemPriceLabel.font.pointSize color:color];
    [self.itemCurrencyLabel applyStyle:self.itemCurrencyLabel.font.fontName fontSize:self.itemCurrencyLabel.font.pointSize color:color];
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
