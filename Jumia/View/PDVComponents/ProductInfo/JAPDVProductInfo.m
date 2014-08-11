//
//  JAPDVProductInfo.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVProductInfo.h"

@implementation JAPDVProductInfo

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (JAPDVProductInfo *)getNewPDVProductInfoSection
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVProductInfo"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVProductInfo class]]) {
            return (JAPDVProductInfo *)obj;
        }
    }
    
    return nil;
}

- (void)setPriceWithNewValue:(NSString *)newValue
                 andOldValue:(NSString *)oldValue
{
    if (newValue.length > 0) {
        
        NSMutableAttributedString *mutableNewValue = [[NSMutableAttributedString alloc] initWithString:newValue];
        
        NSInteger _stringLength = newValue.length;
        
        UIColor *newValueColor = [UIColor colorWithRed:204.0/255.0
                                                 green:0.0/255.0
                                                  blue:0.0/255.0
                                                 alpha:1.0f];
        
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue"
                                       size:14.0];
        
        [mutableNewValue addAttribute:NSFontAttributeName
                                value:font
                                range:NSMakeRange(0, _stringLength)];
        
        [mutableNewValue addAttribute:NSStrokeColorAttributeName
                                value:newValueColor
                                range:NSMakeRange(0, _stringLength)];
        
        if (oldValue.length > 0) {
            
            oldValue = [NSString stringWithFormat:@" %@", oldValue];
            
            NSMutableAttributedString *mutableOldValue = [[NSMutableAttributedString alloc] initWithString:oldValue];
            
            NSInteger oldValueLength = oldValue.length;
            
            UIFont *oldValueFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                   size:14.0];
            
            UIColor *oldValueColor = [UIColor colorWithRed:204.0/255.0
                                                     green:0.0/255.0
                                                      blue:0.0/255.0
                                                     alpha:1.0f];
            
            [mutableOldValue addAttribute:NSFontAttributeName
                                    value:oldValueFont
                                    range:NSMakeRange(0, oldValueLength)];
            
            [mutableOldValue addAttribute:NSStrokeColorAttributeName
                                    value:oldValueColor
                                    range:NSMakeRange(0, oldValueLength)];
            
            NSMutableAttributedString *resultString = [mutableNewValue mutableCopy];
            [resultString appendAttributedString:mutableOldValue];
            
            self.priceLabel.attributedText = resultString;
            
        } else {
            
            self.priceLabel.attributedText = mutableNewValue;
            
        }
    } else {
        NSMutableAttributedString *mutableOldValue = [[NSMutableAttributedString alloc] initWithString:oldValue];
        
        NSInteger oldValueLength = oldValue.length;
        
        UIFont *oldValueFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                               size:14.0];
        
        UIColor *oldValueColor = [UIColor colorWithRed:204.0/255.0
                                                 green:0.0/255.0
                                                  blue:0.0/255.0
                                                 alpha:1.0f];
        
        [mutableOldValue addAttribute:NSFontAttributeName
                                value:oldValueFont
                                range:NSMakeRange(0, oldValueLength)];
        
        [mutableOldValue addAttribute:NSStrokeColorAttributeName
                                value:oldValueColor
                                range:NSMakeRange(0, oldValueLength)];
        
        self.priceLabel.attributedText = mutableOldValue;
    }
}

- (void)removeSizeOptions
{
    [self.sizeView removeFromSuperview];
    
    CGRect reviewFrame = self.reviewsView.frame;
    reviewFrame.origin.y -= 45.0f;
    self.reviewsView.frame = reviewFrame;
    
    CGRect buttonFrame = self.goToSpecificationsButton.frame;
    buttonFrame.origin.y -= 45.0f;
    self.goToSpecificationsButton.frame = buttonFrame;
    
    CGRect labelFrame = self.specificationsLabel.frame;
    labelFrame.origin.y -= 45.0f;
    self.specificationsLabel.frame = labelFrame;
    
    CGRect imageFrame = self.goToSpecificationsImageView.frame;
    imageFrame.origin.y -= 45.0f;
    self.goToSpecificationsImageView.frame = imageFrame;
    
    CGRect frame = self.frame;
    frame.size.height -= 45.0f;
    
    self.frame = frame;
}

- (void)setNumberOfStars:(NSInteger)stars
{
    switch (stars) {
        case 0: {
            
            self.star1.image = [self getEmptyStar];
            self.star2.image = [self getEmptyStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 1: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getEmptyStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 2: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 3: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getFilledStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 4: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getFilledStar];
            self.star4.image = [self getFilledStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 5: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getFilledStar];
            self.star4.image = [self getFilledStar];
            self.star5.image = [self getFilledStar];
            
        }
            break;
            
        default: {
            
            self.star1.image = [self getEmptyStar];
            self.star2.image = [self getEmptyStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
    }
}

- (UIImage *)getEmptyStar
{
    return [UIImage imageNamed:@"img_rating_star_big_empty"];
}

- (UIImage *)getFilledStar
{
    return [UIImage imageNamed:@"img_rating_star_big_full"];
}

@end
