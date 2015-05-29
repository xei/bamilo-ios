//
//  JAFeatureStoresTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 22/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAFeatureStoresTeaserView.h"
#import "UIImageView+WebCache.h"
#import "JAClickableView.h"

@implementation JAFeatureStoresTeaserView

- (void)load
{
    [super load];
    
    if (VALID_NOTEMPTY(self.teaserGrouping.teaserComponents, NSOrderedSet)) {
        
        CGFloat groupingTitleLabelMargin = 16.0f;
        CGFloat groupingTitleLabelHeight = 50.0f; //value by design
        UILabel* groupingTitleLabel = [UILabel new];
        groupingTitleLabel.font = [UIFont fontWithName:kFontMediumName size:14.0f];
        groupingTitleLabel.textColor = [UIColor blackColor];
        groupingTitleLabel.text = STRING_FEATURED_STORES;
        [groupingTitleLabel sizeToFit];
        [groupingTitleLabel setFrame:CGRectMake(groupingTitleLabelMargin,
                                                self.bounds.origin.y,
                                                self.frame.size.width - groupingTitleLabelMargin*2,
                                                groupingTitleLabelHeight)];
        [self addSubview:groupingTitleLabel];
        
        CGFloat currentY = groupingTitleLabel.frame.size.height;
        CGFloat marginX = 6.0f; //value by design
        CGFloat marginY = 6.0f; //value by design
        CGFloat componentHeight = 44; //value by design
        NSInteger numberOfComponentsForLine = 2;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            componentHeight = 68.0f;
            numberOfComponentsForLine = self.teaserGrouping.teaserComponents.count / 2;
        }
        NSInteger numberOfMargins = numberOfComponentsForLine + 1;
        CGFloat componentWidth = (self.bounds.size.width- marginX * numberOfMargins)/numberOfComponentsForLine;
        CGFloat currentX = marginX;
        for (int i = RI_IS_RTL?(int)self.teaserGrouping.teaserComponents.count-1:0;
             RI_IS_RTL? i >= 0 : i < self.teaserGrouping.teaserComponents.count;
             RI_IS_RTL? i--:i++) {
//        for (int i = 0; i < self.teaserGrouping.teaserComponents.count; i++) {
            
            JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                               currentY,
                                                                                               componentWidth,
                                                                                               componentHeight)];
            clickableView.tag = i;
            clickableView.backgroundColor = [UIColor whiteColor];
            [clickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:clickableView];
            
            currentX += clickableView.frame.size.width + marginX;
            if (0 == (i+1) % numberOfComponentsForLine) {
                currentX = marginX;
                currentY += marginY + componentHeight;
            } else if (i+1 == self.teaserGrouping.teaserComponents.count){
                //if it it the last of them all but not the last slot in line, add the height anyway
                currentY += marginY + componentHeight;
            }
            
            RITeaserComponent* component = [self.teaserGrouping.teaserComponents objectAtIndex:i];
            
            NSString* imageUrl = component.imagePortraitUrl;
            CGFloat imageMargin = 2.0f;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                imageMargin = 6.0f;
            }
            CGFloat imageSide = 40.0f; //value by design
            UIImageView* imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
            [imageView setFrame:CGRectMake(clickableView.bounds.size.width - imageMargin - imageSide,
                                           clickableView.bounds.size.height - imageMargin - imageSide,
                                           imageSide,
                                           imageSide)];
            [clickableView addSubview:imageView];
            
            CGFloat textMarginX = 6.0;
            CGFloat textMarginY = 5.0;
            UILabel* titleLabel = [UILabel new];
            titleLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.text = component.title;
            [titleLabel sizeToFit];
            [titleLabel setFrame:CGRectMake(clickableView.bounds.origin.x + textMarginX,
                                            clickableView.bounds.origin.y + textMarginY,
                                            clickableView.bounds.size.width - textMarginX*2 - imageSide - imageMargin,
                                            titleLabel.frame.size.height)];
            [clickableView addSubview:titleLabel];
            
            UILabel* subTitleLabel = [UILabel new];
            subTitleLabel.font = [UIFont fontWithName:kFontLightName size:9.0f];
            subTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
            subTitleLabel.text = component.subTitle;
            [subTitleLabel sizeToFit];
            [subTitleLabel setFrame:CGRectMake(clickableView.bounds.origin.x + textMarginX,
                                               CGRectGetMaxY(titleLabel.frame),
                                               clickableView.bounds.size.width - textMarginX*2 - imageSide - imageMargin,
                                               subTitleLabel.frame.size.height)];
            [clickableView addSubview:subTitleLabel];
        }
        
        
        
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  currentY)];
    }
}

@end
