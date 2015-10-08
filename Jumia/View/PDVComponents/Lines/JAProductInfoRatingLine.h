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

@interface JAProductInfoRatingLine : JAProductInfoBaseLine

@property (nonatomic) BOOL fashion;
@property (nonatomic) NSNumber *ratingAverage;
@property (nonatomic) NSNumber *ratingSum;

- (void)setSellerRatingAverage:(NSNumber *)ratingAverage;

@end
