//
//  NavigationBarProtocol.h
//  Bamilo
//
//  Created by Ali Saeedifar on 7/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NavBarItemTypes.h"

@protocol NavigationBarProtocol <NSObject>

@optional
- (UIView *)navBarTitleView;
- (NSString *)navBarTitleString;
- (NavBarLeftButtonType)navBarleftButton;
- (BOOL)navBarhideBackButton;
- (void)searchIconButtonTapped;
- (void)cartIconButtonTapped;
@end
