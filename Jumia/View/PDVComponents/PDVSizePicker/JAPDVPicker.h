//
//  JAPDVPicker.h
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPDVPicker : UIView
<
    UIPickerViewDataSource
>

@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIImageView *img2;

+ (JAPDVPicker *)getNewJAPDVPicker;
- (void)setDataSourceArray:(NSArray *)dataSource
              previousText:(NSString *)previousText;

@end
