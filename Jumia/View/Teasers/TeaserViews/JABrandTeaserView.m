//
//  JABrandTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 22/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JABrandTeaserView.h"
#import "UIImageView+WebCache.h"
#import "JAClickableView.h"

@interface JABrandTeaserView()

@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JABrandTeaserView

- (void)load
{
    [super load];
    
    CGFloat topAreaHeight = 50.0f; //value by design
    CGFloat bottomAreaHeight = 30.0f; //value by design
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        bottomAreaHeight = 50.0f;
    }
    CGFloat totalHeight = topAreaHeight + bottomAreaHeight;
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              totalHeight)];
    
    CGFloat groupingTitleLabelMargin = 16.0f;
    UILabel* groupingTitleLabel = [UILabel new];
    groupingTitleLabel.font = [UIFont fontWithName:kFontMediumName size:14.0f];
    groupingTitleLabel.textColor = [UIColor blackColor];
    groupingTitleLabel.text = STRING_SHOPS_OF_THE_WEEK;
    groupingTitleLabel.textAlignment = NSTextAlignmentLeft;
    [groupingTitleLabel sizeToFit];
    [groupingTitleLabel setFrame:CGRectMake(groupingTitleLabelMargin,
                                            0.0f,
                                            self.frame.size.width - groupingTitleLabelMargin*2,
                                            topAreaHeight)];
    
    [self addSubview:groupingTitleLabel];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                     CGRectGetMaxY(groupingTitleLabel.frame),
                                                                     self.bounds.size.width,
                                                                     bottomAreaHeight)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    CGFloat componentWidth = 88; //value by design
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        componentWidth = 94.0f; //value by design
    }
    CGFloat currentX = 6.0f;
    
    if (self.frame.size.width-currentX > componentWidth*self.teaserGrouping.teaserComponents.count) {
        componentWidth = (self.frame.size.width-currentX*2) / self.teaserGrouping.teaserComponents.count;
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
        
        NSString* imageUrl = component.imagePortraitUrl;
        UIImageView* imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
        [imageView setFrame:CGRectMake(clickableView.bounds.origin.x,
                                       clickableView.bounds.origin.y,
                                       clickableView.bounds.size.width,
                                       clickableView.bounds.size.height)];
        [clickableView addSubview:imageView];
        
        currentX += clickableView.frame.size.width;
    }
    
    [self.scrollView setContentSize:CGSizeMake(currentX,
                                               self.scrollView.frame.size.height)];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (NSString*)teaserTrackingInfoForIndex:(NSInteger)index;
{
    NSString* teaserTrackingInfo = [NSString stringWithFormat:@"Brand_Teaser_%ld",(long)index];
    return teaserTrackingInfo;
}


@end
