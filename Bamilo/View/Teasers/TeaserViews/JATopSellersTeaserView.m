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
#import "JAPDVSingleRelatedItem.h"

@interface JATopSellersTeaserView()

@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JATopSellersTeaserView

- (void)load {
    [super load];
    
    NSOrderedSet* teaserComponents;
    NSString* title;
    if (VALID_NOTEMPTY(self.teaserGrouping, RITeaserGrouping)) {
        teaserComponents = self.teaserGrouping.teaserComponents;
        title = self.teaserGrouping.title;
    } else if (VALID_NOTEMPTY(self.featuredBoxTeaserGrouping, RIFeaturedBoxTeaserGrouping)) {
        teaserComponents = self.featuredBoxTeaserGrouping.teaserComponents;
        title = self.featuredBoxTeaserGrouping.title;
    }
    
    if (VALID_NOTEMPTY(teaserComponents, NSOrderedSet)) {
        CGFloat groupingTitleLabelMargin = 16.0f;
        CGFloat groupingTitleLabelHeight = 50.0f; //value by design
        UILabel* groupingTitleLabel = [UILabel new];
        groupingTitleLabel.font = JAHEADLINEFont;
        groupingTitleLabel.textColor = [UIColor blackColor];
        groupingTitleLabel.text = [title uppercaseString];
        groupingTitleLabel.textAlignment = NSTextAlignmentLeft;
        [groupingTitleLabel sizeToFit];
        [groupingTitleLabel setFrame:CGRectMake(groupingTitleLabelMargin, self.bounds.origin.y, self.frame.size.width - groupingTitleLabelMargin * 2, groupingTitleLabelHeight)];
        
        [self addSubview:groupingTitleLabel];
        
        CGFloat margin = 1.0f;
        CGSize itemSize = CGSizeMake(134, 210);
        CGFloat componentHeight = itemSize.height + 6.0f;
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.bounds.origin.x, self.bounds.origin.y + groupingTitleLabelHeight, self.bounds.size.width, componentHeight)];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        
        CGFloat currentX = margin;
        CGFloat componentWidth = 114; //value by design
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            componentWidth = 142.0f; //value by design
        }
        
        
        CGFloat relatedItemY = 0.f;
        
        for (int i = 0; i < teaserComponents.count; i++) {
            RITeaserComponent* component = [teaserComponents objectAtIndex:i];
            
            JAPDVSingleRelatedItem *singleItem = [[JAPDVSingleRelatedItem alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
            [singleItem setBackgroundColor:[UIColor whiteColor]];
            singleItem.tag = i;
            [singleItem addTarget:self action:@selector(teaserPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            CGRect tempFrame = singleItem.frame;
            tempFrame.origin.x = currentX;
            tempFrame.origin.y = relatedItemY;
            singleItem.frame = tempFrame;
            [singleItem setTeaserComponent:component];
            
            [self.scrollView addSubview:singleItem];
            currentX += singleItem.frame.size.width+margin;
        }
        
        if (currentX < self.scrollView.width) {
            currentX = self.scrollView.width;
        }
        [self.scrollView setContentSize:CGSizeMake(currentX, self.scrollView.frame.size.height)];
        
        CGFloat totalHeight = groupingTitleLabel.frame.size.height + self.scrollView.frame.size.height;
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, totalHeight)];
        
        if (RI_IS_RTL) {
            [self flipAllSubviews];
        }
    }
}

- (NSString*)teaserTrackingInfoForIndex:(NSInteger)index {
    NSString* teaserTrackingInfo = [NSString stringWithFormat:@"Top_Sellers_%ld",(long)index];
    return teaserTrackingInfo;
}

- (void)teaserPressedForIndex:(NSInteger)index {
    if (self.teaserGrouping) {
        [super teaserPressedForIndex:index];
    } else if (self.featuredBoxTeaserGrouping) {
        
        RITeaserComponent* teaserComponent = [self.featuredBoxTeaserGrouping.teaserComponents objectAtIndex:index];
        
        NSMutableDictionary* userInfo = [NSMutableDictionary new];
        [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
        if (teaserComponent.title.length) {
            [userInfo setObject:teaserComponent.title forKey:@"title"];
        }
        
        NSString* notificationName = kDidSelectTeaserWithPDVUrlNofication;
        
        if (VALID_NOTEMPTY(teaserComponent.targetString, NSString)) {
            [userInfo setObject:teaserComponent.targetString forKey:@"targetString"];
            
            if (VALID_NOTEMPTY(teaserComponent.richRelevance, NSString)) {
                [userInfo setObject:teaserComponent.richRelevance forKey:@"rich_relevance"];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:userInfo];
        }
    }
}

@end
