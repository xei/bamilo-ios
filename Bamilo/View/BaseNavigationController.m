//
//  BaseNavigationController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 1/29/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController() <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarConfigs];
}

- (void)setNavigationBarConfigs {
    self.navigationBar.titleTextAttributes = @{
       NSFontAttributeName: [Theme font:kFontVariationBold size:14],
       NSForegroundColorAttributeName: self.navbarTintColor ?: [UIColor darkGrayColor]
    };
    
    //To change back button icon
    UIImage *backImage = [UIImage imageNamed:@"btn_back"]; //set your backbutton imagename
    if (SYSTEM_VERSION_GREATER_THAN(@"11.0")) {
        backImage = [UIImage imageNamed:@"left_btn_back"]; //set your backbutton imagename
    }
    
    UIImage *backButtonImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    //To remove navBar bottom border
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
    
    // now use the new backButtomImage
    [[UINavigationBar appearance] setBackIndicatorImage: backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage: backButtonImage];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    //To set navigation bar background color
    self.navigationBar.barTintColor = self.navbarColor ?: [UIColor whiteColor];
    self.navigationBar.tintColor = self.navbarTintColor ?: [UIColor darkGrayColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
