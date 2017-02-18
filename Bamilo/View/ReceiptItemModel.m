//
//  ReceiptItemModel.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ReceiptItemModel.h"

@implementation ReceiptItemModel

+ (instancetype)withName:(NSString *)name value:(NSString *)value {
    return [ReceiptItemModel withName:name value:value color:nil];
}

+(instancetype)withName:(NSString *)name value:(NSString *)value color:(UIColor *)color {
    ReceiptItemModel *model = [[ReceiptItemModel alloc] init];
    model.itemName = name;
    model.itemValue = value;
    model.color = color;
    
    return model;
}

@end
