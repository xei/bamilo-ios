//
//  InputTextField.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "InputTextField.h"

#define cPLACEHOLDER_COLOR [UIColor withHexString:@"757575"]
#define cINPUT_TINT_COLOR [UIColor withHexString:@"3D3D3D"]
#define cRED_ERROR_COLOR [UIColor withHexString:@"FF6666"]
#define cDARK_GRAY_COLOR [UIColor withRGBA:115 green:115 blue:115 alpha:1.0f]

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
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes: @{NSForegroundColorAttributeName: cPLACEHOLDER_COLOR}];
    self.textField.attributedPlaceholder = attributedPlaceholder;
    self.textField.textColor = cINPUT_TINT_COLOR;
    self.textField.font = [UIFont fontWithName:kFontRegularName size:12];
    [self.dropDownIcon setHidden:YES];
    
    [self clearError];
    [self updateIconAppearance:YES];
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
    self.seperatorBorderView.backgroundColor = cRED_ERROR_COLOR;
    self.textField.textColor = cRED_ERROR_COLOR;
    [UIView animateWithDuration:0.15 animations:^{
        self.errorMsgTopConstraint.constant = 0;
        [self layoutIfNeeded];
    }];
}

- (void)clearError {
    self.errorMsg.text = nil;
    self.seperatorBorderView.backgroundColor = cDARK_GRAY_COLOR;
    self.textField.textColor = cINPUT_TINT_COLOR;
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
