//
//  DiscountCodeView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DiscountCodeView.h"

@interface DiscountCodeView() <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *discountCodeTextFieldContainerView;
@property (weak, nonatomic) IBOutlet UITextField *discountCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *discountApplyButton;
@property (weak, nonatomic) IBOutlet UIButton *discountRemoveButton;
@end

@implementation DiscountCodeView {
@private
    NSString *_verifiedCode;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    //Initial Setup
    self.discountCodeTextFieldContainerView.backgroundColor = [UIColor clearColor];
    self.discountCodeTextFieldContainerView.layer.borderColor = cLIGHT_GRAY_COLOR.CGColor;
    self.discountCodeTextFieldContainerView.layer.borderWidth = 1.0f;
    
    self.discountCodeTextField.placeholder = STRING_ENTER_YOUR_DISCOUNT_CODE;
    self.discountCodeTextField.delegate = self;
    
    [self.discountApplyButton applyStyle:kFontRegularName fontSize:12.0f color:cDARK_GRAY_COLOR];
    self.discountApplyButton.titleLabel.text = STRING_APPLY_DISCOUNT;
    [self.discountApplyButton setEnabled:NO];
    
    [self.discountRemoveButton applyStyle:kFontRegularName fontSize:12.0f color:cDARK_GRAY_COLOR];
    self.discountRemoveButton.titleLabel.text = STRING_REMOVE_DISCOUNT;
    
    [self updateAppearanceForState:DISCOUNT_CODE_VIEW_STATE_CLEAN];
}

-(void)setState:(DiscountCodeViewState)state {
    [self updateAppearanceForState:state];
    _state = state;
}

-(void)clearOut {
    self.discountCodeTextField.text = @"";  
    [self updateAppearanceForState:DISCOUNT_CODE_VIEW_STATE_CLEAN];
}

#pragma mark - Overrides
+(NSString *)nibName {
    return @"DiscountCodeView";
}

-(void)updateWithModel:(id)model {
    NSString *couponCode = (NSString *)model;
    
    if(couponCode == nil) {
        [self clearOut];
    } else {
        self.discountCodeTextField.text = couponCode;
        [self updateAppearanceForState:DISCOUNT_CODE_VIEW_STATE_CONTAINS_CODE];
    }
}

- (IBAction)applyDiscountButtonTapped:(id)sender {
    [self.discountCodeTextField resignFirstResponder];
    [self.delegate discountCodeViewDidFinish:self withCode:self.discountCodeTextField.text];
}

- (IBAction)removeDiscountButtonTapped:(id)sender {
    [self.delegate discountCodeViewRemoveCodeButtonTapped:self];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self updateAppearanceForState:DISCOUNT_CODE_VIEW_STATE_ACTIVE];
    
    return YES;
}

/*-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    
    if(newText.length > 0) {
        [self updateAppearanceForState:DISCOUNT_CODE_VIEW_STATE_ACTIVE];
    } else {
        [self updateAppearanceForState:DISCOUNT_CODE_VIEW_STATE_CLEAN];
    }
    return YES;
}*/

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.text.length == 0) {
        [self updateAppearanceForState:DISCOUNT_CODE_VIEW_STATE_CLEAN];
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    [self updateAppearanceForState:DISCOUNT_CODE_VIEW_STATE_ACTIVE];
    return YES;
}

#pragma mark - Helpers
-(void) updateAppearanceForState:(DiscountCodeViewState)state {
    switch (state) {
        case DISCOUNT_CODE_VIEW_STATE_CLEAN:
            self.discountApplyButton.hidden = NO;
            self.discountApplyButton.enabled = NO;
            self.discountRemoveButton.hidden = YES;
            self.discountCodeTextField.enabled = YES;
            self.discountCodeTextField.textAlignment = NSTextAlignmentRight;
            self.discountCodeTextField.placeholder = STRING_ENTER_YOUR_DISCOUNT_CODE;
        break;
        
        case DISCOUNT_CODE_VIEW_STATE_ACTIVE:
            self.discountApplyButton.hidden = NO;
            self.discountApplyButton.enabled = YES;
            self.discountRemoveButton.hidden = YES;
            self.discountCodeTextField.enabled = YES;
            self.discountCodeTextField.placeholder = nil;
            self.discountCodeTextField.textAlignment = NSTextAlignmentLeft;
        break;
            
        case DISCOUNT_CODE_VIEW_STATE_CONTAINS_CODE:
            self.discountApplyButton.hidden = YES;
            self.discountApplyButton.enabled = NO;
            self.discountRemoveButton.hidden = NO;
            self.discountCodeTextField.enabled = NO;
            self.discountCodeTextField.placeholder = nil;
            self.discountCodeTextField.textAlignment = NSTextAlignmentLeft;
        break;
    }
}

@end
