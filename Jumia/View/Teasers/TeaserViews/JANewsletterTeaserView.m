//
//  JANewsletterTeaserView.m
//  Jumia
//
//  Created by Jose Mota on 02/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JANewsletterTeaserView.h"
#import "RICustomer.h"

#define kTopMargin 6.f
#define kLateralMargin 10.f

@interface JANewsletterTeaserView () <JADynamicFormDelegate> {
    CGFloat _formWidth;
    CGFloat _genderX;
    CGFloat _genderWidth;
    CGFloat _emailX;
    CGFloat _emailWidth;
}

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UILabel *headerTitleLabel;
@property (nonatomic, strong) UILabel *headerBodyLabel;
@property (nonatomic, strong) JARadioComponent *genderRadioComponent;
@property (nonatomic, strong) JATextFieldComponent *emailTextFieldComponent;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) JADynamicForm *dynamicForm;

@end

@implementation JANewsletterTeaserView

- (UIView *)backgroundView
{
    if (!VALID(_backgroundView, UIView)) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(6.f, kTopMargin, self.width - 2*6.f, 0)];
        [_backgroundView setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:_backgroundView];
    }
    return _backgroundView;
}

- (UILabel *)headerTitleLabel
{
    if (!VALID(_headerTitleLabel, UILabel)) {
        _headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, kTopMargin, _formWidth - 2*kLateralMargin, 20)];
        [_headerTitleLabel setNumberOfLines:0];
        [_headerTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [_headerTitleLabel setFont:JAList2Font];
        [_headerTitleLabel setText:STRING_SIGNUP_NEWSLETTER];
        [_headerTitleLabel setHeight:[_headerTitleLabel sizeThatFits:CGSizeMake(_headerTitleLabel.width, CGFLOAT_MAX)].height];
    }
    return _headerTitleLabel;
}

- (UILabel *)headerBodyLabel
{
    if (!VALID(_headerBodyLabel, UILabel)) {
        _headerBodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.headerTitleLabel.frame) + kTopMargin, _formWidth - 2*kLateralMargin, 30)];
        [_headerBodyLabel setNumberOfLines:0];
        [_headerBodyLabel setTextAlignment:NSTextAlignmentLeft];
        [_headerBodyLabel setFont:JABody3Font];
        [_headerBodyLabel setTextColor:JABlack800Color];
        [_headerBodyLabel setText:STRING_SIGNUP_NEWSLETTER_BODY];
        [_headerBodyLabel setHeight:[_headerBodyLabel sizeThatFits:CGSizeMake(_headerBodyLabel.width, CGFLOAT_MAX)].height];
    }
    return _headerBodyLabel;
}

- (UIButton *)submitButton
{
    if (!VALID(_submitButton, UIButton)) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_submitButton.titleLabel setFont:JAButtonFont];
        [_submitButton setTitle:[STRING_SUBMIT uppercaseString] forState:UIControlStateNormal];
        [_submitButton setTintColor:JAOrange1Color];
        [_submitButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_submitButton sizeToFit];
        [_submitButton setFrame:CGRectMake(kLateralMargin, kTopMargin, _submitButton.width, 20)];
        [_submitButton addTarget:self action:@selector(submitNewsletter:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _submitButton;
}

- (void)setForm:(RIForm *)form
{
    _form = form;
    
    if (form.fields.count != 2) {
        NSLog(@"INVALID NEWSLETTER FORM!");
        return;
    }
    
    [self initValues];
    
    [self setHeader];
    
    self.dynamicForm = [[JADynamicForm alloc] initWithForm:self.form startingPosition:CGRectGetMaxY(self.headerBodyLabel.frame) widthSize:self.width hasFieldNavigation:NO];
    [self.dynamicForm setDelegate:self.genderPickerDelegate?:self];
    for (UIView *view in self.dynamicForm.formViews) {
        if (VALID(view, UIView)) {
            if (VALID(view, JARadioComponent)) {
                [self setGenderView:view];
            }else if(VALID(view, JATextFieldComponent)){
                [self setEmailView:view];
            }
        }
    }
    if (_formWidth > 320) {
        [self.submitButton setFrame:CGRectMake(_formWidth - self.submitButton.width - kLateralMargin, self.emailTextFieldComponent.y + 25, self.submitButton.width, 20)];
    }else{
        [self.submitButton setFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.emailTextFieldComponent.frame) + kTopMargin, _formWidth - 2*kLateralMargin, 20)];
    }
    [self addView:self.submitButton];
    
    [self loadCustomer];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (void)initValues
{
    _formWidth = self.width - 12.f;
    _genderX = kLateralMargin;
    _genderWidth = _formWidth/3 - kLateralMargin;
    _emailX = _formWidth/3 + kLateralMargin;
    
    if (_formWidth > 320) {
        _emailWidth = 2*_formWidth/3 - 3*kLateralMargin - self.submitButton.width;
    }else{
        _emailWidth = 2*_formWidth/3 - 2*kLateralMargin;
    }
}

- (CGRect)getRectForText:(NSString *)text withFont:(UIFont *)font
{
    return [text boundingRectWithSize:CGSizeMake(200, 0)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
}

- (void)setHeader
{
    [self.backgroundView addSubview:self.headerTitleLabel];
    [self.backgroundView addSubview:self.headerBodyLabel];
}

- (void)setGenderView:(UIView *)view
{
    [self setGenderRadioComponent:(JARadioComponent *)view];
    [view setFrame:CGRectMake(_genderX, self.emailTextFieldComponent?self.emailTextFieldComponent.y:view.y, _genderWidth, view.height)];
    [self addView:view];
}

- (void)setEmailView:(UIView *)view
{
    [self setEmailTextFieldComponent:(JATextFieldComponent *)view];
    [view setFrame:CGRectMake(_emailX, self.genderRadioComponent?self.genderRadioComponent.y:view.y, _emailWidth, view.height)];
    [self addView:view];
}

- (void)addView:(UIView *)view
{
    [self.backgroundView addSubview:view];
    if (self.height < CGRectGetMaxY(view.frame) + 2*kTopMargin) {
        [self setHeight:CGRectGetMaxY(view.frame) + 2*kTopMargin];
        [self.backgroundView setHeight:CGRectGetMaxY(view.frame) + kTopMargin];
    }
}

- (void)loadCustomer
{
    if ([RICustomer checkIfUserIsLogged]) {
        [RICustomer getCustomerWithSuccessBlock:^(RICustomer *customer) {
            if (VALID_NOTEMPTY(customer.gender, NSString)) {
                for (NSString *value in self.genderRadioComponent.options) {
                    NSString *label = [self.genderRadioComponent.optionsLabels objectForKey:value];
                    if ([[customer.gender lowercaseString] isEqualToString:[label lowercaseString]]) {
                        [self.genderRadioComponent setValue:value];
                        [self.genderRadioComponent.textField setText:label];
                        break;
                    }
                }
            }
            if (VALID_NOTEMPTY(customer.email, NSString)) {
                [self.emailTextFieldComponent setValue:customer.email];
            }else{
                [self.emailTextFieldComponent setValue:@""];
            }
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            [self.genderRadioComponent setValue:@""];
            [self.emailTextFieldComponent setValue:@""];
        }];
    }else{
        [self.genderRadioComponent setValue:@""];
        [self.emailTextFieldComponent setValue:@""];
    }
}

- (void)submitNewsletter:(UIButton *)sender
{
    if ([self.genderPickerDelegate respondsToSelector:@selector(submitNewsletter:andEmail:)])
    {
        [self.genderPickerDelegate performSelector:@selector(submitNewsletter:andEmail:) withObject:self.dynamicForm withObject:self.emailTextFieldComponent.textField.text];
    }
}

@end
