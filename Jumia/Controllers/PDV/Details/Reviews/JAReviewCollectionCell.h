//
//  JAReviewCollectionCell.h
//  Jumia
//
//  Created by josemota on 10/16/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProductRatings.h"

@interface JAReviewCollectionCell : UICollectionViewCell

- (void)setupWithReview:(RIReview *)review
                  width:(CGFloat)width
          showSeparator:(BOOL)showSeparator;

+ (CGFloat)cellHeightWithReview:(RIReview*)review
                          width:(CGFloat)width;

- (void)addTarget:(id)target action:(nonnull SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
