//
//  JAPDVPicker.m
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVPicker.h"
#import "RIProductSimple.h"

@interface JAPDVPicker ()

@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation JAPDVPicker

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {

    }
    
    return self;
}

+ (JAPDVPicker *)getNewJAPDVPicker
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVPicker"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVPicker class]]) {
            JAPDVPicker *object = (JAPDVPicker*)obj;
            [object setup];
            return object;
        }
    }
    
    return nil;
}

-(void)setup
{
    [self.doneButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.doneButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
}

- (void)setDataSourceArray:(NSArray *)dataSource
              previousText:(NSString *)previousText
{
    self.dataSource = [NSArray arrayWithArray:dataSource];
    [self.picker reloadAllComponents];
    
    for (int i = 0 ; i < dataSource.count ; i++) {
        RIProductSimple *simple = [dataSource objectAtIndex:i];
        
        if ([simple.attributeSize isEqualToString:previousText]) {
            [self.picker selectRow:i
                       inComponent:0
                          animated:YES];
            break;
        }
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
    RIProductSimple *simple = [self.dataSource objectAtIndex:row];
    UIColor *color = UIColorFromRGB(0x4e4e4e);
    
    NSString* option = simple.attributeSize;
    if (ISEMPTY(option)) {
        option = simple.color;
        if (ISEMPTY(option)) {
            option = simple.variation;
            if (ISEMPTY(option)) {
                option = @"";
            }
        }
    }
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:option
                                                                                  attributes:@{NSForegroundColorAttributeName:color}];
    
    NSInteger lenght = simple.attributeSize.length;
    
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light"
                                   size:22.0];
    
    [attString addAttribute:NSFontAttributeName
                      value:font
                      range:NSMakeRange(0, lenght)];
    
    return attString;
}

@end
