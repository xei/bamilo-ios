//
//  JATeaserCategoryScrollView.h
//  Jumia
//
//  Created by Telmo Pinto on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JATeaserCategoryScrollViewDelegate <NSObject>

@optional
- (void)teaserCategorySelectedAtIndex:(NSInteger)index;

@end

@interface JATeaserCategoryScrollView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign)id<JATeaserCategoryScrollViewDelegate> delegate;

- (void)setCategories:(NSArray*)teaserCategories;

@end
