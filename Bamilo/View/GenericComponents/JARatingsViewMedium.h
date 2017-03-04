//
//  JARatingsViewMedium.h
//  Jumia
//
//  Created by Telmo Pinto on 07/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JARatingsViewMedium : UIView

@property (nonatomic, assign)NSInteger rating;

+ (JARatingsViewMedium *)getNewJARatingsViewMedium;

-(void)setNumberOfReviews:(NSInteger)numberOfReviews;

@end
