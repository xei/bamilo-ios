//
//  JAMainTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMainTeaserView.h"
#import "UIImageView+WebCache.h"

#define JAMainTeaserViewHeight 173.0f

@interface JAMainTeaserView()

@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JAMainTeaserView

- (void)load;
{
    [super load];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              JAMainTeaserViewHeight)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    CGFloat currentX = 0;
    
    for (int i = 0; i < self.teasers.count; i++) {
        RITeaser* teaser = [self.teasers objectAtIndex:i];
        
        RITeaserImage* teaserImage;
        
        if (1 == teaser.teaserImages.count) {
            
            teaserImage = [teaser.teaserImages firstObject];
            
        } else {
            for (RITeaserImage* possibleTeaserImage in teaser.teaserImages) {
                
                if ([possibleTeaserImage.deviceType isEqualToString:@"phone"]) {
                    
                    teaserImage = possibleTeaserImage;
                }
            }
        }
        
        UIImageView* imageView = [UIImageView new];
        [imageView setFrame:CGRectMake(currentX,
                                       self.scrollView.bounds.origin.y,
                                       self.scrollView.bounds.size.width,
                                       self.scrollView.bounds.size.height)];
        
        [imageView setImageWithURL:[NSURL URLWithString:teaserImage.imageUrl]];
        [self.scrollView addSubview:imageView];
        
        UIControl* control = [UIControl new];
        [control setFrame:imageView.frame];
        [self.scrollView addSubview:control];
        control.tag = i;
        [control addTarget:self action:@selector(teaserImagePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        currentX += imageView.frame.size.width;
    }
    
    [self.scrollView setContentSize:CGSizeMake(currentX,
                                               self.scrollView.frame.size.height)];
}

- (void)teaserImagePressed:(UIControl*)control
{
    NSInteger index = control.tag;
    
    RITeaser* teaser = [self.teasers objectAtIndex:index];
    
    RITeaserImage* teaserImage = [teaser.teaserImages firstObject];
    
    [self teaserPressedWithTeaserImage:teaserImage];
}

@end
