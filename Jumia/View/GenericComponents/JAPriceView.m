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
    
    _label = [UILabel new];
    
    NSMutableAttributedString* finalPriceString;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:kFontRegularName size:fontSize], NSFontAttributeName,
                                UIColorFromRGB(0xcc0000), NSForegroundColorAttributeName, nil];

    if (VALID_NOTEMPTY(specialPrice, NSString) && VALID_NOTEMPTY(price, NSString))
    {
        NSDictionary* oldPriceAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIFont fontWithName:kFontLightName size:fontSize], NSFontAttributeName,
                                            UIColorFromRGB(0xcccccc), NSForegroundColorAttributeName, nil];
        
        NSRange oldPriceRange = NSMakeRange(RI_IS_RTL?0:(specialPrice.length + 1), RI_IS_RTL?specialPrice.length:price.length);
        
        if ((RI_IS_RTL && _specialPriceOnTheLeft) || (!RI_IS_RTL && !_specialPriceOnTheLeft) ) {
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
    [self addSubview:_label];
    
    [_label setTextAlignment:NSTextAlignmentNatural];
    
    
    if (VALID_NOTEMPTY(specialPrice, NSString)) {
        UILabel* oldPriceLabel = [UILabel new];
        oldPriceLabel.text = price;
        oldPriceLabel.font = [UIFont fontWithName:kFontLightName size:fontSize];
        [oldPriceLabel sizeToFit];
        _strike = [[UIView alloc] init];
        CGFloat strikePosition = self.frame.size.width - oldPriceLabel.frame.size.width;
        if (_specialPriceOnTheLeft) {
            strikePosition = 0.0f;
        }
        
        _strike.frame = CGRectMake(strikePosition,
                                  (self.frame.size.height - 1.0f) /2 ,
                                  oldPriceLabel.frame.size.width,
                                  1.0f);
        
        _strike.backgroundColor = UIColorFromRGB(0xcccccc);
        [self addSubview:_strike];
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
