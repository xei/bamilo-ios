//
//  JAProductReviewsView.m
//  Jumia
//
//  Created by josemota on 10/13/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductReviewsView.h"
#import "JAProductInfoHeaderLine.h"

#define kLeftSidePercentage 0.5f
#define kBarWidth 85

@interface JAProductReviewsView ()
{
    NSDictionary *_ratingsDictionary;
}

@property (nonatomic) UIScrollView *contentScrollView;

@property (nonatomic) JAProductInfoHeaderLine *ratingsHeaderLine;
@property (nonatomic) UIView *ratingsView;
@property (nonatomic) UILabel *averageTitleLabel;
@property (nonatomic) UILabel *averageValueLabel;
@property (nonatomic) UILabel *totalUsersLabel;
@property (nonatomic) UIView *verticalSeparator;
@property (nonatomic) UIView *ratingsRightSideView;
@property (nonatomic) NSDictionary *starsViewDictionary;
@property (nonatomic) NSDictionary *starsTotalLabelDictionary;

@property (nonatomic) JAProductInfoHeaderLine *reviewsHeaderLine;
@property (nonatomic) UICollectionView *collectionView;

@end

@implementation JAProductReviewsView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults
{
}

- (UIScrollView *)contentScrollView
{
    CGRect frame = CGRectMake(0, 0, self.width, self.height);
    if (!VALID_NOTEMPTY(_contentScrollView, UIScrollView)) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:frame];
    }else if (!CGRectEqualToRect(frame, _contentScrollView.frame))
    {
        [_contentScrollView setFrame:frame];
        [self ratingsHeaderLine];
        [self ratingsView];
        [self reviewsHeaderLine];
        [self collectionView];
    }
    return _contentScrollView;
}

- (UIView *)ratingsView
{
    CGRect frame = CGRectMake(16, CGRectGetMaxY(self.ratingsHeaderLine.frame) + 16.f, self.contentScrollView.width - 32, 100);
    if (!VALID_NOTEMPTY(_ratingsView, UIView)) {
        _ratingsView = [[UIView alloc] initWithFrame:frame];
        [_ratingsView addSubview:self.averageTitleLabel];
        [_ratingsView addSubview:self.averageValueLabel];
        [_ratingsView addSubview:self.totalUsersLabel];
        [_ratingsView addSubview:self.verticalSeparator];
        [_ratingsView addSubview:self.ratingsRightSideView];
    }else if (!CGRectEqualToRect(frame, _ratingsView.frame)) {
        [_ratingsView setFrame:frame];
        [self averageTitleLabel];
        [self averageValueLabel];
        [self totalUsersLabel];
        [self verticalSeparator];
        [self ratingsRightSideView];
    }
    return _ratingsView;
}

- (UILabel *)averageTitleLabel
{
    CGRect frame = CGRectMake(_ratingsView.width * kLeftSidePercentage - 150, 0, 150, 30);
    if (!VALID_NOTEMPTY(_averageTitleLabel, UIView)) {
        _averageTitleLabel = [[UILabel alloc] initWithFrame:frame];
        [_averageTitleLabel setFont:JABody2Font];
        [_averageTitleLabel setTextColor:JABlackColor];
        [_averageTitleLabel setTextAlignment:NSTextAlignmentCenter];
#warning TODO String
        [_averageTitleLabel setText:@"Average Rating"];
    }else if (!CGRectEqualToRect(frame, _averageTitleLabel.frame)) {
        [_averageTitleLabel setFrame:frame];
    }
    return _averageTitleLabel;
}

- (UILabel *)averageValueLabel
{
    CGRect frame = CGRectMake(_ratingsView.width*kLeftSidePercentage - 150, CGRectGetMaxY(_averageTitleLabel.frame), 150, 40);
    if (!VALID_NOTEMPTY(_averageValueLabel, UILabel)) {
        _averageValueLabel = [[UILabel alloc] initWithFrame:frame];
        [_averageValueLabel setFont:JADisplay1Font];
        [_averageValueLabel setTextColor:JABlack800Color];
        [_averageValueLabel setTextAlignment:NSTextAlignmentCenter];
        [_averageValueLabel setText:[NSString stringWithFormat:@"%.1f / 5", self.product.avr.floatValue]];
    }else if (!CGRectEqualToRect(frame, _averageValueLabel.frame)) {
        [_averageValueLabel setFrame:frame];
    }
    return _averageValueLabel;
}

- (UILabel *)totalUsersLabel
{
    CGRect frame = CGRectMake(_ratingsView.width*kLeftSidePercentage - 150, CGRectGetMaxY(_averageValueLabel.frame), 150, 30);
    if (!VALID_NOTEMPTY(_totalUsersLabel, UILabel)) {
        _totalUsersLabel = [[UILabel alloc] initWithFrame:frame];
        [_totalUsersLabel setFont:JACaptionFont];
        [_totalUsersLabel setTextColor:JABlack800Color];
        [_totalUsersLabel setTextAlignment:NSTextAlignmentCenter];
    #warning TODO String
        [_totalUsersLabel setText:[NSString stringWithFormat:@"from %d customers", self.product.sum.intValue]];
    }else if (!CGRectEqualToRect(frame, _totalUsersLabel.frame)) {
        [_totalUsersLabel setFrame:frame];
    }
    return _totalUsersLabel;
}

- (UIView *)verticalSeparator
{
    CGRect frame = CGRectMake(_ratingsView.width*kLeftSidePercentage, 0, 2.f, CGRectGetMaxY(_totalUsersLabel.frame));
    if (!VALID_NOTEMPTY(_verticalSeparator, UIView)) {
        _verticalSeparator = [[UIView alloc] initWithFrame:frame];
        [_verticalSeparator setBackgroundColor:JABlack300Color];
    }else if (!CGRectEqualToRect(frame, _verticalSeparator.frame)) {
        [_verticalSeparator setFrame:frame];
    }
    return _verticalSeparator;
}

- (UIView *)ratingsRightSideView
{
    CGRect frame = CGRectMake(_ratingsView.width*kLeftSidePercentage, 0, _ratingsView.width - _ratingsView.width*kLeftSidePercentage, _ratingsView.height);
    if (!VALID_NOTEMPTY(_ratingsRightSideView, UIView)) {
        _ratingsRightSideView = [[UIView alloc] initWithFrame:frame];
        [self setGraphicSide];
    }else if (!CGRectEqualToRect(frame, _ratingsRightSideView.frame)) {
        [_ratingsRightSideView setFrame:frame];
        for (UIView *view in _ratingsRightSideView.subviews) {
            [view removeFromSuperview];
        }
        [self setGraphicSide];
    }
    return _ratingsRightSideView;
}

- (JAProductInfoHeaderLine *)ratingsHeaderLine
{
    CGRect frame = CGRectMake(0, 0, self.width, kProductInfoHeaderLineHeight);
    if (!VALID_NOTEMPTY(_ratingsHeaderLine, JAProductInfoHeaderLine)) {
        _ratingsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:frame];
        [_ratingsHeaderLine setTopSeparatorVisibility:NO];
#warning TODO String
        [_ratingsHeaderLine setTitle:[@"RATINGS" uppercaseString]];
    }else if (!CGRectEqualToRect(frame, _ratingsHeaderLine.frame)){
        [_ratingsHeaderLine setFrame:frame];
    }
    return _ratingsHeaderLine;
}

- (JAProductInfoHeaderLine *)reviewsHeaderLine
{
    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.ratingsView.frame) + 16.f, self.width, kProductInfoHeaderLineHeight);
    if (!VALID_NOTEMPTY(_reviewsHeaderLine, JAProductInfoHeaderLine)) {
        _reviewsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:frame];
        [_reviewsHeaderLine setTopSeparatorVisibility:NO];
#warning TODO String
        [_reviewsHeaderLine setTitle:[@"RATINGS" uppercaseString]];
    }else if (!CGRectEqualToRect(frame, _reviewsHeaderLine.frame)) {
        [_reviewsHeaderLine setFrame:frame];
    }
    return _reviewsHeaderLine;
}

- (void)setGraphicSide
{
    UILabel *label5 = [self getNumbersLabel];
    [label5 setText:@"5"];
    [_ratingsRightSideView addSubview:label5];
    UILabel *labelTotal5 = [self getNumbersTotalLabel];
    [labelTotal5 setY:label5.y];
    [labelTotal5 setText:@"(0)"];
    [_ratingsRightSideView addSubview:labelTotal5];
    UIView *emptyGraphic5 = [self getEmptyGraphic];
    [emptyGraphic5 setY:label5.y + (label5.height - emptyGraphic5.height)/2];
    [_ratingsRightSideView addSubview:emptyGraphic5];
    UIView *graphic5 = [self getGraphic];
    [graphic5 setY:label5.y + (label5.height - graphic5.height)/2];
    [_ratingsRightSideView addSubview:graphic5];
    
    UILabel *label4 = [self getNumbersLabel];
    [label4 setText:@"4"];
    [label4 setYBottomOf:label5 at:0.f];
    [_ratingsRightSideView addSubview:label4];
    UILabel *labelTotal4 = [self getNumbersTotalLabel];
    [labelTotal4 setY:label4.y];
    [labelTotal4 setText:@"(0)"];
    [_ratingsRightSideView addSubview:labelTotal4];
    UIView *emptyGraphic4 = [self getEmptyGraphic];
    [emptyGraphic4 setY:label4.y + (label4.height - emptyGraphic4.height)/2];
    [_ratingsRightSideView addSubview:emptyGraphic4];
    UIView *graphic4 = [self getGraphic];
    [graphic4 setY:label4.y + (label4.height - graphic4.height)/2];
    [_ratingsRightSideView addSubview:graphic4];
    
    UILabel *label3 = [self getNumbersLabel];
    [label3 setText:@"3"];
    [label3 setYBottomOf:label4 at:0.f];
    [_ratingsRightSideView addSubview:label3];
    UILabel *labelTotal3 = [self getNumbersTotalLabel];
    [labelTotal3 setY:label3.y];
    [labelTotal3 setText:@"(0)"];
    [_ratingsRightSideView addSubview:labelTotal3];
    UIView *emptyGraphic3 = [self getEmptyGraphic];
    [emptyGraphic3 setY:label3.y + (label3.height - emptyGraphic3.height)/2];
    [_ratingsRightSideView addSubview:emptyGraphic3];
    UIView *graphic3 = [self getGraphic];
    [graphic3 setY:label3.y + (label3.height - graphic3.height)/2];
    [_ratingsRightSideView addSubview:graphic3];
    
    UILabel *label2 = [self getNumbersLabel];
    [label2 setText:@"2"];
    [label2 setYBottomOf:label3 at:0.f];
    [_ratingsRightSideView addSubview:label2];
    UILabel *labelTotal2 = [self getNumbersTotalLabel];
    [labelTotal2 setY:label2.y];
    [labelTotal2 setText:@"(0)"];
    [_ratingsRightSideView addSubview:labelTotal2];
    UIView *emptyGraphic2 = [self getEmptyGraphic];
    [emptyGraphic2 setY:label2.y + (label2.height - emptyGraphic2.height)/2];
    [_ratingsRightSideView addSubview:emptyGraphic2];
    UIView *graphic2 = [self getGraphic];
    [graphic2 setY:label2.y + (label2.height - graphic2.height)/2];
    [_ratingsRightSideView addSubview:graphic2];
    
    UILabel *label1 = [self getNumbersLabel];
    [label1 setText:@"1"];
    [label1 setYBottomOf:label2 at:0.f];
    [_ratingsRightSideView addSubview:label1];
    UILabel *labelTotal1 = [self getNumbersTotalLabel];
    [labelTotal1 setY:label1.y];
    [labelTotal1 setText:@"(0)"];
    [_ratingsRightSideView addSubview:labelTotal1];
    UIView *emptyGraphic1 = [self getEmptyGraphic];
    [emptyGraphic1 setY:label1.y + (label1.height - emptyGraphic1.height)/2];
    [_ratingsRightSideView addSubview:emptyGraphic1];
    UIView *graphic1 = [self getGraphic];
    [graphic1 setY:label1.y + (label1.height - graphic1.height)/2];
    [_ratingsRightSideView addSubview:graphic1];
    
    self.starsViewDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:graphic1, graphic2, graphic3, graphic4, graphic5, nil] forKeys:[NSArray arrayWithObjects:@1, @2, @3, @4, @5, nil]];
    self.starsTotalLabelDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:labelTotal1, labelTotal2, labelTotal3, labelTotal4, labelTotal5, nil] forKeys:[NSArray arrayWithObjects:@1, @2, @3, @4, @5, nil]];
    
    [_ratingsView setHeight:CGRectGetMaxY(self.verticalSeparator.frame) + 16.f];
    
    if (_ratingsDictionary) {
        [self fillGraphics];
    }
}

- (void)setProduct:(RIProduct *)product
{
    _product = product;
    
    [RIProduct getRatingsDetails:_product.sku successBlock:^(NSDictionary *ratingsDictionary) {
        _ratingsDictionary = ratingsDictionary;
        [self fillGraphics];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        
    }];
    
    [self addSubview:self.contentScrollView];
    CGFloat yOffset = 0.f;
    [self.ratingsHeaderLine setTitle:[NSString stringWithFormat:@"RATINGS (%d)", _product.sum.intValue]];
    [self.ratingsHeaderLine setY:yOffset];
    [self.contentScrollView addSubview:self.ratingsHeaderLine];
    yOffset = CGRectGetMaxY(self.ratingsHeaderLine.frame);
    
    [self.contentScrollView addSubview:self.ratingsView];
    yOffset = CGRectGetMaxY(self.ratingsView.frame);
    
    [self.reviewsHeaderLine setTitle:[NSString stringWithFormat:@"USER REVIEWS (%d)", _product.reviewsTotal.intValue]];
    [self.reviewsHeaderLine setY:yOffset];
    [self.contentScrollView addSubview:self.reviewsHeaderLine];
    yOffset = CGRectGetMaxY(self.reviewsHeaderLine.frame);
    
}

- (UILabel *)getNumbersLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16.f, 14, 10.f, 15.f)];
    [label setFont:JACaptionFont];
    [label setTextColor:JABlackColor];
    return label;
}

- (UILabel *)getNumbersTotalLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self getEmptyGraphic].frame) + 16.f, 14, 20.f, 15.f)];
    [label setFont:JACaptionFont];
    [label setTextColor:JABlackColor];
    return label;
}

- (UIView *)getEmptyGraphic
{
    UIView *graphic = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self getNumbersLabel].frame) + 6.f, 0, kBarWidth, 6.f)];
    [graphic setBackgroundColor:JABlack300Color];
    return graphic;
}

- (UIView *)getGraphic
{
    UIView *graphic = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX([self getNumbersLabel].frame) + 6.f, 0, kBarWidth, 6.f)];
    [graphic setBackgroundColor:JAOrange1Color];
    [graphic setHidden:YES];
    return graphic;
}

- (void)fillGraphics
{
    for (NSNumber *starNumber in [self.starsViewDictionary allKeys]) {
        UIView *graphic = [self.starsViewDictionary objectForKey:starNumber];
        UILabel *label = [self.starsTotalLabelDictionary objectForKey:starNumber];
        if ([_ratingsDictionary objectForKey:[NSString stringWithFormat:@"%d", starNumber.intValue]]) {
            NSNumber *sum = [_ratingsDictionary objectForKey:[NSString stringWithFormat:@"%d", starNumber.intValue]];
            CGFloat full = graphic.width;
            [graphic setWidth:0];
            [graphic setHidden:NO];
            [UIView animateWithDuration:.3 animations:^{
                [graphic setWidth:full*sum.intValue/self.product.sum.intValue];
            }];
            [label setText:[NSString stringWithFormat:@"(%d)", sum.intValue]];
        }else{
            [graphic setWidth:0.f];
            [label setText:@"(0)"];
        }
        [graphic setHidden:NO];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self contentScrollView];
}

@end
