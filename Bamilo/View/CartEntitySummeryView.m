//
//  CartEntitySummeryView.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/15/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartEntitySummeryView.h"
#define cGRAY_COLOR [UIColor withRepeatingRGBA:217 alpha:1.0f]

@interface CartEntitySummeryView()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation CartEntitySummeryView


- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = cGRAY_COLOR;
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
    [self.delegate cartEntitySummeryTapped:self];
}

@end
