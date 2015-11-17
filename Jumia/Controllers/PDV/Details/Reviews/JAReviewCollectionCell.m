//
//  JAReviewCollectionCell.m
//  Jumia
//
//  Created by josemota on 10/16/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAReviewCollectionCell.h"
#import "JAProductInfoRatingLine.h"
#import "JAClickableView.h"

#define kXOffset 16

@interface JAReviewCollectionCell () {
    CGFloat _descriptionLabelInitWidth;
}

@property (nonatomic, strong) JAClickableView *clickableArea;
@property (nonatomic, strong) NSArray *ratingStarViews;
@property (nonatomic, strong) NSArray *ratingLabels;
@property (nonatomic, strong) UIView *ratingsView;
@property (nonatomic, strong) NSMutableDictionary *ratings;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIView *separator;

@end

@implementation JAReviewCollectionCell

- (JAClickableView *)clickableArea
{
    if (!VALID_NOTEMPTY(_clickableArea, JAClickableView)) {
        _clickableArea = [[JAClickableView alloc] initWithFrame:self.bounds];
        [self addSubview:_clickableArea];
    }
    return _clickableArea;
}

- (UIView *)ratingsView
{
    CGRect frame = CGRectMake(0, 18, self.width - self.dateLabel.width, 70);
    if (!VALID_NOTEMPTY(_ratingsView, UIView)) {
        _ratingsView = [[UIView alloc] initWithFrame:frame];
        [self.clickableArea addSubview:_ratingsView];
    }else if (!CGRectEqualToRect(_ratingsView.frame, frame))
    {
        [_ratingsView setFrame:frame];
    }
    return _ratingsView;
}

- (UILabel *)getNewRatingCategoryLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    [label setFont:JABody3Font];
    [label setTextColor:JABlack800Color];
    return label;
}

- (JAProductInfoRatingLine *)getNewRatingLine
{
    JAProductInfoRatingLine *ratingLine = [[JAProductInfoRatingLine alloc] initWithFrame:CGRectMake(kXOffset, 0, 100, 50)];
    [ratingLine setImageRatingSize:kImageRatingSizeSmall];
    [ratingLine setHeight:ratingLine.imageHeight];
    [ratingLine setLineContentXOffset:0.f];
    [ratingLine setTopSeparatorVisibility:NO];
    [ratingLine setBottomSeparatorVisibility:NO];
    return ratingLine;
}

- (NSMutableDictionary *)ratings
{
    if (!VALID_NOTEMPTY(_ratings, NSMutableDictionary)) {
        _ratings = [NSMutableDictionary new];
    }
    return _ratings;
}

- (UILabel *)dateLabel
{
    if (!VALID_NOTEMPTY(_dateLabel, UILabel)) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kXOffset, 18, self.width - 32, 20)];
        [_dateLabel setFont:JABody3Font];
        [_dateLabel setTextColor:JABlack800Color];
        [self.clickableArea addSubview:_dateLabel];
    }
    return _dateLabel;
}

- (UILabel *)titleLabel
{
    CGRect frame = CGRectMake(kXOffset, CGRectGetMaxY(self.ratingsView.frame) + 10.f, self.width - 32, 20);
    if (!VALID_NOTEMPTY(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:frame];
        [_titleLabel setFont:JAList1Font];
        [_titleLabel setTextColor:JABlack900Color];
        [self.clickableArea addSubview:_titleLabel];
    }else if (CGRectEqualToRect(frame, _titleLabel.frame))
    {
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setFrame:frame];
    }
    return _titleLabel;
}

- (UILabel *)authorLabel
{
    CGRect frame = CGRectMake(kXOffset, CGRectGetMaxY(self.titleLabel.frame), self.width - 32, 20);
    if (!VALID_NOTEMPTY(_authorLabel, UILabel)) {
        _authorLabel = [[UILabel alloc] initWithFrame:frame];
        [_authorLabel setFont:JABody3Font];
        [_authorLabel setTextColor:JABlack800Color];
        [self.clickableArea addSubview:_authorLabel];
    }else if (CGRectEqualToRect(frame, _authorLabel.frame)) {
        [_authorLabel setTextAlignment:NSTextAlignmentLeft];
        [_authorLabel setFrame:frame];
    }
    return _authorLabel;
}

- (UILabel *)descriptionLabel
{
    if (!VALID_NOTEMPTY(_descriptionLabel, UILabel)) {
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kXOffset, CGRectGetMaxY(self.authorLabel.frame) + 16, self.width - 32, 20)];
        [_descriptionLabel setFont:JABody3Font];
        [_descriptionLabel setTextColor:JABlack800Color];
        [_descriptionLabel setNumberOfLines:0];
        [self.clickableArea addSubview:_descriptionLabel];
    }else if (_descriptionLabel.x != kXOffset) {
        [_descriptionLabel setX:kXOffset];
    }
    return _descriptionLabel;
}

- (UIView *)separator
{
    if (!VALID_NOTEMPTY(_separator, UIView)) {
        _separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, 1)];
        [_separator setBackgroundColor:JABlack800Color];
        [self.clickableArea addSubview:_separator];
    }
    return _separator;
}

- (void)setRatingStars:(NSArray *)ratingStarViews
{
    self.ratingStarViews = ratingStarViews;
    for (UIView *subView in self.ratingsView.subviews)
    {
        [subView removeFromSuperview];
    }
    if (ratingStarViews.count == 1) {
        NSNumber *number = [ratingStarViews firstObject];
        JAProductInfoRatingLine *line = [self getNewRatingLine];
        [line setX:kXOffset];
        [line setRatingAverage:number];
        [line setHiddenSum:YES];
        [self.ratingsView setHeight:CGRectGetMaxY(line.frame)];
        [self.ratingsView addSubview:line];
        [self.ratings setObject:line forKey:@""];
        return;
    }
    int index = 0;
    for (;index < ratingStarViews.count; index++) {
        NSString *title = [self.ratingLabels objectAtIndex:index];
        NSNumber *number = [ratingStarViews objectAtIndex:index];
        
        UILabel *label = [self getNewRatingCategoryLabel];
        [label setX:kXOffset + index*100];
        [label setText:title];
        [self.ratingsView addSubview:label];
        JAProductInfoRatingLine *line = [self getNewRatingLine];
        [line setX:kXOffset + index*100];
        [line setY:CGRectGetMaxY(label.frame)];
        [line setRatingAverage:number];
        [self.ratingsView setHeight:CGRectGetMaxY(line.frame)];
        [self.ratingsView addSubview:line];
        [self.ratings setObject:line forKey:title];
    }
}

- (CGFloat)getDescriptionLabelInitWidth
{
    return self.width - 2*kXOffset;
}

- (void)setupWithReview:(RIReview *)review width:(CGFloat)width showSeparator:(BOOL)showSeparator
{
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setWidth:width];
    
    [self setRatingLabels:review.ratingTitles];
    [self setRatingStars:review.ratingStars];
    
    [self.dateLabel setText:review.dateString];
    [self.dateLabel sizeToFit];
    [self.dateLabel setXRightAligned:16.f];
    [self.titleLabel setText:review.title];
    [self.authorLabel setText:[NSString stringWithFormat:STRING_BY_SOMEONE, review.userName]];
    [self.descriptionLabel setWidth:[self getDescriptionLabelInitWidth]];
    [self.descriptionLabel setText:review.comment];
    [self.descriptionLabel sizeToFit];
    
    [self setHeight:CGRectGetMaxY(self.descriptionLabel.frame) + 18];
    
    [self.clickableArea setFrame:self.bounds];
    
    if (showSeparator) {
        [self.separator setHidden:NO];
        [self.separator setWidth:self.width];
    }else{
        [self.separator setHidden:YES];
    }
    [self.separator setYBottomAligned:1];
}

+ (CGFloat)cellHeightWithReview:(RIReview *)review width:(CGFloat)width
{
    JAReviewCollectionCell *cell = [JAReviewCollectionCell new];
    [cell setupWithReview:review width:width showSeparator:YES];
    return cell.height;
}

- (void)addTarget:(id)target action:(nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.clickableArea addTarget:target action:action forControlEvents:controlEvents];
}

@end
