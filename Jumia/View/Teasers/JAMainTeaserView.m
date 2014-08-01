//
//  JAMainTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMainTeaserView.h"
#import "RITeaser.h"
#import "RITeaserImage.h"
#import "UIImageView+WebCache.h"

#define JAMainTeaserViewHeight 173.0f

@implementation JAMainTeaserView

- (void)load;
{
    if (self.teasers) {
 
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  JAMainTeaserViewHeight)];
        
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
                                           self.bounds.size.width,
                                           self.bounds.size.height)];
            
            [imageView setImageWithURL:[NSURL URLWithString:teaserImage.imageUrl]];
            [self addSubview:imageView];
            
            currentX += imageView.frame.size.width;
        }
        
        [self setContentSize:CGSizeMake(currentX,
                                        self.frame.size.height)];
    }
}

@end
