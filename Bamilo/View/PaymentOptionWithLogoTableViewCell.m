//
//  PaymentOptionWithLogoTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PaymentOptionWithLogoTableViewCell.h"
#import "UIImageView+WebCache.h"

@implementation PaymentOptionWithLogoTableViewCellModel
@end

@interface PaymentOptionWithLogoTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *paymentOptionContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *paymentOptionView;
@end

@implementation PaymentOptionWithLogoTableViewCell {
@private
    PaymentOptionWithLogoTableViewCellModel *_model;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.paymentOptionContainerView.backgroundColor = self.paymentOptionView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return @"PaymentOptionWithLogoTableViewCell";
}

- (void)updateWithModel:(id)model {
    [super updateWithModel:model];
    
    PaymentOptionWithLogoTableViewCellModel *paymentOptionTableViewCellModel = (PaymentOptionWithLogoTableViewCellModel *)model;
    
    if(paymentOptionTableViewCellModel.logoImageUrl == nil) {
        [self.paymentOptionView setHidden:YES];
    } else {
        [self.paymentOptionView setHidden:NO];
        [self.paymentOptionView sd_setImageWithURL:[NSURL URLWithString:paymentOptionTableViewCellModel.logoImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            self.paymentOptionView.image = image;
        }];
    }
    
    _model = model;
}

@end
