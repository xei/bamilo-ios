//
//  JAProductReviewsView.m
//  Jumia
//
//  Created by josemota on 10/13/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductReviewsView.h"
#import "JAProductInfoHeaderLine.h"
#import "RIProductRatings.h"
#import "JAReviewCollectionCell.h"

#define kLeftSidePercentage 0.5f
#define kBarWidth 85

@interface JAProductReviewsView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSDictionary *_ratingsDictionary;
    NSInteger _currentPage;
}

@property (nonatomic) UIView *topView;

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
@property (nonatomic) RIProductRatings *productRatings;
@property (nonatomic) NSMutableArray *reviewsArray;

@property (nonatomic) UIView *writeReviewView;
@property (nonatomic) UILabel *writeReviewLabel;
@property (nonatomic) UIButton *writeReviewButton;

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

- (UIView *)topView
{
    CGRect frame = CGRectMake(0, 0, self.collectionView.width, CGRectGetMaxY(_reviewsHeaderLine.frame));
    if (!VALID_NOTEMPTY(_topView, UIView)) {
        _topView = [[UIView alloc] initWithFrame:frame];
        [_topView setBackgroundColor:[UIColor whiteColor]];
        [self ratingsHeaderLine];
        [self ratingsView];
        [self reviewsHeaderLine];
        [self writeReviewView];
//        if (RI_IS_RTL) {
//            [_topView flipAllSubviews];
//        }
    }else if (!CGRectEqualToRect(_topView.frame, frame))
    {
        [_topView setFrame:frame];
        [self ratingsHeaderLine];
        [self ratingsView];
        [self reviewsHeaderLine];
        [self writeReviewView];
        if (RI_IS_RTL) {
            [_topView flipAllSubviews];
        }
    }
    return _topView;
}

- (UICollectionView *)collectionView
{
    if (!VALID_NOTEMPTY(_collectionView, UICollectionView)) {
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setMinimumInteritemSpacing:0];
        [layout setMinimumLineSpacing:10];
        //                                      top, left, bottom, right
        [layout setSectionInset:UIEdgeInsetsMake(0.f, 0.0, 10.0, 0.0)];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [_collectionView setBackgroundColor:UIColorFromRGB(0xf0f0f0)];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[JAReviewCollectionCell class] forCellWithReuseIdentifier:@"JAReviewCollectionCell"];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"topView"];
        [self addSubview:_collectionView];
    }else if (!CGRectEqualToRect(_collectionView.frame, self.bounds))
    {
        [_collectionView setFrame:self.bounds];
        [_collectionView reloadData];
    }
    return _collectionView;
}

- (void)setDefaults
{
}

- (UIView *)ratingsView
{
    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.ratingsHeaderLine.frame) + 16.f, _topView.width - 32, 180);
    if (!VALID_NOTEMPTY(_ratingsView, UIView)) {
        _ratingsView = [[UIView alloc] initWithFrame:frame];
        [_ratingsView addSubview:self.averageTitleLabel];
        [_ratingsView addSubview:self.averageValueLabel];
        [_ratingsView addSubview:self.totalUsersLabel];
        [_ratingsView addSubview:self.verticalSeparator];
        [_ratingsView addSubview:self.ratingsRightSideView];
        [_ratingsView addSubview:self.writeReviewView];
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
        [_averageTitleLabel setText:STRING_AVERAGE_RATING];
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
        [_totalUsersLabel setText:[NSString stringWithFormat:STRING_FROM_N_CUSTOMERS, self.product.sum.intValue]];
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
    CGRect frame = CGRectMake(0, 0, self.topView.width, kProductInfoHeaderLineHeight);
    if (!VALID_NOTEMPTY(_ratingsHeaderLine, JAProductInfoHeaderLine)) {
        _ratingsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:frame];
        [_ratingsHeaderLine setTopSeparatorVisibility:NO];
    }else if (!CGRectEqualToRect(frame, _ratingsHeaderLine.frame)){
        [_ratingsHeaderLine setFrame:frame];
    }
    return _ratingsHeaderLine;
}

- (JAProductInfoHeaderLine *)reviewsHeaderLine
{
    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.ratingsView.frame) + 16.f, _topView.width, kProductInfoHeaderLineHeight);
    if (!VALID_NOTEMPTY(_reviewsHeaderLine, JAProductInfoHeaderLine)) {
        _reviewsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:frame];
        [_reviewsHeaderLine setTopSeparatorVisibility:NO];
    }else if (!CGRectEqualToRect(frame, _reviewsHeaderLine.frame)) {
        [_reviewsHeaderLine setFrame:frame];
    }
    return _reviewsHeaderLine;
}

- (UIView *)writeReviewView
{
    CGRect frame = CGRectMake(_topView.width/2 - 160, CGRectGetMaxY(self.verticalSeparator.frame), 320, 80);
    if (!VALID_NOTEMPTY(_writeReviewView, UIView)) {
        _writeReviewView = [[UIView alloc] initWithFrame:frame];
        [_writeReviewView addSubview:self.writeReviewLabel];
        [_writeReviewView addSubview:self.writeReviewButton];
    }else if (!CGRectEqualToRect(frame, _writeReviewView.frame))
    {
        [_writeReviewView setFrame:frame];
        [self writeReviewLabel];
        [self writeReviewButton];
    }
    return _writeReviewView;
}

- (UILabel *)writeReviewLabel
{
    CGRect frame = CGRectMake(0, 10, _writeReviewView.width/2, _writeReviewView.height);
    if (!VALID_NOTEMPTY(_writeReviewLabel, UILabel)) {
        _writeReviewLabel = [[UILabel alloc] initWithFrame:frame];
        [_writeReviewLabel setFont:JABody3Font];
        [_writeReviewLabel setTextColor:JABlack800Color];
        [_writeReviewLabel setTextAlignment:NSTextAlignmentCenter];
        [_writeReviewLabel setNumberOfLines:2];
        [_writeReviewLabel setText:STRING_RATE_NOW];
    }else if (!CGRectEqualToRect(frame, _writeReviewView.frame)) {
        [_writeReviewLabel setFrame:frame];
    }
    return _writeReviewLabel;
}

- (UIButton *)writeReviewButton
{
    CGRect frame = CGRectMake(_writeReviewView.width/2, 10, _writeReviewView.width/2, _writeReviewView.height);
    if (!VALID_NOTEMPTY(_writeReviewButton, UIButton)) {
        _writeReviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_writeReviewButton setTitleColor:JAOrange1Color forState:UIControlStateNormal];
        [_writeReviewButton setTitleColor:JABlack800Color forState:UIControlStateHighlighted];
        [_writeReviewButton setFrame:frame];
        [_writeReviewButton setTitle:STRING_WRITE_REVIEW forState:UIControlStateNormal];
        [_writeReviewButton addTarget:self action:@selector(goToNewReview:) forControlEvents:UIControlEventTouchUpInside];
    }else if (!CGRectEqualToRect(frame, _writeReviewButton.frame)) {
        [_writeReviewButton setFrame:frame];
    }
    return _writeReviewButton;
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
    
    if (_ratingsDictionary) {
        [self fillGraphics];
    }
}

- (void)setProduct:(RIProduct *)product
{
    _product = product;
    
    [self setBackgroundColor:[UIColor whiteColor]];

    [self requestRatings];
    [self requestReviews];
    
    CGFloat yOffset = 0.f;
    [self.ratingsHeaderLine setTitle:[NSString stringWithFormat:STRING_NRATINGS, _product.sum.intValue]];
    [self.ratingsHeaderLine setY:yOffset];
    [self.topView addSubview:self.ratingsHeaderLine];
    yOffset = CGRectGetMaxY(self.ratingsHeaderLine.frame);
    
    [self.topView addSubview:self.ratingsView];
    yOffset = CGRectGetMaxY(self.ratingsView.frame);
    
    [self.reviewsHeaderLine setTitle:[NSString stringWithFormat:@"%@ (%d)", [STRING_USER_REVIEWS uppercaseString],_product.reviewsTotal.intValue]];
    [self.reviewsHeaderLine setY:yOffset];
    [self.topView addSubview:self.reviewsHeaderLine];
    yOffset = CGRectGetMaxY(self.reviewsHeaderLine.frame);
}

- (void)setProductRatings:(RIProductRatings *)productRatings
{
    _productRatings = productRatings;
    [self.collectionView reloadData];
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

- (NSMutableArray *)reviewsArray
{
    if (!VALID(_reviewsArray, NSMutableArray)) {
        _reviewsArray = [NSMutableArray new];
    }
    return _reviewsArray;
}

- (void)requestRatings
{
    [self.viewControllerEvents showLoading];
    [RIProductRatings getRatingsDetails:_product.sku successBlock:^(NSDictionary *ratingsDictionary) {
        _ratingsDictionary = ratingsDictionary;
        [self fillGraphics];
        [self.viewControllerEvents hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
        
        if(RIApiResponseSuccess != apiResponse)
        {
            if (RIApiResponseNoInternetConnection == apiResponse)
            {
                [self.viewControllerEvents showErrorView:YES startingY:0.0f selector:@selector(requestRatings) objects:nil];
            }
            else
            {
                [self.viewControllerEvents showErrorView:NO startingY:0.0f selector:@selector(requestRatings) objects:nil];
            }
        }
        [self.viewControllerEvents hideLoading];
    }];
}

- (void)requestReviews
{
    [self.viewControllerEvents showLoading];
    [RIProductRatings getRatingsForProductWithSku:self.product.sku allowRating:1 pageNumber:(VALID_NOTEMPTY(self.productRatings, RIProductRatings)?self.productRatings.currentPage.intValue+1:1) successBlock:^(RIProductRatings *ratings) {
        self.productRatings = ratings;
        [self.reviewsArray addObjectsFromArray:[self.productRatings.reviews mutableCopy]];
        _currentPage = self.productRatings.currentPage.integerValue;
        [self.collectionView reloadData];
        [self.viewControllerEvents hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        if(RIApiResponseSuccess != apiResponse)
        {
            if (RIApiResponseNoInternetConnection == apiResponse)
            {
                [self.viewControllerEvents showErrorView:YES startingY:0.0f selector:@selector(requestReviews) objects:nil];
            }
            else
            {
                [self.viewControllerEvents showErrorView:NO startingY:0.0f selector:@selector(requestReviews) objects:nil];
            }
        }
        [self.viewControllerEvents hideLoading];
    }];
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
            [label sizeToFit];

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
    [self collectionView];
    if (RI_IS_RTL)
    {
        [self.collectionView flipAllSubviews];
    }
}

#pragma mark - Action

- (void)goToNewReview:(id)sender
{
    NSMutableDictionary *userInfo =  [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(self.product, RIProduct))
    {
        [userInfo setObject:self.product forKey:@"product"];
    }
    
    if(VALID_NOTEMPTY(self.productRatings, RIProductRatings))
    {
        [userInfo setObject:self.productRatings forKey:@"productRatings"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowNewRatingScreenNotification object:nil userInfo:userInfo];
}

#pragma mark - CollectionView

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger arrayIndex = indexPath.row;
    if (indexPath.row == 0) {
        UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"topView" forIndexPath:indexPath];
        if (cell.tag == 0) {
            [cell addSubview:self.topView];
            if (RI_IS_RTL) {
                [self.topView flipAllSubviews];
            }
        }
        cell.tag = 1;
        return cell;
    }
    arrayIndex--;
    RIReview *productReview = [self.reviewsArray objectAtIndex:arrayIndex];
    
    
    if((indexPath.row == ([self.reviewsArray count] - 1)) && (self.productRatings.currentPage != self.productRatings.totalPages))
    {
        [self requestReviews];
    }
    
    JAReviewCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"JAReviewCollectionCell" forIndexPath:indexPath];
    [cell setUserInteractionEnabled:YES];
    [cell setupWithReview:productReview width:[self getCellWidth] showSeparator:YES];
    
    if (RI_IS_RTL) {
        [cell flipAllSubviews];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger arrayIndex = indexPath.row;
    if (indexPath.row == 0) {
        return self.topView.frame.size;
    }
    arrayIndex--;
    RIReview *productReview = [self.reviewsArray objectAtIndex:arrayIndex];
    return [self getCellSizeForReview:productReview indexPath:indexPath];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.reviewsArray.count + 1;
}

- (CGFloat)getCellWidth
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        return 640.f;
    }else{
        return self.collectionView.width - 32;
    }
}

- (CGSize)getCellSizeForReview:(RIReview *)review indexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake([self getCellWidth], [JAReviewCollectionCell cellHeightWithReview:review width:[self getCellWidth]]);
    return size;
}

- (BOOL)isLandscape
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(orientation == UIInterfaceOrientationLandscapeLeft)
    {
        return YES;
    }else if(orientation == UIInterfaceOrientationLandscapeRight)
    {
        return YES;
    }
    return NO;
}

@end
