//
//  JAPDVSingleRelatedItem.m
//  Jumia
//
//  Created by Miguel Chaves on 05/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVSingleRelatedItem.h"

@implementation JAPDVSingleRelatedItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (JAPDVSingleRelatedItem *)getNewPDVSingleRelatedItem
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVSingleRelatedItem"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVSingleRelatedItem class]]) {
            return (JAPDVSingleRelatedItem *)obj;
        }
    }
    
    return nil;
}

@end
