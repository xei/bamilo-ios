//
//  JAPDVBundleSingleItem.m
//  Jumia
//
//  Created by epacheco on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVBundleSingleItem.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"
#import "JAProductInfoSingleLine.h"

@interface JAPDVBundleSingleItem ()

@end

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
            
//            real.productTypeLabel.font = JACaptionFont;
            [real.productTypeLabel setTextColor:JABlack800Color];
            
//            real.productNameLabel.font = JABody3Font;
            [real.productNameLabel setTextColor:JABlackColor];
            
//            real.productPriceLabel.font = JACaptionFont;
            [real.productPriceLabel setTextColor:JABlack800Color];
            
            
//            real.totalPriceLabel.font = JACaptionFont;
//            [real.totalPriceLabel setTextColor:JAOrange1Color];
            
            return real;
        }
    }
    
    return nil;
}

- (void)setProduct:(RIProduct *)product
{
    _product = product;
}

- (void)addSelectTarget:(id)target action:(SEL)selector
{
    [self.selectedProduct addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

@end
