//
//  JARatingsView.h
//  Jumia
//
//  Created by Telmo Pinto on 07/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JARatingsView : UIView

@property (nonatomic, assign)NSInteger rating;

+ (JARatingsView *)getNewJARatingsView;

@end
