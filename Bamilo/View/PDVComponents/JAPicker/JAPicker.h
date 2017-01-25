//
//  JAPicker.h
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JAPickerDelegate <NSObject>

- (void)selectedRow:(NSInteger)selectedRow;

@optional

- (void)closePicker;
- (void)leftButtonPressed;

@end

@interface JAPicker : UIView

@property (weak, nonatomic) id<JAPickerDelegate> delegate;
@property (strong, nonatomic) UIPickerView *pickerView;

- (void)setDataSourceArray:(NSArray *)dataSource
              previousText:(NSString *)previousText
           leftButtonTitle:(NSString*)leftButtonTitle;

- (void)setDataSourceArray:(NSArray *)dataSource
               pickerTitle:(NSString *)pickerTitle
              previousText:(NSString *)previousText
           leftButtonTitle:(NSString*)leftButtonTitle;

@end
