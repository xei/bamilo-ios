//
//  JAPDVGallery.m
//  Jumia
//
//  Created by josemota on 6/15/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVGallery.h"
#import "JAPagedView.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"

@interface JAPDVGallery ()
{
    JAPagedView *_pageControl;
    NSArray *_source;
    NSArray *_imageViewsToScroll;
    NSInteger _lastIndex;
    UIButton *_exitButton;
}

@end

@implementation JAPDVGallery

- (void)loadGalleryWithArray:(NSArray *)source
                     atIndex:(NSInteger)index
{
    _source = source;
    _lastIndex = index;
    
    [_pageControl removeFromSuperview];
    _pageControl = [[JAPagedView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [_pageControl setInfinite:YES];
    [self addSubview:_pageControl];
    
    NSMutableArray* imageViewsToScroll = [NSMutableArray new];
    NSMutableArray *items = [NSMutableArray new];
    for (int i = 0; i < source.count; i++)
    {

        UIScrollView *scrollForImage = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      self.width,
                                                                                      self.height)];
        scrollForImage.delegate = self;
        scrollForImage.tag = i;
        
        scrollForImage.minimumZoomScale = 1.0;
        scrollForImage.maximumZoomScale = 2.0;
        scrollForImage.contentSize = CGSizeMake(self.width,
                                                self.height);
        scrollForImage.showsHorizontalScrollIndicator = NO;
        scrollForImage.showsVerticalScrollIndicator = NO;
        
        
        RIImage *image = [source objectAtIndex:i];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollForImage.bounds];
        imageView.contentMode = UIViewContentModeCenter;
        CGPoint point = self.center;
        point.x = self.width/2;
        point.y = self.height/2;
        imageView.center = point;
        
        [imageView setImageWithURL:[NSURL URLWithString:image.url]
                  placeholderImage:[UIImage imageNamed:@"placeholder_gallery"]];

        [imageViewsToScroll addObject:imageView];
        
        [scrollForImage addSubview:imageView];
        [items addObject:scrollForImage];
        
    }
    _imageViewsToScroll = [imageViewsToScroll copy];
    [_pageControl setViews:items];
    [_pageControl setSelectedIndexPage:index];
    
    
    [_exitButton removeFromSuperview];
    _exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _exitButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:_exitButton.titleLabel.font.pointSize];
    [_exitButton setTitle:STRING_DONE forState:UIControlStateNormal];
    [_exitButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_exitButton sizeToFit];
    [_exitButton setFrame:CGRectMake(RI_IS_RTL?6:self.frame.size.width - _exitButton.frame.size.width - 6.f,
                                     _exitButton.frame.origin.y,
                                     _exitButton.frame.size.width,
                                     _exitButton.frame.size.height)];
    [_exitButton addTarget:self action:@selector(exitButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_exitButton];
}

- (void)reloadFrame:(CGRect)frame
{
    [self setFrame:frame];
    [self loadGalleryWithArray:_source atIndex:_lastIndex];
}

- (void)exitButtonPressed
{
    if (_delegate) {
        [_delegate dismissGallery];
    }
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    UIImageView *imageView = [_imageViewsToScroll objectAtIndex:scrollView.tag];
    
    return imageView;
}

@end
