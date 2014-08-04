//
//  JATopBrandsTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATopBrandsTeaserView.h"
#import "UIImageView+WebCache.h"

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
    
    for (RITeaser* teaser in self.teasers) {
        
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
                                       self.bounds.origin.y,
                                       self.bounds.size.width / self.teasers.count,
                                       self.bounds.size.height)];
        
        [imageView setImageWithURL:[NSURL URLWithString:teaserImage.imageUrl]];
        [self addSubview:imageView];
        
        currentX += imageView.frame.size.width;
    }

}

@end
