//
//  FormItemValidation.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormItemValidation : NSObject
@property (nonatomic) NSUInteger max;
@property (nonatomic) NSUInteger min;
@property (nonatomic) Boolean isRequired;
@property (nonatomic, strong) NSString *regxPattern;

- (instancetype)initWithRequired:(Boolean)isRequired max:(NSUInteger)maxValue min:(NSUInteger)minValue withRegxPatter:(NSString *)regxPattern;
@end
