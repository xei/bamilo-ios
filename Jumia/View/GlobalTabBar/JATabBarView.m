//
//  JATabBarView.m
//  Jumia
//
//  Created by Telmo Pinto on 21/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JATabBarView.h"

#define kButtonIds @[@"home", @"wishlist", @"cart", @"user", @"more"]

@interface JATabBarView()

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) NSArray* tabButtonsArray;

@end

@implementation JATabBarView

- (void)initialSetup
{
    self.backgroundColor = [UIColor redColor];
    
    CGFloat currentX = 0.0f;
    for (int i = 0; i<kButtonIds.count; i++) {
        NSString* identifier = [kButtonIds objectAtIndex:i];

        CGFloat width = self.frame.size.width/kButtonIds.count;
        
        NSString* buttonNameNormal = [NSString stringWithFormat:@"tabbar_button_%@", identifier];
        UIImage* buttonImageNormal = [UIImage imageNamed:buttonNameNormal];
        
        NSString* buttonNameHighlighted = [NSString stringWithFormat:@"tabbar_button_%@_highlighted", identifier];
        UIImage* buttonImageHighlight = [UIImage imageNamed:buttonNameHighlighted];
        
        UIButton* tabButton = [UIButton new];
        [tabButton setImage:buttonImageNormal forState:UIControlStateNormal];
        [tabButton setImage:buttonImageHighlight forState:UIControlStateHighlighted];
        tabButton.frame = CGRectMake(currentX,
                                     self.bounds.origin.y,
                                     width,
                                     self.bounds.size.height);
        tabButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        tabButton.tag = i;
        [tabButton setTitle:identifier forState:UIControlStateNormal];
        [tabButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tabButton];
        
        currentX += width;
    }
}

- (void)buttonPressed:(UIButton*)sender
{
    NSString* identifier = [kButtonIds objectAtIndex:sender.tag];
    
    for (UIButton* button in self.tabButtonsArray) {
        button.selected = NO;
    }
    sender.selected = YES;
    self.selectedIndex = sender.tag;
    
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

@end
