//
//  JAPDVProductInfo.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVProductInfo.h"
#import "JAPriceView.h"

@interface JAPDVProductInfo()

@property (nonatomic, strong)JAPriceView* priceView;

@end

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
            JAPDVProductInfo *object = (JAPDVProductInfo *)obj;
            [object setup];
            return object;
        }
    }
    
    return nil;
}

- (void)setup
{
    [self.sizeLabel setTextColor:UIColorFromRGB(0x55a1ff)];
}

- (void)setPriceWithNewValue:(NSString *)newValue
                 andOldValue:(NSString *)oldValue
{
    [self.priceView removeFromSuperview];
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:oldValue
                     specialPrice:newValue
                         fontSize:14.0f
            specialPriceOnTheLeft:NO];
    self.priceView.frame = CGRectMake(6.0f,
                                      14.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self addSubview:self.priceView];
    
    [self layoutSubviews];
}

- (void)removeSizeOptions
{
    [self.sizeClickableView removeFromSuperview];
    
    CGRect reviewFrame = self.reviewsClickableView.frame;
    reviewFrame.origin.y -= 44.0f;
    self.reviewsClickableView.frame = reviewFrame;
    
    CGRect buttonFrame = self.specificationsClickableView.frame;
    buttonFrame.origin.y -= 44.0f;
    self.specificationsClickableView.frame = buttonFrame;
    
    CGRect labelFrame = self.specificationsLabel.frame;
    labelFrame.origin.y -= 44.0f;
    self.specificationsLabel.frame = labelFrame;
    
    CGRect imageFrame = self.goToSpecificationsImageView.frame;
    imageFrame.origin.y -= 44.0f;
    self.goToSpecificationsImageView.frame = imageFrame;
    
    CGRect frame = self.frame;
    frame.size.height -= 44.0f;
    
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
