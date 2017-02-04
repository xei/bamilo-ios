//
//  PlainTableViewHeaderCell.m
//  Jumia
//
//  Created by aliunco on 1/16/17.
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
    self.contentView.backgroundColor = [UIColor withRGBA:244 green:244 blue:244 alpha:1.0f];
    
    //Title Label Setup
    [self.titleLabel applyStyle:kFontBoldName fontSize:12 color:[UIColor withRGBA:80 green:80 blue:80 alpha:1.0f]];
}

-(void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

+(NSString *)nibName {
    return @"PlainTableViewHeaderCell";
}

@end
