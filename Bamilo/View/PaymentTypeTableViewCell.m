//
//  PaymentTypeTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PaymentTypeTableViewCell.h"

@implementation PaymentTypeTableViewCellModel
@end

@interface PaymentTypeTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet RadioButtonViewControl *radioButtonViewControl;
@end

@implementation PaymentTypeTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[Theme color:kColorDarkGray]];
}

#pragma mark - Overrides
+(CGFloat)cellHeight {
    return 40.0f;
}

+ (NSString *)nibName {
    return @"PaymentTypeTableViewCell";
}

- (void)updateWithModel:(id)model {
    PaymentTypeTableViewCellModel *paymentTypeTableViewCellModel = (PaymentTypeTableViewCellModel *)model;
    
    if(paymentTypeTableViewCellModel) {
        self.titleLabel.text = paymentTypeTableViewCellModel.title;
        self.radioButtonViewControl.delegate = self;
        [self.radioButtonViewControl setIsSelected:paymentTypeTableViewCellModel.isSelected];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self didSelectRadioButton:self];
}

#pragma mark - RadioButtonViewControlDelegate
-(void)didSelectRadioButton:(id)button {
    [self.delegate didSelectRadioButton:self];
}

@end
