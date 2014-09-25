//
//  JASmallTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASmallTeaserView.h"
#import "UIButton+WebCache.h"

#define JATopBrandsTeaserViewHeight 55.0f

@implementation JASmallTeaserView

- (void)load;
{
    [super load];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              self.frame.size.width / 2)]; //images are squared and this will have two images
    
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
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:UIColorFromRGB(0xffffff)];
        [button setFrame:CGRectMake(currentX,
                                   self.bounds.origin.y,
                                   self.bounds.size.width / self.teasers.count,
                                    self.bounds.size.height)];
        [button setImageWithURL:[NSURL URLWithString:teaserImage.imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_grid"]];
        [button addTarget:self action:@selector(teaserImagePressed:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self addSubview:button];
        
        currentX += button.frame.size.width;
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
