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
            return (JAPDVGalleryView *)obj;
        }
    }
    
    return nil;
}

- (void)loadGalleryWithArray:(NSArray *)source
{
    self.imageViewsArray = [NSMutableArray new];
    
    if (source.count == 1)
    {
        RIImage *image = source[0];
        
        UIScrollView *scrollForImage = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.scrollViewImages.frame.size.height)];
        scrollForImage.delegate = self;
        scrollForImage.tag = 0;
        
        scrollForImage.minimumZoomScale = 1.0;
        scrollForImage.maximumZoomScale = 2.0;
        scrollForImage.contentSize = CGSizeMake(320, 320);
        scrollForImage.showsHorizontalScrollIndicator = NO;
        scrollForImage.showsVerticalScrollIndicator = NO;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.scrollViewImages.frame.size.height)];
        imageView.contentMode = UIViewContentModeCenter;
        
        [imageView setImageWithURL:[NSURL URLWithString:image.url]
                  placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
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
        
        [self.scrollViewImages setContentSize:CGSizeMake(320 * self.modifiedArray.count, self.scrollViewImages.frame.size.height)];
        
        for (int i = 0 ; i < self.modifiedArray.count ; i++)
        {
            RIImage *image = [self.modifiedArray objectAtIndex:i];
            
            UIScrollView *scrollForImage = [[UIScrollView alloc] initWithFrame:CGRectMake(i * 320, 0, 320, self.scrollViewImages.frame.size.height)];
            scrollForImage.delegate = self;
            scrollForImage.tag = i;
            
            scrollForImage.minimumZoomScale = 1.0;
            scrollForImage.maximumZoomScale = 2.0;
            scrollForImage.contentSize = CGSizeMake(320, 320);
            scrollForImage.showsHorizontalScrollIndicator = NO;
            scrollForImage.showsVerticalScrollIndicator = NO;
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.scrollViewImages.frame.size.height)];
            imageView.contentMode = UIViewContentModeCenter;
                        
            [imageView setImageWithURL:[NSURL URLWithString:image.url]
                      placeholderImage:[UIImage imageNamed:@"placeholder"]];
            
            [self.imageViewsArray insertObject:imageView
                                       atIndex:i];
            
            [scrollForImage addSubview:imageView];
            [self.scrollViewImages addSubview:scrollForImage];
        }
        
        [self.scrollViewImages scrollRectToVisible:CGRectMake(320, 0, 320, self.scrollViewImages.frame.size.height)
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
        float contentOffsetWhenFullyScrolledRight = self.scrollViewImages.frame.size.width * (self.modifiedArray.count -1);
        
        if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
            
            [self.scrollViewImages scrollRectToVisible:CGRectMake(320, 0, 320, self.scrollViewImages.frame.size.height)
                                              animated:NO];
            
        } else if (scrollView.contentOffset.x == 0)  {
            
            if (self.modifiedArray.count > 1) {
                [self.scrollViewImages scrollRectToVisible:CGRectMake(self.scrollViewImages.contentSize.width - 640, 0, 320, self.scrollViewImages.frame.size.height)
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
