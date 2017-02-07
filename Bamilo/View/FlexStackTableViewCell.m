//
//  FlexStackTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FlexStackTableViewCell.h"

@interface FlexStackTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *upperView;
@property (weak, nonatomic) IBOutlet UIView *lowerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *boldSeparatorHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *boldSeparatorBottomConstraint;

@end

@implementation FlexStackTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.options = NONE;
}

-(void)setOptions:(FlexStackViewOptions)options {
    switch (options) {
        case BOLD_SEPARATOR:
            self.boldSeparatorHeightConstraint.constant = 2;
            self.boldSeparatorBottomConstraint.constant = 0;
        break;
            
        case SHADOW:
            self.boldSeparatorHeightConstraint.constant = 1;
            self.boldSeparatorBottomConstraint.constant = 5;
        break;
            
        default:
            self.boldSeparatorHeightConstraint.constant = 0;
            self.boldSeparatorBottomConstraint.constant = 0;
        break;
    }
    
    _options = options;
}

#pragma mark - Public Methos
-(void)setUpperViewTo:(UIView *)upperView {
    [self.upperView addSubview:upperView];
    [self.upperView anchorMatch:upperView];
    self.upperViewHeightConstraint.constant = upperView.frame.size.height;
}

-(void)setLowerViewTo:(UIView *)lowerView {
    [self.lowerView addSubview:lowerView];
    [self.lowerView anchorMatch:lowerView];
    self.lowerViewHeightConstraint.constant = lowerView.frame.size.height;
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return @"FlexStackTableViewCell";
}

@end
