    //
//  PlainTableViewHeaderCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PlainTableViewHeaderCell.h"

@interface PlainTableViewHeaderCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation PlainTableViewHeaderCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    //Content View Setup
    self.contentView.backgroundColor = [UIColor withRepeatingRGBA:244 alpha:1.0f];
    
    //Title Label Setup
    [self.titleLabel applyStyle:kFontBoldName fontSize:12 color:[UIColor withRepeatingRGBA:80 alpha:1.0f]];
}

- (void)setTitleString:(NSString *)titleString {
    self.titleLabel.text = titleString;
    _titleString = titleString;
}

#pragma mark - Overrides
+ (CGFloat)cellHeight {
    return 40.0f;
}

+ (NSString *)nibName {
    return @"PlainTableViewHeaderCell";
}

@end
