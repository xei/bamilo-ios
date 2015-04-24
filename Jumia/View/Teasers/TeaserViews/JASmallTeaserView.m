//
//  JASmallTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASmallTeaserView.h"
#import "UIImageView+WebCache.h"
#import "JAClickableView.h"

@interface JASmallTeaserView()

@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JASmallTeaserView

- (void)load
{
    [super load];
    
    CGFloat totalHeight = 132; //value by design
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              totalHeight)];
    
    CGFloat margin = 6.0f; //value by design
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                     self.bounds.origin.y + margin,
                                                                     self.bounds.size.width,
                                                                     self.bounds.size.height - 2*margin)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    CGFloat componentWidth = 108; //value by design
    CGFloat currentX = margin;
    
    for (int i = 0; i < self.teaserGrouping.teaserComponents.count; i++) {
        RITeaserComponent* component = [self.teaserGrouping.teaserComponents objectAtIndex:i];
        
        
        JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                           self.scrollView.bounds.origin.y,
                                                                                           componentWidth,
                                                                                           self.scrollView.bounds.size.height)];
        clickableView.tag = i;
        clickableView.backgroundColor = [UIColor whiteColor];
        [clickableView addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:clickableView];
        
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
        
        CGFloat imageHeight = 90; //value by design
        NSString* imageUrl = component.imagePortraitUrl;
        UIImageView* imageView = [UIImageView new];
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
        [imageView setFrame:CGRectMake(clickableView.bounds.origin.x,
                                       clickableView.bounds.size.height - imageHeight,
                                       clickableView.bounds.size.width,
                                       imageHeight)];
        [clickableView addSubview:imageView];
        
        currentX += clickableView.frame.size.width + margin;
    }
    
    [self.scrollView setContentSize:CGSizeMake(currentX,
                                               self.scrollView.frame.size.height)];
}

@end
