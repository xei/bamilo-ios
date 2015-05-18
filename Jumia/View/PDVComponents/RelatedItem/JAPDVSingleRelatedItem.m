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
            JAPDVSingleRelatedItem* real = (JAPDVSingleRelatedItem* )obj;
            real.labelBrand.font = [UIFont fontWithName:kFontRegularName size:real.labelBrand.font.pointSize];
            real.labelName.font = [UIFont fontWithName:kFontLightName size:real.labelName.font.pointSize];
            real.labelPrice.font = [UIFont fontWithName:kFontLightName size:real.labelPrice.font.pointSize];
            return real;
        }
    }
    
    return nil;
}

@end
