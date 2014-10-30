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
            return object;
        }
    }
    
    return nil;
}

- (void)setupWithFrame:(CGRect)frame
{
    [self.sizeLabel setTextColor:UIColorFromRGB(0x55a1ff)];
    
    CGFloat width = frame.size.width - 12.0f;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
    
    [self.priceSeparator setFrame:CGRectMake(self.priceSeparator.frame.origin.x,
                                             self.priceSeparator.frame.origin.y,
                                             width,
                                             self.priceSeparator.frame.size.height)];
    
    [self.sizeClickableView setFrame:CGRectMake(self.sizeClickableView.frame.origin.x,
                                                self.sizeClickableView.frame.origin.y,
                                                width,
                                                self.sizeClickableView.frame.size.height)];
    
    [self.sizeImageViewSeparator setFrame:CGRectMake(self.sizeImageViewSeparator.frame.origin.x,
                                                     self.sizeImageViewSeparator.frame.origin.y,
                                                     width,
                                                     self.sizeImageViewSeparator.frame.size.height)];
    
    [self.reviewsClickableView setFrame:CGRectMake(self.reviewsClickableView.frame.origin.x,
                                                   self.reviewsClickableView.frame.origin.y,
                                                   width,
                                                   self.reviewsClickableView.frame.size.height)];
    
    [self.goToReviewsImageView setFrame:CGRectMake(self.reviewsClickableView.frame.size.width - self.reviewsClickableView.frame.origin.x - self.goToReviewsImageView.frame.size.width - 9.0f,
                                                   self.goToReviewsImageView.frame.origin.y,
                                                   self.goToReviewsImageView.frame.size.width,
                                                   self.goToReviewsImageView.frame.size.height)];
    
    [self.ratingsSeparator setFrame:CGRectMake(self.ratingsSeparator.frame.origin.x,
                                               self.ratingsSeparator.frame.origin.y,
                                               width,
                                               self.ratingsSeparator.frame.size.height)];
    
    [self.specificationsClickableView setFrame:CGRectMake(self.specificationsClickableView.frame.origin.x,
                                                          self.specificationsClickableView.frame.origin.y,
                                                          width,
                                                          self.specificationsClickableView.frame.size.height)];
    
    [self.goToSpecificationsImageView setFrame:CGRectMake(self.sizeClickableView.frame.size.width - self.specificationsClickableView.frame.origin.x - self.goToSpecificationsImageView.frame.size.width - 9.0f,
                                                          self.goToSpecificationsImageView.frame.origin.y,
                                                          self.goToSpecificationsImageView.frame.size.width,
                                                          self.goToSpecificationsImageView.frame.size.height)];
    
    for(UIView *subView in self.subviews)
    {
        [subView setFrame:CGRectMake(subView.frame.origin.x,
                                     subView.frame.origin.y,
                                     width,
                                     subView.frame.size.height)];
    }
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
