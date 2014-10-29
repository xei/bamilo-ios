//
//  JACheckBoxWithOptionsComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JACheckBoxWithOptionsComponent : UIView

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UIView *separator;

@property (strong, nonatomic) RIField *field;
@property (strong, nonatomic) NSMutableDictionary *values;

-(void)setupWithField:(RIField*)field;

@end
