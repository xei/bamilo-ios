//
//  JAReviewCell.h
//  Jumia
//
//  Created by Miguel Chaves on 07/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JARatingsView.h"
#import "RIProductRatings.h"
#import "RISellerReviewInfo.h"

@interface JAReviewCell : UITableViewCell

@property (nonatomic, strong)NSMutableArray *ratingStarViews;
@property (nonatomic, strong)NSMutableArray *ratingLabels;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UILabel *descriptionLabel;
@property (nonatomic, strong)UILabel *authorDateLabel;
@property (nonatomic, strong)UIView *separator;


- (void)setupWithReview:(RIReview *)review
          showSeparator:(BOOL)showSeparator;

- (void)setupWithSellerReview:(RISellerReview*)sellerReview
                showSeparator:(BOOL)showSeparator;

+ (CGFloat)cellHeightWithReview:(RIReview*)review
                          width:(CGFloat)width;

+ (CGFloat)cellHeightWithSellerReview:(RISellerReview*)sellerReview
                                width:(CGFloat)width;

@end
