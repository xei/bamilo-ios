//
//  OnlinePaymentVariationTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OnlinePaymentVariationTableViewCell.h"

#define cCOLOR_ORANGE [UIColor withRGBA:247 green:151 blue:32 alpha:1.0f]

@implementation OnlinePaymentVariationTableViewCellModel
@end

@interface OnlinePaymentVariationTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *paymentOptionContainerView;
@property (weak, nonatomic) IBOutlet UIButton *paymentOptionButton;
@end

@implementation OnlinePaymentVariationTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.paymentOptionContainerView.layer.cornerRadius = 5.0f;
    self.paymentOptionContainerView.layer.masksToBounds = YES;
    
    self.paymentOptionButton.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Overrides
+(CGFloat)cellHeight {
    return 50.0f;
}

+ (NSString *)nibName {
    return @"OnlinePaymentVariationTableViewCell";
}

-(void)updateWithModel:(id)model {
    OnlinePaymentVariationTableViewCellModel *cellModel = (OnlinePaymentVariationTableViewCellModel *)model;
    if(cellModel) {
        self.paymentOptionContainerView.backgroundColor = cellModel.isSelected ? cCOLOR_ORANGE : cLIGHT_GRAY_COLOR;
        [self.paymentOptionButton setImage:[UIImage imageNamed:cellModel.imageName] forState:UIControlStateNormal];
    }
}

@end
