//
//  JAScrolledImageGallery.h
//  Jumia
//
//  Created by josemota on 9/22/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

typedef void (^SelectPageBlock)(NSInteger pageIndex);

@interface JAScrolledImageGalleryView : UIView

@property (nonatomic, assign)BOOL hasSmallDots;
@property (nonatomic, strong) NSArray *views;
@property (nonatomic) NSInteger selectedIndexPage;
@property (nonatomic) BOOL infinite;
@property (nonatomic) CGFloat navigationCursorBottomPercentage;

- (void)getPageChanged:(SelectPageBlock)page;

- (void)getPageChangedTarget:(id)target selector:(SEL)selector;

- (void)addImageClickedTarget:(id)target selector:(SEL)selector;

@end
