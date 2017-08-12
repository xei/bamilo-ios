//
//  NavigationBarProtocol.h
//  Bamilo
//
//  Created by Ali Saeedifar on 7/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NavbarItemTypes.h"

@protocol NavigationBarProtocol <NSObject>

@optional
- (UIView *)navbarTitleView;
- (NSString *)navbarTitleString;
- (NavbarLeftButtonType)navbarleftButton;
- (BOOL)navbarhideBackButton;
- (void)searchIconButtonTapped;
- (void)cartIconButtonTapped;
@end
