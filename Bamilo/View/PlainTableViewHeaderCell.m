    //
//  PlainTableViewHeaderCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PlainTableViewHeaderCell.h"

@interface PlainTableViewHeaderCell()
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation PlainTableViewHeaderCell

-(void)awakeFromNib {
    [super awakeFromNib];
    self.container.backgroundColor = [Theme color:kColorGray10]; //[UIColor withRepeatingRGBA:244 alpha:1.0f];
    //Title Label Setup
    [self.titleLabel applyStyle:kFontBoldName fontSize:12 color: [Theme color:kColorExtraDarkGray]];//[UIColor withRepeatingRGBA:80 alpha:1.0f]];
}

- (void)setTitleString:(NSString *)titleString {
    self.titleLabel.text = titleString;
    _titleString = titleString;
}

- (void)applyStyle: (UIFont *)font color: (UIColor *)color {
    [self.titleLabel applyStyle:font color:color];
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return NSStringFromClass([self class]);
}

+ (CGFloat)cellHeight {
    return 40.0f;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    self.titleLabel.attributedText = nil;
}

@end
