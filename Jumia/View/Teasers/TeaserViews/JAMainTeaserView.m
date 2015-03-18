//
//  JAMainTeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMainTeaserView.h"
#import "UIButton+WebCache.h"
#import "JAClickableView.h"

#define JAMainTeaserViewHeight 173.0f

@interface JAMainTeaserView()

@property (nonatomic, strong)UIScrollView* scrollView;

@end

@implementation JAMainTeaserView

- (void)load;
{
    [super load];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              self.frame.size.width / 2)];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    CGFloat currentX = 0;
    
    for (int i = 0; i < self.teasers.count; i++) {
        RITeaser* teaser = [self.teasers objectAtIndex:i];
        
        RITeaserImage* teaserImage;
        
        if (1 == teaser.teaserImages.count) {
            
            teaserImage = [teaser.teaserImages firstObject];
            
        } else {
            for (RITeaserImage* possibleTeaserImage in teaser.teaserImages) {
                
                NSString* deviceType;
                if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    deviceType = @"tablet";
                } else {
                    deviceType = @"phone";
                }
                
                if ([possibleTeaserImage.deviceType isEqualToString:deviceType]) {
                    
                    teaserImage = possibleTeaserImage;
                    break;
                }
            }
        }
        
        JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                           self.scrollView.bounds.origin.y,
                                                                                           self.scrollView.bounds.size.width,
                                                                                           self.scrollView.bounds.size.height)];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:clickableView.bounds];
        [button setEnabled:NO];
        [button setBackgroundColor:UIColorFromRGB(0xffffff)];
        [button setImageWithURL:[NSURL URLWithString:teaserImage.imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
        [clickableView addSubview:button];
        [clickableView addTarget:self action:@selector(teaserImagePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:clickableView];
        
        currentX += clickableView.frame.size.width;
    }
    
    [self.scrollView setContentSize:CGSizeMake(currentX,
                                               self.scrollView.frame.size.height)];
}

- (void)teaserImagePressed:(UIControl*)control
{
    NSInteger index = control.tag;
    
    RITeaser* teaser = [self.teasers objectAtIndex:index];
    RITeaserImage* teaserImage = [teaser.teaserImages firstObject];
    
    if (2 == [teaser.targetType integerValue]) {
        [self teaserPressedWithTitle:@"" inCampaignTeasers:[self.teasers array]];
    } else {
        [self teaserPressedWithTeaserImage:teaserImage
                                targetType:[teaser.targetType integerValue]];
    
    }
}

@end
