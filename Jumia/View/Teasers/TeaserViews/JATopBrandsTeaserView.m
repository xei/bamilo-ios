//
//  JATopBrandsTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATopBrandsTeaserView.h"
#import "UIImageView+WebCache.h"
#import "JAClickableView.h"

#define JATopBrandsTeaserViewHeight 55.0f

@implementation JATopBrandsTeaserView

- (void)load;
{
    [super load];
        
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              JATopBrandsTeaserViewHeight)];
    
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
        
        JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                           self.bounds.origin.y,
                                                                                           self.bounds.size.width / self.teasers.count,
                                                                                           self.bounds.size.height)];
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:clickableView.bounds];
        [imageView setImageWithURL:[NSURL URLWithString:teaserImage.imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
        [clickableView addSubview:imageView];
        clickableView.tag = i;
        [clickableView addTarget:self action:@selector(teaserImagePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickableView];
        
        currentX += imageView.frame.size.width;
    }
}

- (void)teaserImagePressed:(UIControl*)control
{
    NSInteger index = control.tag;
    
    RITeaser* teaser = [self.teasers objectAtIndex:index];
    
    RITeaserImage* teaserImage = [teaser.teaserImages firstObject];
    
    [self teaserPressedWithTeaserImage:teaserImage
                            targetType:[teaser.targetType integerValue]];
}

@end
