//
//  JAPDVVariations.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVVariations.h"

@implementation JAPDVVariations

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (JAPDVVariations *)getNewPDVVariationsSection
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVVariations"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVVariations class]]) {
            return (JAPDVVariations *)obj;
        }
    }
    
    return nil;
}

- (void)setupWithFrame:(CGRect)frame
{
    CGFloat width = frame.size.width - 12.0f;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
}

@end
