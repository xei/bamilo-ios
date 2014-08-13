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
    if ([newValue floatValue] > 0.0)
    {
        NSMutableAttributedString *stringOldPrice = [[NSMutableAttributedString alloc] initWithString:oldValue];
        NSInteger stringOldPriceLenght = oldValue.length;
        UIFont *stringOldPriceFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                     size:14.0];
        UIColor *stringOldPriceColor = [UIColor colorWithRed:204.0/255.0
                                                       green:204.0/255.0
                                                        blue:204.0/255.0
                                                       alpha:1.0f];
        
        [stringOldPrice addAttribute:NSFontAttributeName
                               value:stringOldPriceFont
                               range:NSMakeRange(0, stringOldPriceLenght)];
        
        [stringOldPrice addAttribute:NSStrokeColorAttributeName
                               value:stringOldPriceColor
                               range:NSMakeRange(0, stringOldPriceLenght)];
        
        [stringOldPrice addAttribute:NSStrikethroughStyleAttributeName
                               value:@(1)
                               range:NSMakeRange(0, stringOldPriceLenght)];
        
        self.oldPriceLabel.attributedText = stringOldPrice;
        
        NSMutableAttributedString *stringNewPrice = [[NSMutableAttributedString alloc] initWithString:newValue];
        NSInteger stringNewPriceLenght = newValue.length;
        UIFont *stringNewPriceFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                     size:14.0];
        UIColor *stringNewPriceColor = [UIColor colorWithRed:204.0/255.0
                                                       green:0.0/255.0
                                                        blue:0.0/255.0
                                                       alpha:1.0f];
        
        [stringNewPrice addAttribute:NSFontAttributeName
                               value:stringNewPriceFont
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        [stringNewPrice addAttribute:NSStrokeColorAttributeName
                               value:stringNewPriceColor
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        self.priceLabel.attributedText = stringNewPrice;
        
        [self.priceLabel sizeToFit];
        [self.oldPriceLabel sizeToFit];
        
        // This view was builded without auto layout so it's necessary to do maths :D
        float x = self.priceLabel.frame.origin.x + self.priceLabel.frame.size.width + 5;
        CGRect temp = self.oldPriceLabel.frame;
        temp.origin.x = x;
        self.oldPriceLabel.frame = temp;
    }
    else
    {
        NSMutableAttributedString *stringNewPrice = [[NSMutableAttributedString alloc] initWithString:oldValue];
        NSInteger stringNewPriceLenght = oldValue.length;
        UIFont *stringNewPriceFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                     size:14.0];
        UIColor *stringNewPriceColor = [UIColor colorWithRed:204.0/255.0
                                                       green:0.0/255.0
                                                        blue:0.0/255.0
                                                       alpha:1.0f];
        
        [stringNewPrice addAttribute:NSFontAttributeName
                               value:stringNewPriceFont
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        [stringNewPrice addAttribute:NSStrokeColorAttributeName
                               value:stringNewPriceColor
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        self.priceLabel.attributedText = stringNewPrice;
        
        [self.oldPriceLabel removeFromSuperview];
        [self.priceLabel sizeToFit];
    }
    
    [self layoutSubviews];
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
