//
//  BaseNavigationController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 1/29/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarConfigs];
    // Do any additional setup after loading the view.
}

- (void)setNavigationBarConfigs {
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName: [Theme font:kFontVariationRegular size:13],
                                                             NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    //To change back button icon
    UIImage *myImage = [UIImage imageNamed:@"btn_back"]; //set your backbutton imagename
    UIImage *backButtonImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    if (SYSTEM_VERSION_GREATER_THAN(@"9.0")) {
        
        if (SYSTEM_VERSION_GREATER_THAN(@"11.0")) {
            myImage = [UIImage imageNamed:@"left_btn_back"]; //set your backbutton imagename
            backButtonImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        
        //To remove navBar bottom border
        [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setShadowImage:[UIImage new]];
        
        // now use the new backButtomImage
        [[UINavigationBar appearance] setBackIndicatorImage:backButtonImage];
        [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backButtonImage];
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    
    //To set navigation bar background color
    self.navigationBar.barTintColor = [Theme color:kColorExtraDarkBlue];
    self.navigationBar.tintColor = [UIColor whiteColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
