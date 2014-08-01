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
            
            if (1 == teaser.teaserImages.count) {
                
                RITeaserImage* teaserImage = [teaser.teaserImages firstObject];
                
                UIImageView* imageView = [UIImageView new];
                [imageView setFrame:CGRectMake(currentX,
                                               self.bounds.origin.y,
                                               self.bounds.size.width,
                                               self.bounds.size.height)];
                
                [imageView setImageWithURL:[NSURL URLWithString:teaserImage.imageUrl]];
                [self addSubview:imageView];
                
                currentX += self.bounds.size.width;
                
            } else {
                for (RITeaserImage* teaserImage in teaser.teaserImages) {
                    
                    if ([teaserImage.deviceType isEqualToString:@"phone"]) {
                        
                        UIImageView* imageView = [UIImageView new];
                        [imageView setFrame:CGRectMake(currentX,
                                                       self.bounds.origin.y,
                                                       self.bounds.size.width,
                                                       self.bounds.size.height)];
                        
                        [imageView setImageWithURL:[NSURL URLWithString:teaserImage.imageUrl]];
                        [self addSubview:imageView];
                        
                        currentX += self.bounds.size.width;
                    }
                }
            }
        }
        
        [self setContentSize:CGSizeMake(currentX,
                                        self.frame.size.height)];
    }
}

@end
