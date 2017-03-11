//
//  InputTextField.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "InputTextField.h"
#import "UITextField+Extensions.h"

#define cICON_RIGHT_MARGIN 8

@interface InputTextField()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconVisibleConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *dropDownIcon;
@property (weak, nonatomic) IBOutlet UILabel *errorMsg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorMsgTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *seperatorBorderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconTrailingConstraint;
@end

@implementation InputTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setUpView];
    
    self.errorMsg.text = nil;
    self.textField.spellCheckingType =  UITextSpellCheckingTypeNo;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
}

- (void)setUpView {
    //Set Default style
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes: @{NSForegroundColorAttributeName: [Theme color: kColorDarkGray]}];
    self.textField.attributedPlaceholder = attributedPlaceholder;
    [self.textField applyStyle:[Theme font:kFontVariationRegular size:12] color:[Theme color:kColorExtraDarkGray]];
    [self.dropDownIcon setHidden:YES];
    
    [self clearError];
    [self updateIconAppearance:YES];
    self.seperatorBorderView.backgroundColor = [Theme color:kColorDarkGray];
}

-(void)setHasIcon:(BOOL)hasIcon {
    [self updateIconAppearance:(hasIcon == NO)];
    _hasIcon = hasIcon;
}

#pragma mark - Public Methods
- (void)showErrorMsg:(NSString *)errorMsg {
    if (!errorMsg){
        return;
    }
    
    self.errorMsg.text = errorMsg;
    self.seperatorBorderView.backgroundColor = [Theme color:kColorRed];
    self.textField.textColor = [Theme color:kColorRed];
    [UIView animateWithDuration:0.15 animations:^{
        self.errorMsgTopConstraint.constant = 0;
        [self layoutIfNeeded];
    }];
}

- (void)clearError {
    self.errorMsg.text = nil;
    self.seperatorBorderView.backgroundColor = [Theme color:kColorDarkGray];
    self.textField.textColor = [Theme color:kColorExtraDarkGray];
    self.errorMsgTopConstraint.constant = -15;
}

-(void) updateDropDownAppearance:(BOOL)isHidden {
    [self.dropDownIcon setHidden:isHidden];
}

#pragma mark - Helpers
-(void) updateIconAppearance:(BOOL)isHidden {
    if(isHidden) {
        self.iconTrailingConstraint.constant = -1 * (2 * cICON_RIGHT_MARGIN);
    } else {
        self.iconTrailingConstraint.constant = cICON_RIGHT_MARGIN;
    }
}

@end
