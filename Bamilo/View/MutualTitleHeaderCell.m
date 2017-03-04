//
//  MutualTitleHeaderCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "MutualTitleHeaderCell.h"

@interface MutualTitleHeaderCell()
@property (nonatomic, weak) IBOutlet UILabel *leftTitleLabel;
@end

@implementation MutualTitleHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.leftTitleLabel applyStyle:kFontBoldName fontSize:12 color:cEXTRA_DARK_GRAY_COLOR];
}


- (void)setLeftTitleString:(NSString *)leftTitleString {
    self.leftTitleLabel.text = leftTitleString;
    _leftTitleString = leftTitleString;
}

- (void)setLeftTitleAtributedString:(NSAttributedString *)leftTitleAtributedString {
    self.leftTitleLabel.attributedText = leftTitleAtributedString;
    _leftTitleAtributedString = leftTitleAtributedString;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.leftTitleLabel.text = nil;
    self.leftTitleLabel.attributedText = nil;
}

@end
