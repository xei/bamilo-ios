//
//  CartEntitySummaryView.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartEntitySummaryView.h"


@interface CartEntitySummaryView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation CartEntitySummaryView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [Theme color:kColorGray];
}

- (void)setCartEntity:(CartEntity *)cartEntity {
    if (cartEntity == nil) {
        return;
    }
    self.priceLabel.text = cartEntity.cartValueFormatted;
    self.titleLabel.text = [[NSString stringWithFormat:@"جمع نهایی‌(%d کالا)", cartEntity.cartCount.intValue] numbersToPersian];
    _cartEntity = cartEntity;
}

- (IBAction)viewTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cartEntitySummeryTapped:)]) {
        [self.delegate cartEntitySummeryTapped:self];
    }
}

- (void)applyColor:(UIColor *)color {
    self.titleLabel.textColor = color;
    self.priceLabel.textColor = color;
}

@end
