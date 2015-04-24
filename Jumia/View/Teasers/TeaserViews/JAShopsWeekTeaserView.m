//
//  JAShopsWeekTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 22/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAShopsWeekTeaserView.h"
#import "JAClickableView.h"
#import "UIImageView+WebCache.h"

@implementation JAShopsWeekTeaserView

- (void)load;
{
    [super load];
    
    CGFloat totalHeight = 142.0f; //value by design
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              totalHeight)];
    
    CGFloat margin = 6.0f; //value by design
    CGFloat componentWidth = (self.frame.size.width - margin*3)/2; //there are 3 margins and 2 components
    
    CGFloat currentX = margin;
    for (int i = 0; i < 2; i++) {
        
        JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                           margin,
                                                                                           componentWidth,
                                                                                           totalHeight - margin)];
        clickableView.backgroundColor = [UIColor whiteColor];
        [clickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickableView];
        
        currentX += clickableView.frame.size.width + margin;
        
        if (i < self.teaserGrouping.teaserComponents.count) {
            
            RITeaserComponent* component = [self.teaserGrouping.teaserComponents objectAtIndex:i];
            
            NSString* imageUrl;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                imageUrl = component.imageLandscapeUrl;
            } else {
                imageUrl = component.imagePortraitUrl;
            }
            UIImageView* imageView = [UIImageView new];
            [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
            [imageView setFrame:CGRectMake(clickableView.bounds.origin.x,
                                           clickableView.bounds.origin.y,
                                           clickableView.bounds.size.width,
                                           clickableView.bounds.size.height)];
            [clickableView addSubview:imageView];
        }
    }
}

@end
