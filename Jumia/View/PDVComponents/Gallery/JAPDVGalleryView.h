//
//  JAPDVGalleryView.h
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JAPDVGalleryViewDelegate <NSObject>

- (void)dismissGallery;

@end

@interface JAPDVGalleryView : UIView

@property (weak, nonatomic) id<JAPDVGalleryViewDelegate> delegate;

- (void)loadGalleryWithArray:(NSArray *)source
                     atIndex:(NSInteger)index;

- (void)reloadFrame:(CGRect)frame;

@end
