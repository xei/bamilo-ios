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
    ReceiptItemModel *model = [[ReceiptItemModel alloc] init];
    model.itemName = name;
    model.itemValue = value;

    return model;
}

@end
