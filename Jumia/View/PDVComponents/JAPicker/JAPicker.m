//
//  JAPicker.m
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPicker.h"
#import "RIProductSimple.h"

@interface JAPicker ()
<
UIPickerViewDataSource,
UIPickerViewDelegate
>

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *buttonBackgroundView;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *leftButton;

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation JAPicker

- (instancetype)initWithFrame:(CGRect)frame
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
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   0.0f,
                                                                   self.frame.size.width,
                                                                   self.frame.size.height)];
    UITapGestureRecognizer *removePickerViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(removePickerView)];
    [self.backgroundView addGestureRecognizer:removePickerViewTap];
    [self addSubview:self.backgroundView];
    
    if(VALID(self.doneButton, UIButton))
    {
        [self.doneButton removeFromSuperview];
    }
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.pickerView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.pickerView setAlpha:0.9];
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    [self.pickerView setFrame:CGRectMake(0.0f,
                                         (self.backgroundView.frame.size.height - self.pickerView.frame.size.height),
                                         self.backgroundView.frame.size.width,
                                         self.pickerView.frame.size.height)];
    [self addSubview:self.pickerView];
    
    self.buttonBackgroundView = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.buttonBackgroundView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.buttonBackgroundView setAlpha:0.9];
    [self.buttonBackgroundView setFrame:CGRectMake(0.0f,
                                                   CGRectGetMinY(self.pickerView.frame) - 44.0f,
                                                   self.backgroundView.frame.size.width,
                                                   44.0f)];

    
    CGFloat doneButtonWidth = 62.0f;
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setFrame:CGRectMake(self.backgroundView.frame.size.width - doneButtonWidth,
                                         0.0f,
                                         doneButtonWidth,
                                         44.0f)];
    [self.doneButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.doneButton setTitle:STRING_DONE forState:UIControlStateNormal];
    [self.doneButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.doneButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBackgroundView addSubview:self.doneButton];
    [self addSubview:self.buttonBackgroundView];
    
    CGFloat leftButtonWidth = 100.0f;
    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.leftButton setFrame:CGRectMake(0.0f,
                                         0.0f,
                                         leftButtonWidth,
                                         44.0f)];
    [self.leftButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.leftButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.leftButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonBackgroundView addSubview:self.leftButton];
    self.leftButton.hidden = YES;
    
    if (RI_IS_RTL) {
        [self.doneButton flipViewPositionInsideSuperview];
        [self.leftButton flipViewPositionInsideSuperview];
    }
}

- (void)removePickerView
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(closePicker)])
    {
        [self.delegate closePicker];
    }
    else
    {
        [self removeFromSuperview];
    }
}

- (void)setDataSourceArray:(NSArray *)dataSource
              previousText:(NSString *)previousText
           leftButtonTitle:(NSString*)leftButtonTitle;
{
    [self setDataSourceArray:dataSource pickerTitle:nil previousText:previousText leftButtonTitle:leftButtonTitle];
}

- (void)setDataSourceArray:(NSArray *)dataSource
               pickerTitle:(NSString *)pickerTitle
              previousText:(NSString *)previousText
           leftButtonTitle:(NSString*)leftButtonTitle
{
    if (VALID_NOTEMPTY(leftButtonTitle, NSString)) {
        [self.leftButton setTitle:leftButtonTitle forState:UIControlStateNormal];
        self.leftButton.hidden = NO;
    } else {
        self.leftButton.hidden = YES;
    }
    
    if (VALID_NOTEMPTY(pickerTitle, NSString)) {
        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setText:pickerTitle];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.titleLabel setFrame:CGRectMake(0, 0, self.width, 44.0f)];
        [self.buttonBackgroundView addSubview:self.titleLabel];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 44.0f, self.width, 1)];
        [separator setBackgroundColor:[UIColor colorWithWhite:.4 alpha:.2]];
        [self.buttonBackgroundView addSubview:separator];
        
        self.buttonBackgroundView.y -= 44.0f;
        self.buttonBackgroundView.height += 44.0f;
        self.doneButton.y += 44.0f;
        self.leftButton.y += 44.0f;
    }
    
    self.dataSource = [NSArray arrayWithArray:dataSource];
    [self.pickerView reloadAllComponents];
    
    for (int i = 0 ; i < dataSource.count ; i++)
    {
        NSString *object = [dataSource objectAtIndex:i];
        if ([object isEqualToString:previousText])
        {
            [self.pickerView selectRow:i
                           inComponent:0
                              animated:YES];
            break;
        }
    }
}

- (void)doneButtonPressed
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedRow:)])
    {
        [self.delegate selectedRow:[self.pickerView selectedRowInComponent:0]];
    }
}

- (void)leftButtonPressed
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(leftButtonPressed)])
    {
        [self.delegate leftButtonPressed];
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
    
    UIFont *font = [UIFont fontWithName:kFontLightName
                                   size:22.0];
    
    [attString addAttribute:NSFontAttributeName
                      value:font
                      range:NSMakeRange(0, object.length)];
    
    return attString;
}

@end
