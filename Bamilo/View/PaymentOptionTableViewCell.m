//
//  PaymentOptionTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PaymentOptionTableViewCell.h"
#import "UIImageView+WebCache.h"

@interface PaymentOptionTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *paymentOptionLogoView;
@property (weak, nonatomic) IBOutlet UIView *paymentOptionContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *paymentOptionView;
@property (weak, nonatomic) IBOutlet UILabel *paymentDescLabel;
@end

@implementation PaymentOptionTableViewCellModel
@end

@implementation PaymentOptionTableViewCell {
@private
    PaymentOptionTableViewCellModel *_model;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.paymentOptionContainerView.backgroundColor = cEXTRA_LIGHT_GRAY_COLOR;
    
    self.paymentOptionView.backgroundColor = [UIColor whiteColor];
    
    [self.paymentDescLabel applyStyle:kFontRegularName fontSize:12.0f color:cDARK_GRAY_COLOR];
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return @"PaymentOptionTableViewCell";
}

- (void)updateWithModel:(id)model {
    PaymentOptionTableViewCellModel *paymentOptionTableViewCellModel = (PaymentOptionTableViewCellModel *)model;
    
    if(paymentOptionTableViewCellModel.logoImageUrl == nil) {
        [self.paymentOptionView setHidden:YES];
    } else {
        [self.paymentOptionView setHidden:NO];
        [self.paymentOptionView sd_setImageWithURL:[NSURL URLWithString:paymentOptionTableViewCellModel.logoImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.paymentOptionView.image = image;
        }];
    }

    self.paymentDescLabel.text = paymentOptionTableViewCellModel.isSelected ? paymentOptionTableViewCellModel.descText : nil;
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
