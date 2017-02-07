//
//  PlainTableViewCell.m
//  Bamilo
//
//  Created by Ali saiedifar on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PlainTableViewCell.h"

@implementation PlainTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self.titleLabel applyStyle:kFontRegularName fontSize:11.0f color:[UIColor blackColor]];
}

+ (CGFloat)heightSize {
    return 50;
}

#pragma mark - Overrides
+ (NSString *) nibName {
    return @"PlainTableViewCell";
}

@end
