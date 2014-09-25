//
//  JACheckBoxWithOptionsComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JACheckBoxWithOptionsComponent : UIView

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIView *separator;

@property (strong, nonatomic) RIField *field;
@property (strong, nonatomic) NSMutableDictionary *values;

+ (JACheckBoxWithOptionsComponent *)getNewJACheckBoxWithOptionsComponent;

-(void)setupWithField:(RIField*)field;


@end
