//
//  JAPDVImageSection.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVImageSection.h"

@implementation JAPDVImageSection

+ (JAPDVImageSection *)getNewPDVImageSection
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVImageSection"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVImageSection class]]) {
            return (JAPDVImageSection *)obj;
        }
    }
    
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
       
    }
    
    return self;
}

@end
