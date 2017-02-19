//
//  ReceiptItemModel.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ReceiptItemModel.h"

#define cDARK_GRAY_COLOR [UIColor withRepeatingRGBA:115 alpha:1.0f]

@implementation ReceiptItemModel

+ (instancetype)withName:(NSString *)name value:(NSString *)value {
    return [ReceiptItemModel withName:name value:value color:cDARK_GRAY_COLOR];
}

+(instancetype)withName:(NSString *)name value:(NSString *)value color:(UIColor *)color {
    ReceiptItemModel *model = [[ReceiptItemModel alloc] init];
    model.itemName = name;
    model.itemValue = value;
    model.color = color;
    
    return model;
}

@end
