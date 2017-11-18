//
//  BaseControlView.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseControlView.h"

@implementation BaseControlView

+ (NSString *)nibName {
    return NSStringFromClass([self class]);
}

+ (instancetype)nibInstance {
    return [[[NSBundle mainBundle] loadNibNamed:[self nibName] owner:self options:nil] lastObject];
}

@end
