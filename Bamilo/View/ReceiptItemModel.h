//
//  ReceiptItemModel.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/7/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiptItemModel : NSObject

@property (copy, nonatomic) NSString *itemName;
@property (copy, nonatomic) NSString *itemValue;
@property (strong, nonatomic) UIColor *color;

+ (instancetype)withName:(NSString *)name value:(NSString *)value color:(UIColor *)color;
+ (instancetype)withName:(NSString *)name value:(NSString *)value;

@end
