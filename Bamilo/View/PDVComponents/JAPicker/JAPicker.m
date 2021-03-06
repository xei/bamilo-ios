//
//  JAPicker.m
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPicker.h"
#import "RIProductSimple.h"

@interface JAPicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *buttonBackgroundView;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation JAPicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setup];
}

- (void)setup {
    if (!VALID(self.backgroundView, UIView)) {
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.backgroundView];
    } else {
        [self.backgroundView setFrame:self.bounds];
    }
    
    UITapGestureRecognizer *removePickerViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removePickerView)];
    [self.backgroundView addGestureRecognizer:removePickerViewTap];
    
    if(!VALID(self.doneButton, UIButton)) {
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.pickerView];
    }
    
    [self.pickerView setBackgroundColor:JAWhiteColor];
    [self.pickerView setAlpha:0.9];
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    [self.pickerView setFrame:CGRectMake(0.0f,
                                         (self.backgroundView.frame.size.height - self.pickerView.frame.size.height),
                                         self.backgroundView.frame.size.width,
                                         self.pickerView.frame.size.height)];
    
    if (!VALID_NOTEMPTY(self.buttonBackgroundView, UIView)) {
        self.buttonBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.buttonBackgroundView setBackgroundColor:JAWhiteColor];
        [self.buttonBackgroundView setAlpha:0.9];
        [self addSubview:self.buttonBackgroundView];
    }
    [self.buttonBackgroundView setFrame:CGRectMake(0.0f, CGRectGetMinY(self.pickerView.frame) - 44.0f, self.backgroundView.frame.size.width, 44.0f)];

    
    CGFloat doneButtonWidth = 62.0f;
    
    if (!VALID_NOTEMPTY(self.doneButton, UIButton)) {
        self.doneButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [self.doneButton.titleLabel setFont:JAPickerDoneLabel];
        [self.doneButton setTitle:STRING_DONE forState:UIControlStateNormal];
        [self.doneButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
        [self.doneButton setTitleColor:JAOrange1Color forState:UIControlStateHighlighted];
        [self.doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonBackgroundView addSubview:self.doneButton];
    }
    [self.doneButton setFrame:CGRectMake(self.backgroundView.frame.size.width - doneButtonWidth, 0.0f, doneButtonWidth, 44.0f)];
    CGFloat leftButtonWidth = 100.0f;
    if (!VALID_NOTEMPTY(self.leftButton, UIButton)) {
        self.leftButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [self.leftButton.titleLabel setFont:JAPickerDoneLabel];
        [self.leftButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
        [self.leftButton setTitleColor:JAOrange1Color forState:UIControlStateHighlighted];
        [self.leftButton addTarget:self action:@selector(leftButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonBackgroundView addSubview:self.leftButton];
        self.leftButton.hidden = YES;
    }
    [self.leftButton setFrame:CGRectMake(0.0f, 0.0f, leftButtonWidth, 44.0f)];
    
    if (RI_IS_RTL) {
        [self.doneButton flipViewPositionInsideSuperview];
        [self.leftButton flipViewPositionInsideSuperview];
    }
}

- (void)removePickerView {
    if(self.delegate && [self.delegate respondsToSelector:@selector(closePicker)]) {
        [self.delegate closePicker];
    } else {
        [self removeFromSuperview];
    }
}

- (void)setDataSourceArray:(NSArray *)dataSource previousText:(NSString *)previousText leftButtonTitle:(NSString*)leftButtonTitle {
    [self setDataSourceArray:dataSource pickerTitle:nil previousText:previousText leftButtonTitle:leftButtonTitle];
}

- (void)setDataSourceArray:(NSArray *)dataSource pickerTitle:(NSString *)pickerTitle previousText:(NSString *)previousText leftButtonTitle:(NSString*)leftButtonTitle {
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
        [self.titleLabel setFrame:CGRectMake(0, 0, self.width - self.doneButton.frame.size.width, 44.0f)];
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
    
    for (int i = 0 ; i < dataSource.count ; i++) {
        NSString *object = [dataSource objectAtIndex:i];
        if ([object isEqualToString:previousText]) {
            [self.pickerView selectRow:i
                           inComponent:0
                              animated:YES];
            break;
        }
    }
}

- (void)doneButtonPressed {
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedRow:)]) {
        [self.delegate selectedRow:[self.pickerView selectedRowInComponent:0]];
    }
}

- (void)leftButtonPressed {
    if(self.delegate && [self.delegate respondsToSelector:@selector(leftButtonPressed)]) {
        [self.delegate leftButtonPressed];
    }
}

#pragma mark - Pickerview data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataSource.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* tView = (UILabel*)view;
    if (!tView) {
        tView = [[UILabel alloc] init];
        [tView setFont:JAPickerAttLabel];
        [tView setTextAlignment:NSTextAlignmentCenter];
    }
    // Fill the label text here
    tView.text=[self.dataSource objectAtIndex:row];
    return tView;
}

@end
