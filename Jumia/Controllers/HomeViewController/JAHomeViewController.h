//
//  JAHomeViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANavigationBar.h"
#import "JATeaserCategoryScrollView.h"

@interface JAHomeViewController : JABaseViewController <JATeaserCategoryScrollViewDelegate>

- (void)setNavigationBar:(JANavigationBar *)navBar;

@end
