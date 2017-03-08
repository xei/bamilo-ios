//
//  OrderDetailInformationTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 3/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "OrderDetailInformationTableViewCell.h"

@interface OrderDetailInformationTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@end

@implementation OrderDetailInformationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.titleLabel applyStyle:kFontRegularName fontSize:10 color:cDARK_GRAY_COLOR];
    [self.valueLabel applyStyle:kFontRegularName fontSize:10 color:cDARK_GRAY_COLOR];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    _title = title;
}

- (void)setValue:(NSString *)value {
    self.valueLabel.text = value;
    _value = value;
}

- (void)prepareForReuse {
    self.value = nil;
    self.title = nil;
}

@end
