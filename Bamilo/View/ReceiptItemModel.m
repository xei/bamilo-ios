//
//  ReceiptItemModel.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ReceiptItemModel.h"

@implementation ReceiptItemModel

+(instancetype) with:(NSString *)name price:(NSString *)price currency:(NSString *)currency {
    ReceiptItemModel *model = [[ReceiptItemModel alloc] init];
    model.itemName = name;
    model.itemPrice = price;
    model.itemCurrency = currency;

    return model;
}

@end
