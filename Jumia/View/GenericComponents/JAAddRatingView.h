//
//  JAAddRatingView.h
//  Jumia
//
//  Created by plopes on 07/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIRatings.h"

@interface JAAddRatingView : UIView

@property (assign, nonatomic) NSInteger rating;
@property (strong, nonatomic) NSString *idRatingType;
@property (strong, nonatomic) NSArray *ratingOptions;

+ (JAAddRatingView *)getNewJAAddRatingView;

- (void)setupWithOption:(RIRatingsDetails*)option;

@end
