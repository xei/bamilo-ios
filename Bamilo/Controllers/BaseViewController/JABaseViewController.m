//
//  JABaseViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAAppDelegate.h"
#import "JANoConnectionView.h"
#import "JAMaintenancePage.h"
#import "JAKickoutView.h"
#import "JAFallbackView.h"
#import "JACenterNavigationController.h"
#import "ViewControllerManager.h"
#import "NotificationBarView.h"
#import "Bamilo-Swift.h"


@interface JABaseViewController () {
    CGRect _noConnectionViewFrame;
    NSString* _searchBarText;
}

@property (assign, nonatomic) int requestNumber;
@property (strong, nonatomic) JANoConnectionView *noConnectionView;
@property (strong, nonatomic) JAMessageView *messageView;
@property (strong, nonatomic) JAMaintenancePage *maintenancePage;
@property (strong, nonatomic) JAKickoutView *kickoutView;
@property (nonatomic, strong) UIButton *searchBarBackButton;
@property (nonatomic) UIInterfaceOrientation orientation;

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *searchBarBackground;

@end

@implementation JABaseViewController {
@private
    NSDate *_startLoadingTime;
    BOOL _hasAppeared;
}

- (CGRect)viewBounds {
    CGFloat topOffset = 0.0f;

    if (SYSTEM_VERSION_GREATER_THAN(@"9.0")) {
        return CGRectMake(self.view.bounds.origin.x,
                          self.view.bounds.origin.y + topOffset,
                          self.view.bounds.size.width,
                          self.view.bounds.size.height - topOffset);
    }
    
    CGFloat statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
    CGFloat navBarHeight = self.navigationController.navigationBar.height;
    
    return CGRectMake(self.view.bounds.origin.x,
                      self.view.bounds.origin.y + topOffset + navBarHeight + statusBarHeight,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - topOffset - navBarHeight - statusBarHeight);
}

- (CGRect)bounds {
    CGFloat offset = 0.0f;
    CGFloat heightOffset = 0.0f;

    if (self.navigationController.navigationBar) {
        heightOffset = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    }
    return CGRectMake(self.view.bounds.origin.x,
                      self.view.bounds.origin.y + offset,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - offset);
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self recordStartLoadTime];
    
    self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.view.backgroundColor = JABackgroundGrey;
    self.requestNumber = 0;
    
    if ([self getScreenName].length) {
        [TrackerManager trackScreenNameWithScreenName:[self getScreenName]];
    }
    
    //navigation bar configs
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    if ([self respondsToSelector:@selector(navBarTitleView)]){
        self.navigationItem.titleView = [self navBarTitleView];
    }
    if ([self respondsToSelector:@selector(navBarTitleString)]) {
        self.title = [self navBarTitleString];
    }
    if ([self respondsToSelector:@selector(navBarhideBackButton)]) {
        self.navigationItem.hidesBackButton = [self navBarhideBackButton];
    }
    if ([self respondsToSelector:@selector(navBarleftButton)]) {
        if ([self navBarleftButton] == NavBarButtonTypeSearch && [self respondsToSelector:@selector(searchIconButtonTapped)]) {
            self.navigationItem.rightBarButtonItem = [NavBarUtility navBarButtonWithType:NavBarButtonTypeSearch viewController:self];
        }
        if ([self navBarleftButton] == NavBarButtonTypeCart && [self respondsToSelector:@selector(cartIconButtonTapped)]) {
            self.navigationItem.rightBarButtonItem = [NavBarUtility navBarButtonWithType:NavBarButtonTypeCart viewController:self];
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self changeLoadingFrame:[[UIScreen mainScreen] bounds] orientation:toInterfaceOrientation];
    
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    if (VALID_NOTEMPTY(self.maintenancePage, JAMaintenancePage)) {
        [self.maintenancePage setupMaintenancePage:CGRectMake(0.0f, 0.0f, window.frame.size.height, window.frame.size.width) orientation:toInterfaceOrientation];
    }
    
    if (VALID_NOTEMPTY(self.kickoutView, JAKickoutView)) {
        [self.kickoutView setupKickoutView:CGRectMake(0.0f, 0.0f, window.frame.size.height, window.frame.size.width) orientation:toInterfaceOrientation];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)changeLoadingFrame:(CGRect)frame orientation:(UIInterfaceOrientation)orientation {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
         UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
         // do whatever
         CGRect viewFrame = self.view.frame;
         CGFloat screenWidth = viewFrame.size.width;
         CGFloat screenHeight = viewFrame.size.height;
         
         if (self.noConnectionView) {
             self.noConnectionView.frame = CGRectMake(_noConnectionViewFrame.origin.x, _noConnectionViewFrame.origin.y, screenWidth, screenHeight);
             [self.noConnectionView reDraw];
             [self.view bringSubviewToFront:self.noConnectionView];
         }
        
         UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
         if (self.maintenancePage) {
             [self.maintenancePage setupMaintenancePage:CGRectMake(0.0f, 0.0f, window.frame.size.width, window.frame.size.height) orientation:orientation];
         }
         if (self.kickoutView) {
             [self.kickoutView setupKickoutView:CGRectMake(0.0f, 0.0f, window.frame.size.width, window.frame.size.height) orientation:orientation];
         }
     } completion: nil];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:kAppDidEnterBackground object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppDidEnterBackground object:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    }
    return supportedInterfaceOrientations;
}

- (void)setSearchBarText:(NSString*)text {
    _searchBarText = text;
}

# pragma mark - Loading View
- (void)showLoading {
    self.requestNumber++;
    
    [self changeLoadingFrame:[[UIScreen mainScreen] bounds] orientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if (1 == self.requestNumber) {
        [LoadingManager showLoading];
    }
}

- (void)hideLoading {
    self.requestNumber--;
    if (self.requestNumber < 0) {
        self.requestNumber = 0;
    }
    if (0 == self.requestNumber) {
        [LoadingManager hideLoading];
    }
}

- (void)cancelLoading {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelLoadingNotificationName object:nil];
}

# pragma mark Message View
- (void)showMessage:(NSString *)message success:(BOOL)success {
    UIViewController *rootViewController = [ViewControllerManager topViewController];
    [[NotificationBarView sharedInstance] show:rootViewController text:message isSuccess:success];
}

- (void)removeMessageView {
    [[NotificationBarView sharedInstance] dismiss];
}

# pragma mark Error Views
- (void)onSuccessResponse:(RIApiResponse)apiResponse messages:(NSArray *)successMessages showMessage:(BOOL)showMessage {
    [self removeErrorView];
    if (showMessage) {
        [self showMessage:[successMessages componentsJoinedByString:@","] success:YES];
    }
}

- (void)onErrorResponse:(RIApiResponse)apiResponse messages:(NSArray *)errorMessages showAsMessage:(BOOL)showAsMessage selector:(SEL)selector objects:(NSArray *)objects {
    [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:showAsMessage target:self selector:selector objects:objects];
}

- (void)onErrorResponse:(RIApiResponse)apiResponse messages:(NSArray *)errorMessages showAsMessage:(BOOL)showAsMessage target:(id)target selector:(SEL)selector objects:(NSArray *)objects {
    [self removeErrorView];
    if (RIApiResponseAuthorizationError == apiResponse) {
        [self showAuthenticationPage:target selector:selector objects:objects];
    } else if (RIApiResponseMaintenancePage == apiResponse) {
        [self showMaintenancePage:target selector:selector objects:objects];
    } else if(RIApiResponseKickoutView == apiResponse) {
        [self showKickoutView:target selector:selector objects:objects];
    } else if (RIApiResponseNoInternetConnection == apiResponse) {
        if (showAsMessage) {
            [self showMessage:STRING_NO_CONNECTION success:NO];
        } else {
            [self showErrorView:YES startingY:self.viewBounds.origin.y target:target selector:selector objects:objects];
        }
    } else if (showAsMessage) {
        if (VALID_NOTEMPTY(errorMessages, NSArray)) {
            [self showMessage:[errorMessages componentsJoinedByString:@", "] success:NO];
        }
    } else {
        [self showErrorView:NO startingY:self.viewBounds.origin.y target:target selector:selector objects:objects];
    }
}

- (void)showErrorView:(BOOL)isNoInternetConnection startingY:(CGFloat)startingY selector:(SEL)selector objects:(NSArray *)objects {
    [self showErrorView:isNoInternetConnection startingY:startingY target:self selector:selector objects:objects];
}

- (void)showErrorView:(BOOL)isNoInternetConnection startingY:(CGFloat)startingY target:(id)target selector:(SEL)selector objects:(NSArray *)objects {
    
    if (self.noConnectionView) {
        //[self.noConnectionView removeFromSuperview];
    } else {
        self.noConnectionView = [JANoConnectionView getNewJANoConnectionViewWithFrame:self.viewBounds];
        //This is to avoid a retain cycle
        __block id viewController = target;
        [self.noConnectionView setRetryBlock: ^(BOOL dismiss)
         {
             if ([viewController respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                 if (ISEMPTY(objects)) {
                     [viewController performSelector:selector];
                 } else if (1 == [objects count]) {
                     [viewController performSelector:selector withObject:[objects objectAtIndex:0]];
                 } else if (2 == [objects count]) {
                     [viewController performSelector:selector withObject:[objects objectAtIndex:0] withObject:[objects objectAtIndex:1]];
                 }
#pragma clang diagnostic pop
             }
         }];
        [self.view addSubview:self.noConnectionView];
    }
    
    [self.noConnectionView setupNoConnectionViewForNoInternetConnection:isNoInternetConnection];
    _noConnectionViewFrame = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        if (_noConnectionViewFrame.size.width > _noConnectionViewFrame.size.height) {
            _noConnectionViewFrame  = CGRectMake(0.0f, startingY, _noConnectionViewFrame.size.height, _noConnectionViewFrame.size.width - startingY);
        }
        else {
            _noConnectionViewFrame  = CGRectMake(0.0f, startingY, _noConnectionViewFrame.size.width, _noConnectionViewFrame.size.height - startingY);
        }
    }
    else {
        if (_noConnectionViewFrame.size.width > _noConnectionViewFrame.size.height) {
            _noConnectionViewFrame  = CGRectMake(0.0f, startingY, _noConnectionViewFrame.size.width, _noConnectionViewFrame.size.height - startingY);
        }
        else {
            _noConnectionViewFrame  = CGRectMake(0.0f, startingY, _noConnectionViewFrame.size.height, _noConnectionViewFrame.size.width - startingY);
        }
    }
    [self.noConnectionView setFrame:_noConnectionViewFrame];
    [self.view bringSubviewToFront:self.noConnectionView];
}

- (void)removeErrorView {
    [self.noConnectionView removeFromSuperview];
    self.noConnectionView = nil;
}

- (void)showAuthenticationPage:(id)target selector:(SEL)selector objects:(NSArray *)objects {
    // This is to avoid a retain cycle
    __block id viewController = target;
    __block void (^block)(void) = ^{
        if ([viewController respondsToSelector:selector]) {
            if (ISEMPTY(objects)) {
                ((void (*)(id, SEL))[viewController methodForSelector:selector])(viewController, selector);
            } else if (1 == [objects count]) {
                ((void (*)(id, SEL, id))[viewController methodForSelector:selector])(viewController, selector, [objects objectAtIndex:0]);
            }
            else if (2 == [objects count]) {
                ((void (*)(id, SEL, id, id))[viewController methodForSelector:selector])(viewController, selector, [objects objectAtIndex:0], [objects objectAtIndex:1]);
            }
        }
    };
    if ([CurrentUserManager isUserLoggedIn]) {
//        [RICustomer autoLogin:^(BOOL success) {
//            if (success) {
//                block();
//            } else {
//                [CurrentUserManager cleanFromDB];
//                [(JACenterNavigationController *)self.navigationController performProtectedBlock:^(BOOL userHadSession) {
//                    block();
//                }];
//            }
//        }];
    } else{
        [(JACenterNavigationController *)self.navigationController performProtectedBlock:^(BOOL userHadSession) {
            block();
        }];
    }
}

- (void)showMaintenancePage:(id)target selector:(SEL)selector objects:(NSArray *)objects {
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    
    self.maintenancePage = [JAMaintenancePage getNewJAMaintenancePage];
    [self.maintenancePage setupMaintenancePage:window.frame orientation:[[UIApplication sharedApplication] statusBarOrientation]];
    __block id viewController = target;
    [self.maintenancePage setRetryBlock: ^(BOOL dismiss)
     {
         if ([viewController respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             if (ISEMPTY(objects)) {
                 [viewController performSelector:selector];
             }
             else if (1 == [objects count]) {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0]];
             }
             else if (2 == [objects count]) {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0] withObject:[objects objectAtIndex:1]];
             }
#pragma clang diagnostic pop
         }
     }];
    
    for (UIView *view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAMaintenancePage class]]) {
            [view removeFromSuperview];
        }
    }
    
    [window.rootViewController.view addSubview:self.maintenancePage];
}

- (void)removeMaintenancePage {
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    for (UIView *view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAMaintenancePage class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}

- (void)showKickoutView:(id)target selector:(SEL)selector objects:(NSArray *)objects {
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    
    self.kickoutView = [[JAKickoutView alloc] init];
    [self.kickoutView setupKickoutView:window.frame orientation:[[UIApplication sharedApplication] statusBarOrientation]];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    __block id viewController = target;
    [self.kickoutView setRetryBlock: ^(BOOL dismiss) {
         if ([viewController respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             if (ISEMPTY(objects)) {
                 [viewController performSelector:selector];
             }
             else if (1 == [objects count]) {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0]];
             }
             else if (2 == [objects count]) {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0] withObject:[objects objectAtIndex:1]];
             }
#pragma clang diagnostic pop
         }
     }];
    
    for (UIView *view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAKickoutView class]]) {
            [view removeFromSuperview];
        }
    }
    
    [window.rootViewController.view addSubview:self.kickoutView];
}

- (void)removeKickoutView {
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    for (UIView *view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAKickoutView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}

- (BOOL)isIpad {
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        return YES;
    }
    return NO;
}

- (BOOL)isIpadLandscape {
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        return YES;
    }
    return NO;
}

-(void)appWillEnterForeground {
    return;
}

-(void)appDidEnterBackground {
    return;
}

- (void)onOrientationChanged {
//    if (self.searchBarIsVisible) {
//        [self reloadSearchBar];
//    }
    self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
}


//TEMP FUNCTION
- (NSArray *)extractSuccessMessages:(id)dataMessages {
    NSMutableArray *messages = [NSMutableArray array];
    
    if ([dataMessages isKindOfClass:DataMessageList.class]) {
        for(DataMessage *msgObject in ((DataMessageList *)dataMessages).success) {
            [messages addObject:msgObject.message];
        }
    }
    

    if ([dataMessages isKindOfClass:ApiDataMessageList.class]) {
        for(ApiDataMessage *msgObject in ((ApiDataMessageList *)dataMessages).success) {
            [messages addObject:msgObject.message];
        }
    }
    
    return messages;
}

//##################################################################################################
#pragma mark - PerformanceTrackerProtocol
-(void) recordStartLoadTime {
    _startLoadingTime = [NSDate date];
}

- (void)publishScreenLoadTimeWithName:(NSString *)name withLabel:(NSString *)label {
    NSDate *publishTime = [NSDate date];
    NSTimeInterval publishInterVal = [publishTime timeIntervalSinceDate:_startLoadingTime];
    [TrackerManager trackLoadTimeWithScreenName:name interval:@((NSUInteger)(publishInterVal * 1000)) label:label];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getDataTrackerAlias {
    return nil;
}

- (NSString *)getScreenName {
    return nil;
}

#pragma mark - NavigationBarProtocol
- (void)searchIconButtonTapped {
    [[MainTabBarViewController topNavigationController] showSearchView: [self getScreenName]];
}

- (void)cartIconButtonTapped {
    [MainTabBarViewController showCart];
}

- (void)updateCartInNavBar {
    if (self.navBarleftButton == NavBarButtonTypeCart) {
        self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)[[RICart sharedInstance].cartEntity.cartCount integerValue]];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

@end
