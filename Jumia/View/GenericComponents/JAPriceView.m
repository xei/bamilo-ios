//
//  JAPriceView.m
//  Jumia
//
//  Created by Telmo Pinto on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPriceView.h"

@interface JAPriceView () {
    UILabel *_label;
    UIView *_strike;
    BOOL _specialPriceOnTheLeft;
}

@end

@implementation JAPriceView

- (void)loadWithPrice:(NSString*)price
         specialPrice:(NSString*)specialPrice
             fontSize:(CGFloat)fontSize
specialPriceOnTheLeft:(BOOL)specialPriceOnTheLeft;
{
    _specialPriceOnTheLeft = specialPriceOnTheLeft;
    
    if (!_label) {
        _label = [UILabel new];
        [self addSubview:_label];
    }
    
    NSMutableAttributedString* finalPriceString;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                JACaptionFont, NSFontAttributeName,
                                JABlackColor, NSForegroundColorAttributeName, nil];

    if (VALID_NOTEMPTY(specialPrice, NSString) && VALID_NOTEMPTY(price, NSString))
    {
        NSDictionary* oldPriceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            JACaptionFont, NSFontAttributeName,
                                            JABlack800Color, NSForegroundColorAttributeName, nil];
        
        NSRange oldPriceRange = NSMakeRange(RI_IS_RTL?0:(specialPrice.length + 1), RI_IS_RTL?specialPrice.length:price.length);
        
        if (/*(RI_IS_RTL && _specialPriceOnTheLeft) || (!RI_IS_RTL && */!_specialPriceOnTheLeft/*)*/ ) {
            finalPriceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", price, specialPrice]
                                                                      attributes:attributes];
            oldPriceRange = NSMakeRange(0, price.length);
        }else{
            finalPriceString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", specialPrice, price]
                                                                      attributes:attributes];
            oldPriceRange = NSMakeRange(specialPrice.length + 1, price.length);
        }
        
        
        [finalPriceString setAttributes:oldPriceAttributes
                                  range:oldPriceRange];
        
    }
    else if (VALID_NOTEMPTY(price, NSString))
    {
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:price attributes:attributes];
    }
    else if (VALID_NOTEMPTY(specialPrice, NSString))
    {
        // this should not happen.. this means that the API is only sending special price
        finalPriceString = [[NSMutableAttributedString alloc] initWithString:specialPrice attributes:attributes];
    }
    else
    {
        // this should not happen.. this means that the API is not sending any price
        finalPriceString  = [[NSMutableAttributedString alloc] initWithString:@"" attributes:attributes];
    }
    
    [_label setAttributedText:finalPriceString];
    [_label sizeToFit];
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            _label.frame.size.width,
                            _label.frame.size.height);
    
    [_label setTextAlignment:NSTextAlignmentNatural];
    if (RI_IS_RTL) {
        [_label setTextAlignment:NSTextAlignmentRight];
    }
    
    
    if (VALID_NOTEMPTY(specialPrice, NSString)) {
        UILabel* oldPriceLabel = [UILabel new];
        oldPriceLabel.text = price;
        oldPriceLabel.font = [attributes objectForKey:NSFontAttributeName];
        [oldPriceLabel sizeToFit];
        if (!_strike) {
            _strike = [[UIView alloc] init];
            [self addSubview:_strike];
        }
        CGFloat strikePosition = self.frame.size.width - oldPriceLabel.frame.size.width;
        if ((RI_IS_RTL && _specialPriceOnTheLeft) || (!RI_IS_RTL && !_specialPriceOnTheLeft)) {
            strikePosition = 0.0f;
        }
        
        _strike.frame = CGRectMake(strikePosition,
                                  _label.y + _label.height/2 - 1.f,
                                  oldPriceLabel.frame.size.width,
                                  1.0f);
        
        _strike.backgroundColor = JABlack800Color;
    }else{
        if (_strike) {
            [_strike removeFromSuperview];
            _strike = nil;
        }
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (self.width < _label.width) {
        _label.width = self.width;
    }
}

@end
