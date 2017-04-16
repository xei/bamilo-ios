//
//  BaseControlView.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseControlView.h"

@implementation BaseControlView

+ (instancetype)nibInstance {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
}

@end
