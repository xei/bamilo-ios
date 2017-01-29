//
//  PlainTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PlainTableViewCell.h"

@interface PlainTableViewCell()
    @property (nonatomic, weak) IBOutlet UILabel* titleUILabel;
@end

@implementation PlainTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.titleUILabel setFont: [UIFont fontWithName:kFontRegularName size:12]];
}

+ (NSString *) nibName {
    return @"PlainTableViewCell";
}

+ (CGFloat)heightSize {
    return 50;
}

- (void)setTitle:(NSString *)title {
    self.titleUILabel.text = title;
}

@end
