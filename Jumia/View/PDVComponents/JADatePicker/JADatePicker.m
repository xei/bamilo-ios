//
//  JADatePicker.m
//  Jumia
//
//  Created by plopes on 17/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JADatePicker.h"

@interface JADatePicker ()

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *buttonBackgroundView;
@property (strong, nonatomic) UIButton *doneButton;

@end


@implementation JADatePicker

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

-(void)setup
{
    if(VALID(self.backgroundView, UIView))
    {
        [self.backgroundView removeFromSuperview];
    }
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.frame];
    UITapGestureRecognizer *removePickerViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(removePickerView)];
    [self.backgroundView addGestureRecognizer:removePickerViewTap];
    [self addSubview:self.backgroundView];
    
    if(VALID(self.doneButton, UIButton))
    {
        [self.doneButton removeFromSuperview];
    }

    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    [self.datePicker setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.datePicker setAlpha:0.9];
    [self.datePicker setFrame:CGRectMake(0.0f,
                                         (self.backgroundView.frame.size.height - self.datePicker.frame.size.height),
                                         self.frame.size.width,
                                         self.datePicker.frame.size.height)];
    [self addSubview:self.datePicker];
    
    self.buttonBackgroundView = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.buttonBackgroundView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.buttonBackgroundView setAlpha:0.9];
    [self.buttonBackgroundView setFrame:CGRectMake(0.0f,
                                                   CGRectGetMinY(self.datePicker.frame) - 44.0f,
                                                   self.frame.size.width,
                                                   44.0f)];
    
    CGFloat doneButtonWidth = 62.0f;
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setFrame:CGRectMake(self.frame.size.width - doneButtonWidth,
                                         0.0f,
                                         doneButtonWidth,
                                         44.0f)];
    [self.doneButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.doneButton setTitle:STRING_DONE forState:UIControlStateNormal];
    [self.doneButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.doneButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBackgroundView addSubview:self.doneButton];
    [self addSubview:self.buttonBackgroundView];
}

-(void)setDate:(NSDate*)date
{
    [self.datePicker setDate:date];
}

- (void)removePickerView
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeDatePicker)])
    {
        [self.delegate closeDatePicker];
    }
    else
    {
        [self removeFromSuperview];
    }
}

- (void)doneButtonPressed
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedDate:)])
    {
        [self.delegate selectedDate:[self.datePicker date]];
    }
}

#pragma mark - Pickerview data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataSource.count;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *object = [self.dataSource objectAtIndex:row];
    UIColor *color = UIColorFromRGB(0x4e4e4e);
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:object
                                                                                  attributes:@{NSForegroundColorAttributeName:color}];
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light"
                                   size:22.0];
    
    [attString addAttribute:NSFontAttributeName
                      value:font
                      range:NSMakeRange(0, object.length)];
    
    return attString;
}


@end
