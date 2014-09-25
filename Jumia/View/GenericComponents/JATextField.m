//
//  JATextField.m
//  Jumia
//
//  Created by Pedro Lopes on 03/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATextField.h"

@implementation JATextField

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x, bounds.origin.y - 3.0f,
                      bounds.size.width, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x, bounds.origin.y - 3.0f,
                      bounds.size.width, bounds.size.height);
}

@end
