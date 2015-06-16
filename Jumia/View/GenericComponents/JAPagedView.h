//
//  JAPagedScrollView.h
//  testing
//
//  Created by josemota on 6/9/15.
//  Copyright (c) 2015 josemota. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectPageBlock)(NSInteger pageIndex);

@interface JAPagedView : UIView

@property (nonatomic, assign)BOOL hasSmallDots;
@property (nonatomic, strong) NSArray *views;
@property (nonatomic) NSInteger selectedIndexPage;
@property (nonatomic) BOOL infinite;

- (void)getPageChanged:(SelectPageBlock)page;

- (void)getPageChangedTarget:(id)target selector:(SEL)selector;

@end
