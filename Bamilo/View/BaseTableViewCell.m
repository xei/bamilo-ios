//
//  BaseTableViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark - Public Methods
+(CGFloat)cellHeight {
    return 0;
}

+ (NSString *)nibName {
    return NSStringFromClass(self);
}

- (void)updateWithModel:(id)model {
    return;
}

@end
