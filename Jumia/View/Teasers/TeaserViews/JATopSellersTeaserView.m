//
//  JATopSellersTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 23/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JATopSellersTeaserView.h"
#import "UIImageView+WebCache.h"
#import "JAClickableView.h"

@interface JATopSellersTeaserView()

@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JATopSellersTeaserView

- (void)load
{
    [super load];
    
    if (VALID_NOTEMPTY(self.teaserGrouping.teaserComponents, NSOrderedSet)) {
        CGFloat groupingTitleLabelMargin = 16.0f;
        CGFloat groupingTitleLabelHeight = 30.0f;
        UILabel* groupingTitleLabel = [UILabel new];
        groupingTitleLabel.font = [UIFont fontWithName:kFontMediumName size:14.0f];
        groupingTitleLabel.textColor = [UIColor blackColor];
        groupingTitleLabel.text = self.teaserGrouping.title;
        [groupingTitleLabel sizeToFit];
        [groupingTitleLabel setFrame:CGRectMake(groupingTitleLabelMargin,
                                                self.bounds.origin.y,
                                                self.frame.size.width - groupingTitleLabelMargin*2,
                                                groupingTitleLabelHeight)];
        [self addSubview:groupingTitleLabel];
        
        CGFloat margin = 6.0f; //value by design
        CGFloat componentHeight = 129.0f; //value by design
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x,
                                                                         self.bounds.origin.y + groupingTitleLabelHeight,
                                                                         self.bounds.size.width,
                                                                         componentHeight)];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        CGFloat componentWidth = 114; //value by design
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
            
            NSString* imageUrl = component.imagePortraitUrl;
            CGFloat imageTopMargin = 7.0f; //value by design
            CGFloat imageWidth = 100.0f; //value by design
            CGFloat imageHeight = 71.0f; //value by design
            UIImageView* imageView = [UIImageView new];
            [imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
            [imageView setFrame:CGRectMake((clickableView.bounds.size.width - imageWidth) / 2,
                                           imageTopMargin,
                                           imageWidth,
                                           imageHeight)];
            [clickableView addSubview:imageView];
            
            CGFloat textMarginY = 6.0;
            UILabel* nameLabel = [UILabel new];
            nameLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
            nameLabel.textColor = [UIColor blackColor];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.text = component.name;
            [nameLabel sizeToFit];
            [nameLabel setFrame:CGRectMake(imageView.frame.origin.x,
                                            CGRectGetMaxY(imageView.frame) + textMarginY,
                                            imageView.frame.size.width,
                                            nameLabel.frame.size.height)];
            [clickableView addSubview:nameLabel];
            
            UILabel* priceLabel = [UILabel new];
            priceLabel.font = [UIFont fontWithName:kFontRegularName size:10.0f];
            priceLabel.textColor = UIColorFromRGB(0xcc0000);
            priceLabel.textAlignment = NSTextAlignmentCenter;
            priceLabel.text = component.priceFormatted;
            [priceLabel sizeToFit];
            [priceLabel setFrame:CGRectMake(imageView.frame.origin.x,
                                               CGRectGetMaxY(nameLabel.frame),
                                               imageView.frame.size.width,
                                               priceLabel.frame.size.height)];
            [clickableView addSubview:priceLabel];
            
            currentX += clickableView.frame.size.width;
            
            if (i+1 != self.teaserGrouping.teaserComponents.count) {
                //not the last one, so add a separator
                UIView* separator = [UIView new];
                separator.backgroundColor = UIColorFromRGB(0xd8d8d8);
                [separator setFrame:CGRectMake(currentX - 1,
                                               clickableView.frame.origin.y,
                                               1,
                                               clickableView.frame.size.height)];
                [self.scrollView addSubview:separator];
            }
        }

        
        
        [self.scrollView setContentSize:CGSizeMake(currentX,
                                                   self.scrollView.frame.size.height)];
        
        CGFloat totalHeight = groupingTitleLabel.frame.size.height + self.scrollView.frame.size.height;
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  totalHeight)];
    }
}

@end