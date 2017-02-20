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

@implementation BaseViewController {
@private
    NSDate *_startLoadingTime;
    BOOL _hasAppeared;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //PerformanceTrackerProtocol
    [self recordStartLoadTime];
    
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

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:kAppWillEnterForeground object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:kAppDidEnterBackground object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTurnOnMenuSwipePanelNotification object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kAppWillEnterForeground object:nil];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kAppDidEnterBackground object:nil];
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
- (BOOL) showNotificationBar:(id)message isSuccess:(BOOL)success {
    if(success == NO) {
        if([message isKindOfClass:[NSError class]]) {
            NSError *error = (NSError *)message;
            return [self showNotificationBarMessage:[error.userInfo[kErrorMessages] firstObject] isSuccess:NO];
        }
    }
    
    return NO;
}

- (BOOL)showNotificationBarMessage:(NSString *)message isSuccess:(BOOL)success {
    UIViewController *rootViewController = [ViewControllerManager topViewController];
    
    float messageViewY = 64;
    
    if(self.messageView == nil) {
        self.messageView = [[JAMessageView alloc] initWithFrame:CGRectMake(0, messageViewY, self.view.bounds.size.width, kMessageViewHeight)];
        [self.messageView setupView];
    }
    
    if(self.navigationController && self.navigationController.navigationBar) {
        messageViewY = 0;
    }
    [self.messageView setFrame:CGRectMake(0, messageViewY, self.view.bounds.size.width, kMessageViewHeight)];
    
    if (!VALID_NOTEMPTY([self.messageView superview], UIView)) {
        [rootViewController.view addSubview:self.messageView];
    }
    
    [self.messageView setTitle:message success:success];
    
    return YES;
}

- (void)removeMessageView {
    [self.messageView removeFromSuperview];
}

#pragma mark - PerformanceTrackerProtocol
-(void) recordStartLoadTime {
    _startLoadingTime = [NSDate date];
}

-(void) publishScreenLoadTime {
    //Publish the load time if it's the first load OR it's been forced
    if(_hasAppeared == NO || ([self respondsToSelector:@selector(forcePublishScreenLoadTime)] && [self forcePublishScreenLoadTime])) {
        NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:_startLoadingTime];
        NSString *screenName = [self getPerformanceTrackerScreenName];
        if(screenName) {
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:[NSNumber numberWithDouble:executionTime] reference:screenName label:[self getPerformanceTrackerLabel] ?: @""];
        }
        _hasAppeared = YES;
    }
}

-(NSString *) getPerformanceTrackerScreenName {
    return nil;
}

-(NSString *)getPerformanceTrackerLabel {
    return nil;
}

@end
