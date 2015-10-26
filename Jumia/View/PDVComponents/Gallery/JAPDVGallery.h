//
//  JAPDVGallery.h
//  Jumia
//
//  Created by josemota on 6/15/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JAPDVGalleryDelegate <NSObject>

- (void)onIndexChanged:(NSInteger)index;
- (void)dismissGallery;

@end

@interface JAPDVGallery : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) id<JAPDVGalleryDelegate> delegate;

- (void)loadGalleryWithArray:(NSArray *)source
                     atIndex:(NSInteger)index;
- (void)reloadFrame:(CGRect)frame;

@end