//
//  JACollectionSeparator.m
//  Jumia
//
//  Created by Jose Mota on 30/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JACollectionSeparator.h"

@implementation JACollectionSeparator

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = JABlack700Color;
    }
    
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    self.frame = layoutAttributes.frame;
}

@end
