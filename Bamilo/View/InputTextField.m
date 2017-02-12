//
//  InputTextField.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "InputTextField.h"

#define cPlACEHOLDER_COLOR [UIColor withHexString:@"757575"]
#define cINPUT_TINT_COLOR [UIColor withHexString:@"3D3D3D"]


@interface InputTextField()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconVisibleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconHiddenConstraint;

@end


@implementation InputTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpView];
}

- (void)setUpView {
    
    //setDefault style
    NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.textField.placeholder attributes: @{NSForegroundColorAttributeName: cPlACEHOLDER_COLOR}];
    self.textField.attributedPlaceholder = attributedPlaceholder;
    self.textField.tintColor = cINPUT_TINT_COLOR;
    self.textField.font = [UIFont fontWithName:kFontRegularName size:12];
    
    self.hasIcon = NO;
}

- (void)setHasIcon:(Boolean)hasIcon {
    _hasIcon = hasIcon;
    if (hasIcon) {
        [self showIcon];
        return;
    }
    [self hideIcon];
}


- (void)showIcon {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.iconVisibleConstraint.priority = UILayoutPriorityDefaultHigh;
        self.iconHiddenConstraint.priority = UILayoutPriorityDefaultLow;
    });
}

- (void)hideIcon {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.iconVisibleConstraint.priority = UILayoutPriorityDefaultLow;
        self.iconHiddenConstraint.priority = UILayoutPriorityDefaultHigh;
    });
}

@end
