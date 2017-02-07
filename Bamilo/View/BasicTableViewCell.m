//
//  BasicTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BasicTableViewCell.h"

@implementation BasicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.titleLabel applyStyle:kFontRegularName fontSize:12 color:[UIColor withRepeatingRGBA:115 alpha:1.0]];
}

#pragma mark - Overrides
+ (NSString *) nibName {
    return @"BasicTableViewCell";
}

@end
