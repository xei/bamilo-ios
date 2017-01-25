//
//  JADatePicker.h
//  Jumia
//
//  Created by plopes on 17/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JADatePickerDelegate <NSObject>

- (void)selectedDate:(NSDate*)selectedDate;

@optional

- (void)closeDatePicker;

@end

@interface JADatePicker : UIView

@property (weak, nonatomic) id<JADatePickerDelegate> delegate;
@property (strong, nonatomic) UIDatePicker *datePicker;

-(void)setDate:(NSDate*)date;

@end
