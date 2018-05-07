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
- (UIView *)navBarTitleView;
- (NSString *)navBarTitleString;
- (NavBarButtonType)navBarleftButton;
- (NavBarButtonType)navBarRightButton;
- (BOOL)navBarhideBackButton;
- (void)searchIconButtonTapped;
- (void)cartIconButtonTapped;
- (void)closeButtonTapped;

@end
