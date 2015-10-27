//
//  JATabBarView.m
//  Jumia
//
//  Created by Telmo Pinto on 21/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JATabBarView.h"
#import "JATabBarButton.h"

#define kButtonIds @[@"home", @"wishlist", @"cart", @"user", @"more"]

@interface JATabBarView()

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSMutableArray* tabButtonsArray;

@end

@implementation JATabBarView

- (void)initialSetup
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.tabButtonsArray = [NSMutableArray new];
    
    CGFloat currentX = 0.0f;
    for (int i = 0; i<kButtonIds.count; i++) {
        NSString* identifier = [kButtonIds objectAtIndex:i];

        CGFloat width = self.frame.size.width/kButtonIds.count;
        
        NSString* buttonNameNormal = [NSString stringWithFormat:@"tabbar_button_%@", identifier];
        NSString* buttonNameHighlighted = [NSString stringWithFormat:@"tabbar_button_%@_highlighted", identifier];

        JATabBarButton* tabButton = [[JATabBarButton alloc] init];
        tabButton.frame = CGRectMake(currentX,
                                     self.bounds.origin.y,
                                     width,
                                     self.bounds.size.height);
        tabButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [tabButton setupWithImageName:buttonNameNormal highlightedImageName:buttonNameHighlighted title:identifier];
        tabButton.clickableView.tag = i;
        [tabButton.clickableView addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tabButton];
        [self.tabButtonsArray addObject:tabButton];
        
        currentX += width;
    }
    
    [self updateCartNumber:0];
}

- (void)buttonPressed:(UIControl*)sender
{
    [self selectButtonAtIndex:sender.tag];
    
    NSString* identifier = [kButtonIds objectAtIndex:sender.tag];
    
    if ([identifier isEqualToString:@"home"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
    } else if ([identifier isEqualToString:@"wishlist"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowFavoritesScreenNotification object:nil];
    } else if ([identifier isEqualToString:@"cart"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCartNotification object:nil];
    } else if ([identifier isEqualToString:@"user"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMyAccountScreenNotification object:nil];
    } else if ([identifier isEqualToString:@"more"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMoreMenuScreenNotification object:nil];
    }
}

- (void)selectButtonAtIndex:(NSInteger)index;
{
    if (index < kButtonIds.count) {
        JATabBarButton* previousTab = [self.tabButtonsArray objectAtIndex:self.selectedIndex];
        previousTab.selected = NO;
        JATabBarButton* currentTab = [self.tabButtonsArray objectAtIndex:index];
        currentTab.selected = YES;
        self.selectedIndex = index;
    }
}

- (void)updateCartNumber:(NSInteger)cartNumber
{
    JATabBarButton* cartButton = [self.tabButtonsArray objectAtIndex:2];
    [cartButton setNumber:cartNumber];
}

@end
