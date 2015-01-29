//
//  JAPDVBundleSingleItem.m
//  Jumia
//
//  Created by epacheco on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVBundleSingleItem.h"

@implementation JAPDVBundleSingleItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (JAPDVBundleSingleItem *)getNewPDVBundleSingleItem
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVBundleSingleItem"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVBundleSingleItem class]]) {
            return (JAPDVBundleSingleItem *)obj;
        }
    }
    
    return nil;
}

@end
