//
//  JAProductInfoRatingLine.h
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAProductInfoBaseLine.h"

#define kProductInfoSingleLineHeight 48

typedef NS_ENUM(NSInteger, JAImageRatingSize) {
    kImageRatingSizeMedium = 0,
    kImageRatingSizeSmall = 1,
    kImageRatingSizeBig = 2
};

@interface JAProductInfoRatingLine : JAProductInfoBaseLine

@property (nonatomic) BOOL fashion;
@property (nonatomic) NSNumber *ratingAverage;
@property (nonatomic) NSNumber *ratingSum;
@property (nonatomic) JAImageRatingSize imageRatingSize;
@property (nonatomic) BOOL noMargin;
@property (nonatomic, readonly) CGFloat imageHeight;

@end
