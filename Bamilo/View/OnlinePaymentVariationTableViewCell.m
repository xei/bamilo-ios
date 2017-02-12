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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.paymentOptionContainerView.layer.cornerRadius = 5.0f;
    self.paymentOptionContainerView.layer.masksToBounds = YES;
    
    self.paymentOptionButton.backgroundColor = [UIColor whiteColor];
    self.paymentOptionButton.adjustsImageWhenHighlighted = NO;
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
        [self.paymentOptionButton setImage:[UIImage imageNamed:cellModel.imageName] forState:UIControlStateNormal];
        [self updateButtonAppearance:cellModel.isSelected];
    }
}

- (IBAction)optionButtonTapped:(id)sender {
    [self.delegate didSelectRadioButton:self];
}

#pragma mark - RadioButtonViewProtocol
-(void)update:(BOOL)isSelected {
    [self updateButtonAppearance:isSelected];
}

#pragma mark - Helpers
-(void) updateButtonAppearance:(BOOL)isSelected {
    self.paymentOptionContainerView.backgroundColor = isSelected ? cCOLOR_ORANGE : cEXTRA_LIGHT_GRAY_COLOR;
}

@end
