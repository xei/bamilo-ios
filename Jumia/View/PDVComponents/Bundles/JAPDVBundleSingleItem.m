//
//  JAPDVBundleSingleItem.m
//  Jumia
//
//  Created by epacheco on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVBundleSingleItem.h"

@implementation JAPDVBundleSingleItem

@synthesize alwaysSelected=_alwaysSelected;
-(void)setAlwaysSelected:(BOOL)alwaysSelected
{
    _alwaysSelected = alwaysSelected;
    if (alwaysSelected) {
        self.selected = YES;
    }
}

-(void)setSelected:(BOOL)selected
{
    if (self.alwaysSelected) {
        self.selectedProduct.selected = YES;
    } else {
        self.selectedProduct.selected = selected;
    }
}
- (BOOL)selected
{
    if (self.alwaysSelected) {
        return YES;
    } else {
        return self.selectedProduct.selected;
    }
}

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
            JAPDVBundleSingleItem* real = (JAPDVBundleSingleItem* )obj;
            real.productNameLabel.font = [UIFont fontWithName:kFontRegularName size:real.productNameLabel.font.pointSize];
            real.productTypeLabel.font = [UIFont fontWithName:kFontLightName size:real.productTypeLabel.font.pointSize];
            real.productPriceLabel.font = [UIFont fontWithName:kFontLightName size:real.productPriceLabel.font.pointSize];
            return real;
        }
    }
    
    return nil;
}

+ (JAPDVBundleSingleItem *)getNewPDVBundleSingleItemWithSize
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVBundleSingleItemWithSize"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVBundleSingleItem class]]) {
            JAPDVBundleSingleItem* real = (JAPDVBundleSingleItem* )obj;
            real.productNameLabel.font = [UIFont fontWithName:kFontRegularName size:real.productNameLabel.font.pointSize];
            real.productTypeLabel.font = [UIFont fontWithName:kFontLightName size:real.productTypeLabel.font.pointSize];
            real.productPriceLabel.font = [UIFont fontWithName:kFontLightName size:real.productPriceLabel.font.pointSize];
            return real;
        }
    }
    
    return nil;
}

@end