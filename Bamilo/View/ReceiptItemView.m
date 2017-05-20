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
    
    [self.itemNameLabel applyStyle:[Theme font:kFontVariationRegular size:11] color:[Theme color:kColorDarkGray]];
    [self.itemPriceLabel applyStyle:[Theme font:kFontVariationRegular size:11] color:[Theme color:kColorDarkGray]];
    [self.itemCurrencyLabel applyStyle:[Theme font:kFontVariationRegular size:11] color:[Theme color:kColorDarkGray]];
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
    self.itemPriceLabel.text = receiptItemModel.itemValue;
    
    if(receiptItemModel.color) {
        [self applyColor:receiptItemModel.color];
    }
}

@end
