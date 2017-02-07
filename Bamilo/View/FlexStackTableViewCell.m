//
//  FlexStackTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "FlexStackTableViewCell.h"

#define kUPPER_VIEW_TAG 9001
#define kLOWER_VIEW_TAG 9002

@interface FlexStackTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *upperView;
@property (weak, nonatomic) IBOutlet UIView *lowerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *upperViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *boldSeparatorHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *boldSeparatorBottomConstraint;

@end

@implementation FlexStackTableViewCell {
@private
    CGFloat upperViewFrameHeight, lowerViewFrameHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.options = NONE;
    
    self.contentView.userInteractionEnabled = NO;
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
    upperView.tag = kUPPER_VIEW_TAG;
    [self.upperView addSubview:upperView];
    [self.upperView anchorMatch:upperView];
    upperViewFrameHeight = self.upperViewHeightConstraint.constant = upperView.frame.size.height;
}

-(void)setLowerViewTo:(UIView *)lowerView {
    lowerView.tag = kLOWER_VIEW_TAG;
    [self.lowerView addSubview:lowerView];
    [self.lowerView anchorMatch:lowerView];
    lowerViewFrameHeight = self.lowerViewHeightConstraint.constant = lowerView.frame.size.height;
}

-(void) update:(FlexStackViews)view set:(BOOL)visible animated:(BOOL)animated {
    switch (view) {
        case UPPER_VIEW: {
            [self updateHeightConstraint:self.upperViewHeightConstraint to:visible ? upperViewFrameHeight : 0 animated:animated];
        }
        break;
        
        case LOWER_VIEW: {
            [self updateHeightConstraint:self.lowerViewHeightConstraint to:visible ? lowerViewFrameHeight : 0 animated:animated];
        }
        break;
    }
}

#pragma mark - Overrides
+ (NSString *)nibName {
    return @"FlexStackTableViewCell";
}

#pragma mark - Helpers
-(void) updateHeightConstraint:(NSLayoutConstraint *)constraint to:(CGFloat)constant animated:(BOOL)animated {
    if(animated) {
        [UIView animateWithDuration:0.2 animations:^{
            constraint.constant = constant;
            [self layoutIfNeeded];
        }];
    } else {
        constraint.constant = constant;
    }
}

@end
