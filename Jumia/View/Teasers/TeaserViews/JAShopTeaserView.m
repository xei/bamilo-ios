//
//  JAShopTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 22/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAShopTeaserView.h"
#import "JAClickableView.h"
#import "UIImageView+WebCache.h"

@implementation JAShopTeaserView

- (void)load;
{
    [super load];
    
    CGFloat totalHeight = 129.0f; //value by design
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        totalHeight = 150.0f; //value by design
    }
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              totalHeight)];
    CGFloat margin = 6.0f; //value by design
    CGFloat numberOfComponents = 3; //value by design;
    CGFloat componentWidth = (self.frame.size.width - margin*2)/numberOfComponents;
    
    CGFloat currentX = margin;
    
    for (int i = 0; i < numberOfComponents; i++) {
        
        JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                           self.bounds.origin.y,
                                                                                           componentWidth,
                                                                                           self.bounds.size.height)];
        clickableView.tag = i;
        clickableView.backgroundColor = [UIColor whiteColor];
        [clickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickableView];
        
        currentX += clickableView.frame.size.width;
        
        if (i < self.teaserGrouping.teaserComponents.count) {
            
            RITeaserComponent* component = [self.teaserGrouping.teaserComponents objectAtIndex:i];
            
            CGFloat textMarginX = 4.0;
            CGFloat textMarginY = 6.0;
            UILabel* titleLabel = [UILabel new];
            titleLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
            titleLabel.textColor = [UIColor blackColor];
            titleLabel.text = component.title;
            [titleLabel sizeToFit];
            [titleLabel setFrame:CGRectMake(clickableView.bounds.origin.x + textMarginX,
                                            clickableView.bounds.origin.y + textMarginY,
                                            clickableView.bounds.size.width - textMarginX*2,
                                            titleLabel.frame.size.height)];
            [clickableView addSubview:titleLabel];
            
            UILabel* subTitleLabel = [UILabel new];
            subTitleLabel.font = [UIFont fontWithName:kFontLightName size:9.0f];
            subTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
            subTitleLabel.text = component.subTitle;
            [subTitleLabel sizeToFit];
            [subTitleLabel setFrame:CGRectMake(clickableView.bounds.origin.x + textMarginX,
                                               CGRectGetMaxY(titleLabel.frame),
                                               clickableView.bounds.size.width - textMarginX*2,
                                               subTitleLabel.frame.size.height)];
            [clickableView addSubview:subTitleLabel];
            
            CGFloat imageBottomMargin = 0.0f; //value by design
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                titleLabel.textAlignment = NSTextAlignmentCenter;
                subTitleLabel.textAlignment = NSTextAlignmentCenter;
                imageBottomMargin = 12.0f;
            }
            NSString* imageUrl = component.imagePortraitUrl;
            CGFloat imageHeight = 96; //value by design
            CGFloat imageWidth = imageHeight;
            UIImageView* imageView = [UIImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
            [imageView setFrame:CGRectMake((clickableView.bounds.size.width - imageWidth) / 2,
                                           clickableView.bounds.size.height - imageHeight - imageBottomMargin,
                                           imageWidth,
                                           imageHeight)];
            [clickableView addSubview:imageView];
        }
        
        if (i != numberOfComponents-1) {
            //not the last one, so add a separator
            UIView* separator = [UIView new];
            separator.backgroundColor = UIColorFromRGB(0xd8d8d8);
            [separator setFrame:CGRectMake(currentX - 1,
                                           clickableView.frame.origin.y,
                                           1,
                                           clickableView.frame.size.height)];
            [self addSubview:separator];
        }
    }
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

@end
