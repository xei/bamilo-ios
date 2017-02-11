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
@end

@implementation DiscountCodeView

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
}

-(void)clearOut {
    self.discountCodeTextField.text = @"";
    self.discountCodeTextField.textAlignment = NSTextAlignmentRight;
    self.discountCodeTextField.placeholder = STRING_ENTER_YOUR_DISCOUNT_CODE;
}

#pragma mark - Overrides
+(NSString *)nibName {
    return @"DiscountCodeView";
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.placeholder = nil;
    textField.textAlignment = NSTextAlignmentLeft;
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.text.length == 0) {
        textField.textAlignment = NSTextAlignmentRight;
        textField.placeholder = STRING_ENTER_YOUR_DISCOUNT_CODE;
    }
}

@end
