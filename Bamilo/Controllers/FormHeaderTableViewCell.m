//
//  FormHeaderTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FormHeaderTableViewCell.h"

@interface FormHeaderTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation FormHeaderTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.containerView.backgroundColor = [UIColor withRepeatingRGBA:244 alpha:1.0f];
    [self.titleLabel applyStyle:kFontBoldName fontSize:12 color:[UIColor withRepeatingRGBA:80 alpha:1.0f]];
}

-(void)setTitleString:(NSString *)titleString {
    self.titleLabel.text = titleString;
    _titleString = titleString;
}

#pragma mark - Overrides
+(CGFloat)cellHeight {
    return 56.0f;
}

+(NSString *)nibName {
    return @"FormHeaderTableViewCell";
}

@end
