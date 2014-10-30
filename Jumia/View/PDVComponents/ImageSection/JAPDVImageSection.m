//
//  JAPDVImageSection.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVImageSection.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"

@interface JAPDVImageSection ()

@end

@implementation JAPDVImageSection

+ (JAPDVImageSection *)getNewPDVImageSection
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVImageSection"
                                                 owner:nil
                                               options:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVImageSection~iPad_Portrait"
                                            owner:nil
                                          options:nil];
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVImageSection~iPad_Landscape"
                                                owner:nil
                                              options:nil];
        }
    }
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVImageSection class]]) {
            return (JAPDVImageSection *)obj;
        }
    }
    
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
       
    }
    
    return self;
}

- (void)setupWithFrame:(CGRect)frame
{
    CGFloat width = frame.size.width - 12.0f;

    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
    
    [self.imageScrollView setFrame:CGRectMake(self.imageScrollView.frame.origin.x,
                                              self.imageScrollView.frame.origin.y,
                                              width,
                                              self.imageScrollView.frame.size.height)];
}

- (void)loadWithImages:(NSArray*)imagesArray
{
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    CGFloat currentX = 0.0f;
    CGFloat imageWidth = 146.0f;
    CGFloat imageHeight = 183.0f;
    for (int i = 0; i < imagesArray.count; i++) {
        RIImage* image = [imagesArray objectAtIndex:i];
        if (VALID_NOTEMPTY(image, RIImage)) {
            JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                               0.0f,
                                                                                               self.imageScrollView.frame.size.width,
                                                                                               self.imageScrollView.frame.size.height)];
            [clickableView addTarget:self action:@selector(imageViewPressed:) forControlEvents:UIControlEventTouchUpInside];
            clickableView.tag = i;
            [self.imageScrollView addSubview:clickableView];
            
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((clickableView.bounds.size.width - imageWidth) / 2,
                                                                                   (clickableView.bounds.size.height - imageHeight) / 2,
                                                                                   imageWidth,
                                                                                   imageHeight)];
            [clickableView addSubview:imageView];
            [imageView setImageWithURL:[NSURL URLWithString:image.url]
                         placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
            
            currentX += clickableView.frame.size.width;
        }
    }
    
    [self.imageScrollView setContentSize:CGSizeMake(currentX,
                                                    self.imageScrollView.frame.size.height)];
}

- (void)imageViewPressed:(UIControl*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageClickedAtIndex:)]) {
        [self.delegate imageClickedAtIndex:sender.tag];
    }
}

@end
