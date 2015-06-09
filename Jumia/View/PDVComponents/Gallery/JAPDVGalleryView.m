//
//  JAPDVGalleryView.m
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVGalleryView.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"
#import "JAAppDelegate.h"
#import "JAPageControl.h"

@interface JAPDVGalleryView ()
<
UIScrollViewDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImages;
@property (nonatomic, strong) JAPageControl* pageControl;
@property (strong, nonatomic) NSMutableArray *modifiedArray;
@property (strong, nonatomic) NSMutableArray *imageViewsArray;
@property (strong, nonatomic) NSArray *source;
@property (assign, nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end

@implementation JAPDVGalleryView

- (instancetype)init
{
    self = (JAPDVGalleryView *)[[[NSBundle mainBundle] loadNibNamed:@"JAPDVGalleryView" owner:self options:nil] firstObject];
    if (self) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = (JAPDVGalleryView *)[[[NSBundle mainBundle] loadNibNamed:@"JAPDVGalleryView" owner:self options:nil] firstObject];
    if (self) {
        [super setFrame:frame];
    }
    return self;
}

- (void)loadGalleryWithArray:(NSArray *)source
                     atIndex:(NSInteger)index
{
    _source = [NSArray arrayWithArray:source];
    
    [_scrollViewImages setFrame:CGRectMake(0.0f,
                                               _scrollViewImages.frame.origin.y,
                                               self.frame.size.width,
                                               self.frame.size.height - _scrollViewImages.frame.origin.y)];
    
    _imageViewsArray = [NSMutableArray new];
    
    if (_source.count == 1)
    {
        RIImage *image = _source[0];
        
        UIScrollView *scrollForImage = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      _scrollViewImages.frame.size.width,
                                                                                      _scrollViewImages.frame.size.height)];
        scrollForImage.delegate = self;
        scrollForImage.tag = 0;
        
        scrollForImage.minimumZoomScale = 1.0;
        scrollForImage.maximumZoomScale = 2.0;
        scrollForImage.contentSize = CGSizeMake(_scrollViewImages.frame.size.width,
                                                _scrollViewImages.frame.size.height);
        scrollForImage.showsHorizontalScrollIndicator = NO;
        scrollForImage.showsVerticalScrollIndicator = NO;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               _scrollViewImages.frame.size.width,
                                                                               _scrollViewImages.frame.size.height)];
        imageView.contentMode = UIViewContentModeCenter;
        CGPoint point = scrollForImage.center;
        point.x = _scrollViewImages.frame.size.width/2;
        point.y = _scrollViewImages.frame.size.height/2;
        imageView.center = point;
        
        [imageView setImageWithURL:[NSURL URLWithString:image.url]
                  placeholderImage:[UIImage imageNamed:@"placeholder_gallery"]];
        
        [_imageViewsArray insertObject:imageView
                                   atIndex:0];
        
        [scrollForImage addSubview:imageView];
        [_scrollViewImages addSubview:scrollForImage];
    }
    else
    {
        _modifiedArray = [_source mutableCopy];
        [_modifiedArray insertObject:[_source lastObject]
                                 atIndex:0];
        [_modifiedArray addObject:[_source firstObject]];
        
        [_scrollViewImages setContentSize:CGSizeMake(_scrollViewImages.frame.size.width * _modifiedArray.count,
                                                         _scrollViewImages.frame.size.height)];
        
        int position = 0;
        for (int i = RI_IS_RTL?(int)_modifiedArray.count-1:0; RI_IS_RTL?i >= 0:i < _modifiedArray.count; RI_IS_RTL?i--:i++)
//        for (int i = 0; i < _modifiedArray.count; i++)
        {
            RIImage *image = [_modifiedArray objectAtIndex:i];
            
            UIScrollView *scrollForImage = [[UIScrollView alloc] initWithFrame:CGRectMake(position * _scrollViewImages.frame.size.width,
                                                                                          0,
                                                                                          _scrollViewImages.frame.size.width,
                                                                                          _scrollViewImages.frame.size.height)];
            scrollForImage.delegate = self;
            scrollForImage.tag = i;
            
            scrollForImage.minimumZoomScale = 1.0;
            scrollForImage.maximumZoomScale = 2.0;
            scrollForImage.contentSize = CGSizeMake(_scrollViewImages.frame.size.width,
                                                    _scrollViewImages.frame.size.height);
            scrollForImage.showsHorizontalScrollIndicator = NO;
            scrollForImage.showsVerticalScrollIndicator = NO;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                   0,
                                                                                   _scrollViewImages.frame.size.width,
                                                                                   _scrollViewImages.frame.size.height)];
            imageView.contentMode = UIViewContentModeCenter;
            CGPoint point = scrollForImage.center;
            point.x = _scrollViewImages.frame.size.width/2;
            point.y = _scrollViewImages.frame.size.height/2;
            imageView.center = point;
            
            [imageView setImageWithURL:[NSURL URLWithString:image.url]
                      placeholderImage:[UIImage imageNamed:@"placeholder_gallery"]];
            
//            [_imageViewsArray insertObject:imageView
//                                       atIndex:i];
            [_imageViewsArray addObject:imageView];
            
            [scrollForImage addSubview:imageView];
            [_scrollViewImages addSubview:scrollForImage];
            position++;
        }
        
        if (index >= _source.count)
        {
            index = 0;
        }
        [_scrollViewImages scrollRectToVisible:CGRectMake(_scrollViewImages.frame.size.width + (_scrollViewImages.frame.size.width * (RI_IS_RTL?(_source.count-1-index):index)),
                                                              0,
                                                              _scrollViewImages.frame.size.width,
                                                              _scrollViewImages.frame.size.height)
                                          animated:NO];
    }

    _index = index;
    
    if (_pageControl) {
        [_pageControl removeFromSuperview];
    }
    
    _pageControl = [[JAPageControl alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                       self.bounds.size.height - 20.0f,
                                                                       self.bounds.size.width,
                                                                       10.0f)];
    _pageControl.numberOfPages = _source.count;
    [self addSubview:_pageControl];
    
    _pageControl.currentPage = RI_IS_RTL?_source.count-1 - _index: _index;
    
    _doneButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:_doneButton.titleLabel.font.pointSize];
    [_doneButton setTitle:STRING_DONE forState:UIControlStateNormal];
    [_doneButton setFrame:CGRectMake(self.frame.size.width - _doneButton.frame.size.width,
                                         _doneButton.frame.origin.y,
                                         _doneButton.frame.size.width,
                                         _doneButton.frame.size.height)];
    if (RI_IS_RTL)
        [self.doneButton flipViewPositionInsideSuperview];
}

- (void)reloadFrame:(CGRect)frame
{
    [self setFrame:frame];
    
    [_scrollViewImages setFrame:CGRectMake(0.0f,
                                               _scrollViewImages.frame.origin.y,
                                               self.frame.size.width,
                                               self.frame.size.height - _scrollViewImages.frame.origin.y)];
    
    _imageViewsArray = [NSMutableArray new];
    
    for(UIView *view in _scrollViewImages.subviews)
    {
        if([view isKindOfClass:[UIScrollView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    if (_source && _index) {
        [self loadGalleryWithArray:_source atIndex:_index];
    }
    
    [_doneButton setFrame:CGRectMake(self.frame.size.width - _doneButton.frame.size.width,
                                         _doneButton.frame.origin.y,
                                         _doneButton.frame.size.width,
                                         _doneButton.frame.size.height)];
}

- (IBAction)dismiss:(id)sender
{
    [_delegate dismissGallery];
}

#pragma mark - Scrollview delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrollViewImages)
    {
        NSInteger newIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
        if(0 == newIndex)
        {
            _index = [_source count] - 1;
        }
        else if(([_modifiedArray count] - 1) == newIndex)
        {
            _index =  0;
        }
        else
        {
            _index = newIndex - 1;
        }
        
        CGFloat contentOffsetWhenFullyScrolledRight = _scrollViewImages.frame.size.width * (_modifiedArray.count - 1);
        
        if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
            
            [_scrollViewImages scrollRectToVisible:CGRectMake(_scrollViewImages.frame.size.width,
                                                                  0,
                                                                  _scrollViewImages.frame.size.width,
                                                                  _scrollViewImages.frame.size.height)
                                              animated:NO];
            
        }
        else if (scrollView.contentOffset.x == 0)
        {
            if (_modifiedArray.count > 1)
            {
                [_scrollViewImages scrollRectToVisible:CGRectMake(_scrollViewImages.contentSize.width - (_scrollViewImages.frame.size.width * 2),
                                                                      0, _scrollViewImages.frame.size.width,
                                                                      _scrollViewImages.frame.size.height)
                                                  animated:NO];
            }
        }
    }
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    UIImageView *imageView = [_imageViewsArray objectAtIndex:scrollView.tag];
    
    return imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //add 0.5 to make sure we scroll the indicators with the middle of the page
    //and then subtract 1 to make up for the fake image offset (fake images that are used for infinite scrolling)
//    _pageControl.currentPage = (scrollView.contentOffset.x / _scrollViewImages.frame.size.width) + 0.5f - 1.0f;
    
    int page = (scrollView.contentOffset.x / _scrollViewImages.frame.size.width) + 0.5f - 1.0f;
    _pageControl.currentPage = page;

}

@end
