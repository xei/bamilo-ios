//
//  InputTextField.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputTextField : UIView
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (nonatomic) Boolean hasIcon;

- (void)showErrorMsg:(NSString *)errorMsg;
- (void)clearError;

@end
