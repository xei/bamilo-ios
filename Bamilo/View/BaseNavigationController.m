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
    // Do any additional setup after loading the view.
    
    self.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.interactivePopGestureRecognizer.delegate = self;
    [self.interactivePopGestureRecognizer setEnabled:YES];
}

- (void)setNavigationBarConfigs {
    self.navigationBar.titleTextAttributes = @{NSFontAttributeName: [Theme font:kFontVariationRegular size:13], NSForegroundColorAttributeName: self.navbarTintColor ?: [UIColor whiteColor]};
    
    //To change back button icon
    UIImage *myImage = [UIImage imageNamed:@"btn_back"]; //set your backbutton imagename
    UIImage *backButtonImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    if (SYSTEM_VERSION_GREATER_THAN(@"11.0")) {
        myImage = [UIImage imageNamed:@"left_btn_back"]; //set your backbutton imagename
        backButtonImage = [myImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    //To remove navBar bottom border
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
    
    // now use the new backButtomImage
    [[UINavigationBar appearance] setBackIndicatorImage: backButtonImage];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage: backButtonImage];
    [[UINavigationBar appearance] setTranslucent:NO];
    
    //To set navigation bar background color
    self.navigationBar.barTintColor = self.navbarColor ?: [Theme color:kColorExtraDarkBlue];
    self.navigationBar.tintColor = self.navbarTintColor ?: [UIColor whiteColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

// --- These two functions has been implemented becasue of IOS SDK Bug of swipe back gesture
// --- in root viewcontroller !
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (self.viewControllers.count > 1) {
            self.interactivePopGestureRecognizer.delegate = self;
            self.interactivePopGestureRecognizer.enabled = YES;
        } else {
            self.interactivePopGestureRecognizer.delegate = nil;
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        return self.viewControllers.count > 1;
    }
    return NO;
}

@end
