//
//  JAReviewCell.m
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAReviewCell.h"

#define kJAReviewCellHorizontalMargins 6.0f

@implementation JAReviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
    }
    
    return self;
}

- (void)setupWithReview:(RIReview *)review
          showSeparator:(BOOL)showSeparator;
{
    for (int i = 0; i < self.ratingStarViews.count; i++) {
        UIView* ratingStarView = [self.ratingStarViews objectAtIndex:i];
        [ratingStarView removeFromSuperview];
        UILabel* ratingLabel = [self.ratingLabels objectAtIndex:i];
        [ratingLabel removeFromSuperview];
    }
    self.ratingLabels = [NSMutableArray new];
    self.ratingStarViews = [NSMutableArray new];
    
    CGFloat currentX = kJAReviewCellHorizontalMargins;
    CGFloat currentY = 6.0f;
    CGFloat ratingViewWidth = (self.frame.size.width - kJAReviewCellHorizontalMargins*2) / 3;
    for (int i = 0; i < review.ratingStars.count; i++) {
        
        NSString* title = [review.ratingTitles objectAtIndex:i];
        
        UILabel* titleLabel = [UILabel new];
        [titleLabel setTextColor:UIColorFromRGB(0x666666)];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
        [titleLabel setText:title];
        [titleLabel sizeToFit];
        [titleLabel setFrame:CGRectMake(currentX,
                                        currentY,
                                        ratingViewWidth,
                                        titleLabel.frame.size.height)];
        [self addSubview:titleLabel];
        [self.ratingLabels addObject:titleLabel];
        
        NSNumber* average = [review.ratingStars objectAtIndex:i];
        
        JARatingsView* ratingsView = [JARatingsView getNewJARatingsView];
        [ratingsView setRating:[average integerValue]];
        [ratingsView setFrame:CGRectMake(currentX,
                                         currentY + titleLabel.frame.size.height,
                                         ratingsView.frame.size.width,
                                         ratingsView.frame.size.height)];
        [self addSubview:ratingsView];
        [self.ratingStarViews addObject:ratingsView];
        
        currentX += ratingViewWidth;
        
        NSInteger nextIndex = i+1;
        if (nextIndex < review.ratingStars.count) {
            if (0 == nextIndex%3) {
                currentX = kJAReviewCellHorizontalMargins;
                if (0 != nextIndex) {
                    currentY += titleLabel.frame.size.height + ratingsView.frame.size.height;
                }
            }
        } else {
            currentY += 35.0f;
        }
    }
    
    [self.titleLabel removeFromSuperview];
    self.titleLabel = [UILabel new];
    [self.titleLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f]];
    [self.titleLabel setText:review.title];
    [self.titleLabel sizeToFit];
    [self.titleLabel setFrame:CGRectMake(kJAReviewCellHorizontalMargins,
                                         currentY,
                                         self.frame.size.width - (kJAReviewCellHorizontalMargins*2),
                                         self.titleLabel.frame.size.height)];
    [self addSubview:self.titleLabel];
    
    [self.descriptionLabel removeFromSuperview];
    self.descriptionLabel = [UILabel new];
    [self.descriptionLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.descriptionLabel setText:review.comment];
    [self.descriptionLabel setNumberOfLines:0];
    [self.descriptionLabel setFrame:CGRectMake(kJAReviewCellHorizontalMargins,
                                               CGRectGetMaxY(self.titleLabel.frame) + 10.0f,
                                               self.frame.size.width - (kJAReviewCellHorizontalMargins*2),
                                               self.descriptionLabel.frame.size.height)];
    [self.descriptionLabel sizeToFit];
    [self addSubview:self.descriptionLabel];
    
    [self.authorDateLabel removeFromSuperview];
    self.authorDateLabel = [UILabel new];
    [self.authorDateLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.authorDateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f]];
    NSString* authorDateString;
    if (review.userName.length > 0) {
        authorDateString = [NSString stringWithFormat:STRING_POSTED_BY, review.userName, review.dateString];
    } else {
        authorDateString = [NSString stringWithFormat:STRING_POSTED_BY_ANONYMOUS, review.dateString];
    }
    [self.authorDateLabel setText:authorDateString];
    
    [self.authorDateLabel setFrame:CGRectMake(kJAReviewCellHorizontalMargins,
                                              CGRectGetMaxY(self.descriptionLabel.frame) + 10.0f,
                                              self.frame.size.width - (kJAReviewCellHorizontalMargins*2),
                                              self.authorDateLabel.frame.size.height)];
    [self.authorDateLabel sizeToFit];
    [self addSubview:self.authorDateLabel];
    
    [self.separator removeFromSuperview];
    if (showSeparator) {
        self.separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  CGRectGetMaxY(self.authorDateLabel.frame) + 10.0f,
                                                                  self.frame.size.width,
                                                                  1)];
        [self.separator setBackgroundColor:UIColorFromRGB(0xcccccc)];
        [self addSubview:self.separator];
    }
}

+ (CGFloat)cellHeightWithReview:(RIReview*)review
                          width:(CGFloat)width;
{
    CGFloat totalHeight = 0.0f;
    
    NSInteger numberOfRatingLines = ceilf(review.ratingStars.count / 3);
    
    UILabel* ratingLabel = [UILabel new];
    [ratingLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [ratingLabel setText:@"A"];
    [ratingLabel sizeToFit];
    JARatingsView* ratingsView = [JARatingsView getNewJARatingsView];
    [ratingsView setRating:1];
    
    totalHeight += numberOfRatingLines*(ratingLabel.frame.size.height+ratingsView.frame.size.height) + 35.0f;
    
    UILabel* titleLabel = [UILabel new];
    [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f]];
    [titleLabel setText:review.title];
    [titleLabel sizeToFit];
    
    totalHeight += titleLabel.frame.size.height + 10;
    
    UILabel* descriptionLabel = [UILabel new];
    [descriptionLabel setTextColor:UIColorFromRGB(0x666666)];
    [descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [descriptionLabel setText:review.comment];
    [descriptionLabel setNumberOfLines:0];
    [descriptionLabel setFrame:CGRectMake(0.0f,
                                          0.0f,
                                          width,
                                          descriptionLabel.frame.size.height)];
    [descriptionLabel sizeToFit];
    
    totalHeight += descriptionLabel.frame.size.height + 10;
    
    UILabel* authorDateLabel = [UILabel new];
    [authorDateLabel setTextColor:UIColorFromRGB(0x666666)];
    [authorDateLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f]];
    [authorDateLabel setText:@"A"];
    [authorDateLabel setFrame:CGRectMake(0.0f,
                                         0.0f,
                                         width,
                                         authorDateLabel.frame.size.height)];
    [authorDateLabel sizeToFit];
    
    totalHeight += authorDateLabel.frame.size.height + 1; //separator height, plus margin
    
    return totalHeight;
}


@end
