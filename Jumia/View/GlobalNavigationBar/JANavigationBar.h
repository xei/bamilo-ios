//
//  JANavigationBar.h
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANavigationBarView.h"

@protocol JANavigationBarDelegate <NSObject>

- (void)customNavigationBarOpenMenu;

@end

@interface JANavigationBar : UINavigationBar

@property (strong, nonatomic) JANavigationBarView *navigationBarView;
@property (weak, nonatomic) id<JANavigationBarDelegate>customDelegate;

- (void)changeNavigationBarTitle:(NSString *)newTitle;
- (void)changedToHomeViewController;

@end
