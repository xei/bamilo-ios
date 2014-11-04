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

@interface JAPDVGalleryView ()
<
UIScrollViewDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImages;
@property (strong, nonatomic) NSMutableArray *modifiedArray;
@property (strong, nonatomic) NSMutableArray *imageViewsArray;

@end

@implementation JAPDVGalleryView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (JAPDVGalleryView *)getNewJAPDVGalleryView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVGalleryView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVGalleryView class]]) {
            JAPDVGalleryView *temp = (JAPDVGalleryView *)obj;
            temp.frame = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame;
            return temp;
        }
    }
    
    return nil;
}

- (void)loadGalleryWithArray:(NSArray *)source
                       frame:(CGRect)frame
                     atIndex:(NSInteger)index
{
    self.translatesAutoresizingMaskIntoConstraints = YES;
    [self setFrame:CGRectMake(frame.origin.x,
                              frame.origin.y,
                              frame.size.width,
                              frame.size.height)];
    
    self.scrollViewImages.translatesAutoresizingMaskIntoConstraints = YES;
    [self.scrollViewImages setFrame:CGRectMake(0.0f,
                                               self.scrollViewImages.frame.origin.y,
                                               self.frame.size.width,
                                               self.frame.size.height - self.scrollViewImages.frame.origin.y)];
    
    self.imageViewsArray = [NSMutableArray new];
    
    if (source.count == 1)
    {
        RIImage *image = source[0];
        
        UIScrollView *scrollForImage = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                                      0,
                                                                                      self.scrollViewImages.frame.size.width,
                                                                                      self.scrollViewImages.frame.size.height)];
        scrollForImage.delegate = self;
        scrollForImage.tag = 0;
        
        scrollForImage.minimumZoomScale = 1.0;
        scrollForImage.maximumZoomScale = 2.0;
        scrollForImage.contentSize = CGSizeMake(self.scrollViewImages.frame.size.width,
                                                self.scrollViewImages.frame.size.height);
        scrollForImage.showsHorizontalScrollIndicator = NO;
        scrollForImage.showsVerticalScrollIndicator = NO;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                               0,
                                                                               self.scrollViewImages.frame.size.width,
                                                                               self.scrollViewImages.frame.size.height)];
        imageView.contentMode = UIViewContentModeCenter;
        CGPoint point = scrollForImage.center;
        point.x = self.scrollViewImages.frame.size.width/2;
        point.y = self.scrollViewImages.frame.size.height/2;
        imageView.center = point;
        
        [imageView setImageWithURL:[NSURL URLWithString:image.url]
                  placeholderImage:[UIImage imageNamed:@"placeholder_gallery"]];
        
        [self.imageViewsArray insertObject:imageView
                                   atIndex:0];
        
        [scrollForImage addSubview:imageView];
        [self.scrollViewImages addSubview:scrollForImage];
    }
    else
    {
        self.modifiedArray = [source mutableCopy];
        [self.modifiedArray insertObject:[source lastObject]
                                 atIndex:0];
        [self.modifiedArray addObject:[source firstObject]];
        
        [self.scrollViewImages setContentSize:CGSizeMake(self.scrollViewImages.frame.size.width * self.modifiedArray.count,
                                                         self.scrollViewImages.frame.size.height)];
        
        for (int i = 0; i < self.modifiedArray.count; i++)
        {
            RIImage *image = [self.modifiedArray objectAtIndex:i];
            
            UIScrollView *scrollForImage = [[UIScrollView alloc] initWithFrame:CGRectMake(i * self.scrollViewImages.frame.size.width,
                                                                                          0,
                                                                                          self.scrollViewImages.frame.size.width,
                                                                                          self.scrollViewImages.frame.size.height)];
            scrollForImage.delegate = self;
            scrollForImage.tag = i;
            
            scrollForImage.minimumZoomScale = 1.0;
            scrollForImage.maximumZoomScale = 2.0;
            scrollForImage.contentSize = CGSizeMake(self.scrollViewImages.frame.size.width,
                                                    self.scrollViewImages.frame.size.height);
            scrollForImage.showsHorizontalScrollIndicator = NO;
            scrollForImage.showsVerticalScrollIndicator = NO;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                   0,
                                                                                   self.scrollViewImages.frame.size.width,
                                                                                   self.scrollViewImages.frame.size.height)];
            imageView.contentMode = UIViewContentModeCenter;
            CGPoint point = scrollForImage.center;
            point.x = self.scrollViewImages.frame.size.width/2;
            point.y = self.scrollViewImages.frame.size.height/2;
            imageView.center = point;
            
            [imageView setImageWithURL:[NSURL URLWithString:image.url]
                      placeholderImage:[UIImage imageNamed:@"placeholder_gallery"]];
            
            [self.imageViewsArray insertObject:imageView
                                       atIndex:i];
            
            [scrollForImage addSubview:imageView];
            [self.scrollViewImages addSubview:scrollForImage];
        }
        
        if (index >= source.count)
        {
            index = 0;
        }
        
        [self.scrollViewImages scrollRectToVisible:CGRectMake(self.scrollViewImages.frame.size.width + (self.scrollViewImages.frame.size.width * index),
                                                              0,
                                                              self.scrollViewImages.frame.size.width,
                                                              self.scrollViewImages.frame.size.height)
                                          animated:NO];
    }
}

- (IBAction)dismiss:(id)sender
{
    [self.delegate dismissGallery];
}

#pragma mark - Scrollview delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollViewImages)
    {
        CGFloat contentOffsetWhenFullyScrolledRight = self.scrollViewImages.frame.size.width * (self.modifiedArray.count - 1);
        
        if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
            
            [self.scrollViewImages scrollRectToVisible:CGRectMake(self.scrollViewImages.frame.size.width,
                                                                  0,
                                                                  self.scrollViewImages.frame.size.width,
                                                                  self.scrollViewImages.frame.size.height)
                                              animated:NO];
            
        }
        else if (scrollView.contentOffset.x == 0)
        {
            if (self.modifiedArray.count > 1)
            {
                [self.scrollViewImages scrollRectToVisible:CGRectMake(self.scrollViewImages.contentSize.width - (self.scrollViewImages.frame.size.width * 2),
                                                                      0, self.scrollViewImages.frame.size.width,
                                                                      self.scrollViewImages.frame.size.height)
                                                  animated:NO];
            }
        }
    }
}

#pragma mark - Zoom method

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    UIImageView *imageView = [self.imageViewsArray objectAtIndex:scrollView.tag];
    
    return imageView;
}

@end
