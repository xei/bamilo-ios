//
//  PaymentOptionTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PaymentOptionTableViewCell.h"

@implementation PaymentOptionTableViewCellModel
@end

@interface PaymentOptionTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *paymentDescLabel;
@end

@implementation PaymentOptionTableViewCell  {
@private
    PaymentOptionTableViewCellModel *_model;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    [self.paymentDescLabel applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorDarkGray]];
}

#pragma mark - Overrides
-(void)updateWithModel:(id)model {
    PaymentOptionTableViewCellModel *paymentOptionTableViewCellModel = (PaymentOptionTableViewCellModel *)model;
    self.paymentDescLabel.text = paymentOptionTableViewCellModel.isSelected ? paymentOptionTableViewCellModel.descText : nil;
    _model = model;
}

+ (NSString *)nibName {
    return @"PaymentOptionTableViewCell";
}

#pragma mark - RadioButtonViewProtocol
-(void)update:(BOOL)isSelected {
    [self updateAppearance:isSelected];
}

#pragma mark - Helpers
-(void) updateAppearance:(BOOL)isSelected {
    self.paymentDescLabel.text = isSelected ? _model.descText : nil;
}

@end
