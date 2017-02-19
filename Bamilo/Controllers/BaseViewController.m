//
//  BaseViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "JAAppDelegate.h"
#import "JAMessageView.h"
#import "BaseViewController.h"
#import "ViewControllerManager.h"

@interface BaseViewController()
@property (strong, nonatomic) JAMessageView *messageView;
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.hidesBackButton = YES;
    self.title = nil;
    self.view.backgroundColor = JABackgroundGrey;
}

- (JANavigationBarLayout *)navBarLayout {
    if (!_navBarLayout) {
        _navBarLayout = [[JANavigationBarLayout alloc] init];
    }
    return _navBarLayout;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateNavBar];
    
    [self requestNavigationBarReload];
    [self requestTabBarReload];
    
    if([self getIsSideMenuAvailable]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOnMenuSwipePanelNotification object:nil];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:kAppDidEnterBackground object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTurnOnMenuSwipePanelNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppDidEnterBackground object:nil]; //???? what ?????
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Private Methods
- (void)requestNavigationBarReload {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeNavigationBarNotification object:self.navBarLayout];
}

- (void)requestTabBarReload {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBarVisibility object:[NSNumber numberWithBool:[self getTabBarVisible]]];
}

#pragma mark - Public Methods
- (void)updateNavBar {
    return;
}

#pragma mark - SideMenuProtocol
- (BOOL)getIsSideMenuAvailable {
    return YES;
}

#pragma mark - TabBarProtocol
- (BOOL)getTabBarVisible {
    return NO;
}

# pragma mark - Message View
- (void)showNotificationBar:(NSString *)message isSuccess:(BOOL)success {
    UIViewController *rootViewController = [ViewControllerManager topViewController];
    
    if (!VALID_NOTEMPTY(self.messageView, JAMessageView)) {
        self.messageView = [[JAMessageView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, kMessageViewHeight)];
        [self.messageView setupView];
    } else {
        [self.messageView setFrame:CGRectMake(0, 64, self.view.bounds.size.width, kMessageViewHeight)];
    }
    
    if (!VALID_NOTEMPTY([self.messageView superview], UIView)) {
        [rootViewController.view addSubview:self.messageView];
    }
    [self.messageView setTitle:message success:success];
}

- (void)removeMessageView {
    [self.messageView removeFromSuperview];
}

@end
