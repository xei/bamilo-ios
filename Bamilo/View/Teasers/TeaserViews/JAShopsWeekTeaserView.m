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
    CGFloat horizontalMargin = 6.0f; //value by design
    CGFloat middleMargin = 6.0f; //value by design
    CGFloat topMargin = 6.0f; //value by design
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        totalHeight = 283.0f;
        middleMargin = 12.0f; //value by design
        topMargin = 12.0f; //value by design
    }
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              totalHeight)];
    

    CGFloat componentWidth = (self.frame.size.width - horizontalMargin*2 - middleMargin)/2;
    
    CGFloat currentX = horizontalMargin;
    for (int i = 0; i < 2; i++) {
        
        JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                           topMargin,
                                                                                           componentWidth,
                                                                                           totalHeight - topMargin)];
        clickableView.tag = i;
        clickableView.backgroundColor = [UIColor whiteColor];
        [clickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickableView];
        
        currentX += clickableView.frame.size.width + middleMargin;
        
        if (i < self.teaserGrouping.teaserComponents.count) {
            
            RITeaserComponent* component = [self.teaserGrouping.teaserComponents objectAtIndex:i];
            
            NSString* imageUrl = component.imagePortraitUrl;
            UIImageView* imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
            [imageView setFrame:CGRectMake(clickableView.bounds.origin.x,
                                           clickableView.bounds.origin.y,
                                           clickableView.bounds.size.width,
                                           clickableView.bounds.size.height)];
            [clickableView addSubview:imageView];
        }
    }
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (NSString*)teaserTrackingInfoForIndex:(NSInteger)index;
{
    NSString* teaserTrackingInfo = [NSString stringWithFormat:@"Shops_Week_%ld",(long)index];
    return teaserTrackingInfo;
}

@end
