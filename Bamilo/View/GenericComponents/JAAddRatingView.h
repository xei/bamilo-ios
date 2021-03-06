//
//  JAAddRatingView.h
//  Jumia
//
//  Created by plopes on 07/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIFieldRatingStars.h"

@interface JAAddRatingView : UIView

@property (assign, nonatomic) NSInteger rating;
@property (nonatomic, strong) RIFieldRatingStars* fieldRatingStars;

- (void)setupWithFieldRatingStars:(RIFieldRatingStars*)fieldRatingStars;

@end
