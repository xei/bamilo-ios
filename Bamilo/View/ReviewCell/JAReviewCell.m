//
//  JAReviewCell.m
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAReviewCell.h"

#define kJAReviewCellHorizontalMargins 6.0f

@interface JAReviewCell () {
    JARatingsView *_sellerRatingsView;
    CGFloat _sellerRatingsViewWidth, _sellerRatingsViewHeight;
}

@end

@implementation JAReviewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
    }
    
    return self;
}

- (void)setupWithReview:(RIReview *)review
                  width:(CGFloat)width
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
    
    CGFloat currentX = RI_IS_RTL? width - kJAReviewCellHorizontalMargins: kJAReviewCellHorizontalMargins;
    CGFloat currentY = 6.0f;
    
    int numberOfItemsSideBySide = 3;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
//        if (UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation || UIInterfaceOrientationLandscapeRight == self.interfaceOrientation)
//        {
            numberOfItemsSideBySide = 7;
//        }
    }
    
    CGFloat ratingViewWidth = (width - kJAReviewCellHorizontalMargins) / numberOfItemsSideBySide;
    for (int i = 0; i < review.ratingStars.count; i++) {
        
        NSString* title = [review.ratingTitles objectAtIndex:i];
        
        UILabel* titleLabel = [UILabel new];
        [titleLabel setTextColor:JAGreyColor];
        [titleLabel setFont:[UIFont fontWithName:kFontLightName size:12.0f]];
        [titleLabel setText:title];
        [titleLabel sizeToFit];
        [titleLabel setFrame:CGRectMake(currentX + (RI_IS_RTL?-titleLabel.bounds.size.width:0),
                                        currentY,
                                        ratingViewWidth,
                                        titleLabel.frame.size.height)];
        [self addSubview:titleLabel];
        [self.ratingLabels addObject:titleLabel];
        
        NSNumber* average = [review.ratingStars objectAtIndex:i];
        
        JARatingsView* ratingsView = [JARatingsView getNewJARatingsView];
        [ratingsView setRating:[average integerValue]];
        [ratingsView setFrame:CGRectMake(currentX + (RI_IS_RTL?-ratingsView.bounds.size.width:0),
                                         currentY + titleLabel.frame.size.height,
                                         ratingsView.frame.size.width,
                                         ratingsView.frame.size.height)];
        [self addSubview:ratingsView];
        [self.ratingStarViews addObject:ratingsView];
        
        currentX += RI_IS_RTL?-ratingViewWidth:ratingViewWidth;
        
        NSInteger nextIndex = i+1;
        if (nextIndex < review.ratingStars.count) {
            if (0 == nextIndex%numberOfItemsSideBySide) {
                //                currentX = kJAReviewCellHorizontalMargins;
                currentX = RI_IS_RTL? width - kJAReviewCellHorizontalMargins: kJAReviewCellHorizontalMargins;
                if (0 != nextIndex) {
                    currentY += titleLabel.frame.size.height + ratingsView.frame.size.height;
                }
            }
        } else {
            currentY += 35.0f;
            currentX = RI_IS_RTL? width - kJAReviewCellHorizontalMargins: kJAReviewCellHorizontalMargins;
        }
    }
 
    [self loadBottomOfCellWithY:currentY
                          width:width
                          title:review.title
                        comment:review.comment
                       userName:review.userName
                     dateString:review.dateString
                  showSeparator:showSeparator];
}

- (void)setupWithSellerReview:(RISellerReview*)sellerReview
                  width:(CGFloat)width
                showSeparator:(BOOL)showSeparator;
{
    CGFloat currentY = 8.0f;
    
    if (!_sellerRatingsView) {
        _sellerRatingsView = [JARatingsView getNewJARatingsView];
        [_sellerRatingsView setY:8.f];
        _sellerRatingsViewWidth = _sellerRatingsView.width;
        _sellerRatingsViewHeight = _sellerRatingsView.height;
        [self addSubview:_sellerRatingsView];
    }
    [_sellerRatingsView setRating:[sellerReview.average integerValue]];
    
    [_sellerRatingsView setWidth:_sellerRatingsViewWidth];
    [_sellerRatingsView setHeight:_sellerRatingsViewHeight];
    [_sellerRatingsView setX:RI_IS_RTL?width-_sellerRatingsView.width-kJAReviewCellHorizontalMargins:kJAReviewCellHorizontalMargins];
    
    currentY = _sellerRatingsView.height + 12.0f;
    
    [self loadBottomOfCellWithY:currentY
                          width:width
                          title:sellerReview.title
                        comment:sellerReview.comment
                       userName:sellerReview.userName
                     dateString:sellerReview.dateString
                  showSeparator:showSeparator];
}

-(void)loadBottomOfCellWithY:(CGFloat)currentY
                       width:(CGFloat)width
                       title:(NSString*)title
                     comment:(NSString*)comment
                    userName:(NSString*)userName
                  dateString:(NSString*)dateString
               showSeparator:(BOOL)showSeparator
{
    [self.titleLabel removeFromSuperview];
    self.titleLabel = [UILabel new];
    [self.titleLabel setTextColor:JAGreyColor];
    [self.titleLabel setFont:[UIFont fontWithName:kFontMediumName size:12.0f]];
    [self.titleLabel setText:title];
    [self.titleLabel sizeToFit];
    [self.titleLabel setFrame:CGRectMake(kJAReviewCellHorizontalMargins,
                                         currentY,
                                         width - (kJAReviewCellHorizontalMargins*2),
                                         self.titleLabel.frame.size.height)];
    [self.titleLabel setTextAlignment: RI_IS_RTL ? NSTextAlignmentRight : NSTextAlignmentLeft];
    
    [self addSubview:self.titleLabel];
    
    [self.descriptionLabel removeFromSuperview];
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kJAReviewCellHorizontalMargins,
                                                   CGRectGetMaxY(self.titleLabel.frame) + 10.0f,
                                                   width - (kJAReviewCellHorizontalMargins*2),
                                                   self.descriptionLabel.frame.size.height + 20.f)];
    [self.descriptionLabel setTextColor:JAGreyColor];
    [self.descriptionLabel setFont:[UIFont fontWithName:kFontLightName size:12.0f]];
    [self.descriptionLabel setText:comment];
    [self.descriptionLabel setNumberOfLines:0];
    [self.descriptionLabel sizeToFit];
    if (RI_IS_RTL) {
        [self.descriptionLabel setX:width-kJAReviewCellHorizontalMargins-self.descriptionLabel.width];
        [self.descriptionLabel setTextAlignment:NSTextAlignmentRight];
    }else{
        [self.descriptionLabel setTextAlignment:NSTextAlignmentLeft];
    }
    
    [self addSubview:self.descriptionLabel];
    
    [self.authorDateLabel removeFromSuperview];
    self.authorDateLabel = [UILabel new];
    [self.authorDateLabel setTextColor:JAGreyColor];
    [self.authorDateLabel setFont:[UIFont fontWithName:kFontLightName size:10.0f]];
    NSString* authorDateString;
    if (userName.length > 0) {
        authorDateString = [NSString stringWithFormat:STRING_POSTED_BY, userName, dateString];
    } else {
        authorDateString = [NSString stringWithFormat:STRING_POSTED_BY_ANONYMOUS, dateString];
    }
    [self.authorDateLabel setText:authorDateString];
    
    [self.authorDateLabel setFrame:CGRectMake(kJAReviewCellHorizontalMargins,
                                              CGRectGetMaxY(self.descriptionLabel.frame) + 10.0f,
                                              width - (kJAReviewCellHorizontalMargins*2),
                                              self.authorDateLabel.frame.size.height)];
    [self.authorDateLabel sizeToFit];
    [self.authorDateLabel setFrame:CGRectMake(self.authorDateLabel.frame.origin.x,
                                              self.authorDateLabel.frame.origin.y,
                                              width - (kJAReviewCellHorizontalMargins*2),
                                              self.authorDateLabel.frame.size.height)];
    [self.authorDateLabel setTextAlignment:RI_IS_RTL?NSTextAlignmentRight:NSTextAlignmentLeft];
    
    [self addSubview:self.authorDateLabel];
    
    [self.separator removeFromSuperview];
    if (showSeparator) {
        self.separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  CGRectGetMaxY(self.authorDateLabel.frame) + 10.0f,
                                                                  width,
                                                                  1)];
        [self.separator setBackgroundColor:JATextFieldColor];
        [self addSubview:self.separator];
    }
}

+ (CGFloat)cellHeightWithReview:(RIReview*)review
                          width:(CGFloat)width;
{
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kJAReviewCellHorizontalMargins, 0, width - 2*kJAReviewCellHorizontalMargins, 500)];
    [descriptionLabel setTextColor:JAGreyColor];
    [descriptionLabel setFont:[UIFont fontWithName:kFontLightName size:12.0f]];
    [descriptionLabel setText:review.comment];
    [descriptionLabel setNumberOfLines:0];
    [descriptionLabel sizeToFit];

    return descriptionLabel.frame.size.height + 100.f;
}

+ (CGFloat)cellHeightWithSellerReview:(RISellerReview*)sellerReview
                                width:(CGFloat)width;
{
    CGFloat currentY = 8.0f;
    
    JARatingsView* ratingsView = [JARatingsView getNewJARatingsView];
    [ratingsView setRating:1];
    
    currentY += ratingsView.frame.size.height + 6.0f;
    
    return [JAReviewCell cellHeightForBottomOfCellWithPreviousHeight:currentY
                                                               width:width
                                                               title:sellerReview.title
                                                             comment:sellerReview.comment];
}

+(CGFloat)cellHeightForBottomOfCellWithPreviousHeight:(CGFloat)previousHeight
                                                width:(CGFloat)width
                                                title:(NSString*)title
                                              comment:(NSString*)comment
{
    CGFloat totalHeight = previousHeight;
    
    UILabel* titleLabel = [UILabel new];
    [titleLabel setFont:[UIFont fontWithName:kFontMediumName size:12.0f]];
    [titleLabel setText:title];
    [titleLabel sizeToFit];
    
    totalHeight += titleLabel.frame.size.height + 10;
    
    UILabel* descriptionLabel = [UILabel new];
    [descriptionLabel setTextColor:JAGreyColor];
    [descriptionLabel setFont:[UIFont fontWithName:kFontLightName size:12.0f]];
    [descriptionLabel setText:comment];
    [descriptionLabel setNumberOfLines:0];
    [descriptionLabel setFrame:CGRectMake(0.0f,
                                          0.0f,
                                          width,
                                          descriptionLabel.frame.size.height)];
    [descriptionLabel sizeToFit];
    
    totalHeight += descriptionLabel.frame.size.height + 10;
    
    UILabel* authorDateLabel = [UILabel new];
    [authorDateLabel setTextColor:JAGreyColor];
    [authorDateLabel setFont:[UIFont fontWithName:kFontLightName size:10.0f]];
    [authorDateLabel setText:@"A"];
    [authorDateLabel setFrame:CGRectMake(0.0f,
                                         0.0f,
                                         width,
                                         authorDateLabel.frame.size.height)];
    [authorDateLabel sizeToFit];
    
    totalHeight += authorDateLabel.frame.size.height + 10; //separator height, plus margin
    
    return totalHeight;
}

@end
