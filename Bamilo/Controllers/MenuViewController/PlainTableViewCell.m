//
//  PlainTableViewCell.m
//  Bamilo
//
//  Created by Ali Saeedifar on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PlainTableViewCell.h"

@interface PlainTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *arrorwUIImage;

@end

@implementation PlainTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self.titleLabel applyStyle:kFontRegularName fontSize:11.0f color:[UIColor withRepeatingRGBA:80 alpha:1.0f]];
    
    self.arrorwUIImage.image = [self.arrorwUIImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.arrorwUIImage.tintColor = [Theme color:kColorGray5];
}

+ (CGFloat)heightSize {
    return 50;
}

#pragma mark - Overrides
+ (NSString *) nibName {
    return @"PlainTableViewCell";
}

@end
