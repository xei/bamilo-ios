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
    if (source.count == 1)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        RIImage *image = source[0];
        
        [imageView setImageWithURL:[NSURL URLWithString:image.url]];
        
        [self.scrollViewImages addSubview:imageView];
        [self.scrollViewImages setContentSize:CGSizeMake(320, 320)];
    }
    else
    {
        self.modifiedArray = [source mutableCopy];
        [self.modifiedArray insertObject:[source lastObject]
                                 atIndex:0];
        [self.modifiedArray addObject:[source firstObject]];
        
        [self.scrollViewImages setContentSize:CGSizeMake(320 * self.modifiedArray.count, 320)];
        
        for (int i = 0 ; i < self.modifiedArray.count ; i++)
        {
            RIImage *image = [self.modifiedArray objectAtIndex:i];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 320, 0, 320, 320)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
                        
            [imageView setImageWithURL:[NSURL URLWithString:image.url]];
            
            [self.scrollViewImages addSubview:imageView];
        }
        
        [self.scrollViewImages scrollRectToVisible:CGRectMake(320, 0, 320, 320)
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
            
            [self.scrollViewImages scrollRectToVisible:CGRectMake(320, 0, 320, 320)
                                              animated:NO];
            
        } else if (scrollView.contentOffset.x == 0)  {
            
            if (self.modifiedArray.count > 1) {
                [self.scrollViewImages scrollRectToVisible:CGRectMake(self.scrollViewImages.contentSize.width - 640, 0, 320, 320)
                                                  animated:NO];
            }
        }
    }
}

@end
