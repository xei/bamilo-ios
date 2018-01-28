//
//  InputTextField.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseControlView.h"
#import "IconButton.h"

@interface InputTextField : BaseControlView
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (assign, nonatomic) BOOL hasIcon;

- (void)showErrorMsg:(NSString *)errorMsg;
- (void)clearError;
- (void)updateDropDownAppearance:(BOOL)isHidden;
- (void)showDisabledMode;
- (void)resetSeperator;
- (void)enableEyeIconButton:(BOOL)enable;

@end
