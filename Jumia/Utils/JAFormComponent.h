//
//  JAFormComponent.h
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIField.h"

@interface JATextField : UIView

@property (strong, nonatomic) RIField *field;
@property (weak, nonatomic) IBOutlet UITextField *textField;

- (BOOL)isValid;

@end

@interface JACheckBoxComponent : UIView

@property (strong, nonatomic) RIField *field;
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UISwitch *switchComponent;

@end

@interface JABirthDateComponent : UIView

@property (strong, nonatomic) RIField *field;
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@interface JAGenderComponent : UIView

@property (strong, nonatomic) RIField *field;
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

- (void)initSegmentedControl:(NSArray *)itens;

@end

@interface JAFormComponent : NSObject

+ (JATextField *)getNewJATextField;
+ (JACheckBoxComponent *)getNewJACheckBoxComponent;
+ (JABirthDateComponent *)getNewJABirthDateComponent;
+ (JAGenderComponent *)getNewJAGenderComponent;

@end
