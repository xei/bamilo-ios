//
//  JACheckBoxComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"

@interface JACheckBoxComponent : UIView

@property (strong, nonatomic) RIField *field;
@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UISwitch *switchComponent;

+ (JACheckBoxComponent *)getNewJACheckBoxComponent;

-(void)setup;

-(void)setupWithField:(RIField*)field;

@end
