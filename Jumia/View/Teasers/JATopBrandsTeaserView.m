//
//  JATopBrandsTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATopBrandsTeaserView.h"
#import "RITeaser.h"
#import "RITeaserImage.h"
#import "UIImageView+WebCache.h"

@interface JATopBrandsTeaserView()

@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JATopBrandsTeaserView

- (void)load;
{
    if (self.teasers) {
        
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  55)];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        
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
                                           64,
                                           self.bounds.size.height)];
            
            [imageView setImageWithURL:[NSURL URLWithString:teaserImage.imageUrl]];
            [self addSubview:imageView];
            
            currentX += imageView.frame.size.width;
        }
        
        [self.scrollView setContentSize:CGSizeMake(currentX,
                                                   self.scrollView.frame.size.height)];
    }
}

@end
