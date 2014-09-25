//
//  JAPDVRelatedItem.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVRelatedItem.h"

@implementation JAPDVRelatedItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (JAPDVRelatedItem *)getNewPDVRelatedItemSection
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVRelatedItem"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVRelatedItem class]]) {
            return (JAPDVRelatedItem *)obj;
        }
    }
    
    return nil;
}

@end
