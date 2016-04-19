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
    
    CGFloat marginX= 6.0f; //value by design
    CGFloat marginY= 10.0f; //value by design
    CGFloat heightWithoutMargins = 146; //value by design
    CGFloat totalHeight = heightWithoutMargins + marginY*2;
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              totalHeight)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                     self.bounds.origin.y + marginY,
                                                                     self.bounds.size.width,
                                                                     self.bounds.size.height - 2*marginY)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    CGFloat componentWidth = 112; //value by design
    CGFloat currentX = marginX;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        totalHeight += marginY; //the top margin is doubled on ipad, so add another margin to the total
        componentWidth = 210; //value by design
        currentX = marginX*2; //the first margin is doubled
    }
    
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
        
        CGFloat textMarginX = 6.0;
        CGFloat textMarginY = 4.0;
        UILabel* titleLabel = [UILabel new];
        titleLabel.font = JATitleFont;
        titleLabel.textColor = JABlackColor;
        titleLabel.text = component.title;
        [titleLabel sizeToFit];
        [titleLabel setFrame:CGRectMake(clickableView.bounds.origin.x + textMarginX,
                                        clickableView.bounds.origin.y + textMarginY,
                                        clickableView.bounds.size.width - textMarginX*2,
                                        titleLabel.frame.size.height)];
        [clickableView addSubview:titleLabel];
        
        UILabel* subTitleLabel = [UILabel new];
        subTitleLabel.font = JACaptionFont;
        CGFloat subtitleYOffset = 0.0f;
        if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
        {
            //SHOP font adjustment
            subtitleYOffset = -2.0f;
            subTitleLabel.font = [UIFont fontWithName:kFontLightName size:subTitleLabel.font.pointSize-1];
        }
        subTitleLabel.textColor = JABlack800Color;
        subTitleLabel.text = component.subTitle;
        [subTitleLabel sizeToFit];
        [subTitleLabel setFrame:CGRectMake(clickableView.bounds.origin.x + textMarginX,
                                           CGRectGetMaxY(titleLabel.frame) + subtitleYOffset,
                                           clickableView.bounds.size.width - textMarginX*2,
                                           subTitleLabel.frame.size.height)];
        [clickableView addSubview:subTitleLabel];
        
        CGFloat imageWidth = clickableView.bounds.size.width;
        
        titleLabel.textAlignment = NSTextAlignmentLeft;
        subTitleLabel.textAlignment = NSTextAlignmentLeft;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            titleLabel.textAlignment = NSTextAlignmentCenter;
            subTitleLabel.textAlignment = NSTextAlignmentCenter;
            imageWidth = 112; //value by design
        }
        
        CGFloat imageHeight = 112; //value by design
        NSString* imageUrl = component.imagePortraitUrl;
        UIImageView* imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
        [imageView setFrame:CGRectMake((clickableView.bounds.size.width - imageWidth)/2,
                                       clickableView.bounds.size.height - imageHeight,
                                       imageWidth,
                                       imageHeight)];
        [clickableView addSubview:imageView];
        
        currentX += clickableView.frame.size.width + marginX;
    }
    
    [self.scrollView setContentSize:CGSizeMake(currentX, self.scrollView.frame.size.height)];
    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (self.scrollView.contentSize.width < self.frame.size.width) {
            [self.scrollView setFrame: CGRectMake((self.frame.size.width - self.scrollView.contentSize.width) / 2,
                                                  self.scrollView.frame.origin.y,
                                                  self.scrollView.contentSize.width,
                                                  self.scrollView.frame.size.height)];
        }
    }
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (NSString*)teaserTrackingInfoForIndex:(NSInteger)index;
{
    NSString* teaserTrackingInfo = [NSString stringWithFormat:@"Small_Teaser_%ld",(long)index];
    return teaserTrackingInfo;
}

@end
