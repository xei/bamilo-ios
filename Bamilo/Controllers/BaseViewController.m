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
#import "NotificationBarView.h"
#import "EmarsysPredictManager.h"
#import "Bamilo-Swift.h"
#import "DataServiceProtocol.h"

@interface BaseViewController()
@property (strong, nonatomic) JAMessageView *messageView;
@end

@implementation BaseViewController {
@private
    NSDate *_startLoadingTime;
    ErrorControlView *errorView;
    BOOL _hasAppeared;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self recordStartLoadTime];
    self.title = nil;
    self.view.backgroundColor = JABackgroundGrey;
    if ([self getScreenName].length) {
        [TrackerManager trackScreenNameWithScreenName:[self getScreenName]];
    }
    
    //navigation bar configs
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    if ([self respondsToSelector:@selector(navBarTitleView)]){
        self.navigationItem.titleView = [self navBarTitleView];
    }
    if ([self respondsToSelector:@selector(navBarTitleString)]) {
        if ([[self navBarTitleString] isKindOfClass:[NSString class]] && [[self navBarTitleString] length]) {
            self.navigationItem.titleView = nil;
            self.title = [self navBarTitleString];
        }
    }
    if ([self respondsToSelector:@selector(navBarhideBackButton)]) {
        self.navigationItem.hidesBackButton = [self navBarhideBackButton];
    }
    
    if ([self respondsToSelector:@selector(navBarleftButton)]) {
        self.navigationItem.rightBarButtonItem = [self getNavbarItemButton:[self navBarleftButton]];
    }
    
    if ([self respondsToSelector:@selector(navBarRightButton)]) {
        self.navigationItem.leftBarButtonItem = [self getNavbarItemButton:[self navBarRightButton]];
    }
}

- (UIBarButtonItem *)getNavbarItemButton:(NavBarButtonType)navbarButtonType {
    if (navbarButtonType == NavBarButtonTypeSearch && [self respondsToSelector:@selector(searchIconButtonTapped)]) {
        return [NavBarUtility navBarButtonWithType:NavBarButtonTypeSearch viewController:self];
    }
    if (navbarButtonType == NavBarButtonTypeCart && [self respondsToSelector:@selector(cartIconButtonTapped)]) {
        return [NavBarUtility navBarButtonWithType:NavBarButtonTypeCart viewController:self];
    }
    if ((navbarButtonType == NavBarButtonTypeClose || navbarButtonType == NavBarButtonTypeDarkClose) && [self respondsToSelector:@selector(closeButtonTapped)]) {
        return [NavBarUtility navBarButtonWithType:navbarButtonType viewController:self];
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self conformsToProtocol:@protocol(EmarsysPredictProtocolBase)]) {
        if ([self respondsToSelector:@selector(isPreventSendTransactionInViewWillAppear)]) {
            if (![((id<EmarsysPredictProtocolBase>)self) isPreventSendTransactionInViewWillAppear]) {
                [EmarsysPredictManager sendTransactionsOf:self];
            }
        } else {
            [EmarsysPredictManager sendTransactionsOf:self];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (CGRect)viewBounds {
    if (SYSTEM_VERSION_GREATER_THAN(@"9.0")) {
        return self.view.bounds;
    }
    CGFloat statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.height;
    
    return CGRectMake(self.view.bounds.origin.x,
                      self.view.bounds.origin.y + navBarHeight + statusBarHeight,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - navBarHeight - statusBarHeight);
    
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
- (BOOL)showNotificationBar:(id)message isSuccess:(BOOL)success {
    if(success == NO) {
        if([message isKindOfClass:[NSError class]]) {
            NSError *error = (NSError *)message;
            id errorMessage = [error.userInfo[kErrorMessages] firstObject];
            if([errorMessage isKindOfClass:[NSString class]]) {
                return [self showNotificationBarMessage:errorMessage isSuccess:NO];
            }
        }
    }
    return NO;
}

- (BOOL)showNotificationBarFromMessageDictionary:(NSDictionary *)messageDict isSuccess:(BOOL)success {
    if(messageDict.count) {
        NSString *errorMessage = [messageDict objectForKey:kMessage];
        if (errorMessage && errorMessage.length) {
            return [self showNotificationBarMessage:errorMessage isSuccess:success];
        }
    }
    return NO;
}

- (void)showMessage:(NSArray <NSString *>*)successMessages showMessage:(BOOL)showMessage {
    if (showMessage) {
        [self showNotificationBarMessage:[successMessages componentsJoinedByString:@","] isSuccess:YES];
    }
}

//TEMP FUNCTION
- (NSArray *)extractSuccessMessages:(DataMessageList *)dataMessages {
    NSMutableArray *messages = [NSMutableArray array];
    for(DataMessage *msgObject in ((DataMessageList *)dataMessages).success) {
        [messages addObject:msgObject.message];
    }
    return messages;
}

- (BOOL)showNotificationBarMessage:(NSString *)message isSuccess:(BOOL)success {
    UIViewController *rootViewController = self; // [ViewControllerManager topViewController];
    [[NotificationBarView sharedInstance] show:rootViewController text:message isSuccess:success];
    return YES;
}

- (void)removeMessageView {
    [[NotificationBarView sharedInstance] dismiss];
}

#pragma mark - PerformanceTrackerProtocol
- (void)recordStartLoadTime {
    _startLoadingTime = [NSDate date];
}

- (void)publishScreenLoadTimeWithName:(NSString *)name withLabel:(NSString *)label {
    NSDate *publishTime = [NSDate date];
    NSTimeInterval publishInterVal = [publishTime timeIntervalSinceDate:_startLoadingTime];
    [TrackerManager trackLoadTimeWithScreenName:name interval:@((NSUInteger)(publishInterVal * 1000)) label:label];
}

- (void)handleGenericErrorCodesWithErrorControlView:(int)errorCode forRequestID:(int)rid {
    if (errorView) {
        [errorView removeFromSuperview];
    }
    errorView = [ErrorControlView nibInstance];
    if (errorView) {
        [errorView updateWith:errorCode callBack:^(void (^errorViewHandler)(BOOL)) {
            if ([self conformsToProtocol:@protocol(DataServiceProtocol)]) {
                [((id<DataServiceProtocol>)self) retryAction:^(BOOL success) {
                    errorViewHandler(success);
                } forRequestId:rid];
            }
        }];
        [self.view addSubview:errorView];
        [errorView bringSubviewToFront:self.view];
        [errorView bindFrameToSuperviewBounds];
    }
}

- (void)removeErrorView {
    [errorView removeFromSuperview];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return nil;
}

#pragma mark - NavigationBarProtocol
- (void)searchIconButtonTapped {
    [[MainTabBarViewController topNavigationController] showSearchView: [self getScreenName]];
}

- (void)cartIconButtonTapped {
    [MainTabBarViewController showCart];
}

- (void)closeButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateCartInNavBar {
    if ([self respondsToSelector:@selector(navBarleftButton)] && self.navBarleftButton == NavBarButtonTypeCart) {
        self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)[[RICart sharedInstance].cartEntity.cartCount integerValue]];
    }
}

@end
