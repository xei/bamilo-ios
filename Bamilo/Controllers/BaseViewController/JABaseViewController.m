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
#import "RICustomer.h"
#import "JAAuthenticationViewController.h"
#import "JACenterNavigationController.h"
#import "ViewControllerManager.h"
#import "NotificationBarView.h"
#import "EmarsysPredictManager.h"
#import "Bamilo-Swift.h"

#define kSearchViewBarHeight 44.0f


@interface JABaseViewController () {
    CGRect _noConnectionViewFrame;
    NSString* _searchBarText;
}

@property (assign, nonatomic) int requestNumber;
@property (strong, nonatomic) UIView *loadingView;
@property (nonatomic, strong) UIImageView *loadingAnimation;
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
    CGFloat bottomOffset = 0.0f;
    if (self.searchBarIsVisible) {
        topOffset += kSearchViewBarHeight;
    }
    return CGRectMake(self.view.bounds.origin.x,
                      self.view.bounds.origin.y + topOffset,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - topOffset - bottomOffset);
}

- (CGRect)bounds {
    CGFloat offset = 0.0f;
    CGFloat heightOffset = 0.0f;
    if (self.searchBarIsVisible) {
        offset = kSearchViewBarHeight;
    }
    if (self.navigationController.navigationBar) {
        heightOffset = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    }
    return CGRectMake(self.view.bounds.origin.x,
                      self.view.bounds.origin.y + offset,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - offset - heightOffset);
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        JANavigationBarLayout *defaultLayout = [[JANavigationBarLayout alloc] init];
        self.navBarLayout = defaultLayout;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        JANavigationBarLayout *defaultLayout = [[JANavigationBarLayout alloc] init];
        self.navBarLayout = defaultLayout;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        JANavigationBarLayout *defaultLayout = [[JANavigationBarLayout alloc] init];
        self.navBarLayout = defaultLayout;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //PerformanceTrackerProtocol
    [self recordStartLoadTime];
    
    self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.hidesBackButton = YES;
//    self.title = @"";
    
    self.view.backgroundColor = JABackgroundGrey;
    
    self.requestNumber = 0;
    
    self.loadingView = [[UIImageView alloc] initWithFrame:((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame];
    self.loadingView.backgroundColor = [UIColor blackColor];
    self.loadingView.alpha = 0.0f;
    self.loadingView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelLoading)];
    [self.loadingView addGestureRecognizer:tap];
    
    UIImage *image = [UIImage imageNamed:@"loadingAnimationFrame1"];
    
    int lastFrame = 8;
  
    self.loadingAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    self.loadingAnimation.animationDuration = 1.0f;
    NSMutableArray *animationFrames = [NSMutableArray new];
    for (int i = 1; i <= lastFrame; i++) {
        NSString *frameName = [NSString stringWithFormat:@"loadingAnimationFrame%d", i];
        UIImage *frame = [UIImage imageNamed:frameName];
        [animationFrames addObject:frame];
    }
    self.loadingAnimation.animationImages = [animationFrames copy];
    self.loadingAnimation.center = self.loadingView.center;
    
    self.loadingView.alpha = 0.0f;
    if ([self getScreenName].length) {
        [TrackerManager trackScreenNameWithScreenName:[self getScreenName]];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
    if ([[UIApplication sharedApplication] statusBarOrientation] != self.orientation) {
        [self onOrientationChanged];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC/2), dispatch_get_main_queue(), ^{
            [self setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        });
    }
}

- (void)changeLoadingFrame:(CGRect)frame orientation:(UIInterfaceOrientation)orientation {
    CGFloat screenWidth = frame.size.width;
    CGFloat screenHeight = frame.size.height;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        if (screenWidth > screenHeight) {
            self.loadingView.frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
        else {
            self.loadingView.frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
    }
    else {
        if (screenWidth > screenHeight) {
            self.loadingView.frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
        else {
            self.loadingView.frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
    }
    
    self.loadingAnimation.center = self.loadingView.center;
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
             self.noConnectionView.frame = CGRectMake(_noConnectionViewFrame.origin.x,
                                                      _noConnectionViewFrame.origin.y,
                                                      screenWidth,
                                                      screenHeight);
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
         if (self.searchBarIsVisible) {
             [self reloadSearchBar];
         }

     } completion: nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadNavBar];
//    [self reloadTabBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sideMenuIsOpening) name:kOpenMenuNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSearchView) name:kDidPressSearchButtonNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:kAppDidEnterBackground object:nil];
    
    if (self.searchBarIsVisible) {
        [self showSearchBar];
    }
    
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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppDidEnterBackground object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidPressSearchButtonNotification object:nil];
}

- (void)sideMenuIsOpening {
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    }
    return supportedInterfaceOrientations;
}

- (void)reloadNavBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeNavigationBarNotification
                                                        object:self.navBarLayout];
}

//- (void)reloadTabBar {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBarVisibility
//                                                        object:[NSNumber numberWithBool:self.tabBarIsVisible]];
//}

- (void)showSearchBar {
    self.searchBarBackground = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, kSearchViewBarHeight)];
    
    self.searchBarBackground.backgroundColor = JABlack300Color;
    [self.view addSubview:self.searchBarBackground];
    
    UIView* separatorView = [UIView new];
    [separatorView setBackgroundColor:JABlack400Color];
    [separatorView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [separatorView setFrame:CGRectMake(self.searchBarBackground.bounds.origin.x, self.searchBarBackground.bounds.size.height - 1.0f, self.searchBarBackground.bounds.size.width, 1.0f)];

    [self.searchBarBackground addSubview:separatorView];
    
    CGFloat horizontalMargin = 3.0f; //adjustment to native searchbar margin
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        horizontalMargin = 10.0f;
    }
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.searchBarBackground.bounds.origin.x + horizontalMargin, self.searchBarBackground.bounds.origin.y, self.searchBarBackground.bounds.size.width - horizontalMargin * 2, self.searchBarBackground.bounds.size.height - 1.0f)];
    
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = JABlack300Color;
    self.searchBar.placeholder = STRING_SEARCH_PLACEHOLDER;
    self.searchBar.showsCancelButton = NO;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor: [Theme color:kColorOrange]];
    
    UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
    textFieldSearch.font = [UIFont fontWithName:kFontRegularName size:textFieldSearch.font.pointSize];
    textFieldSearch.backgroundColor = JAWhiteColor;
    //remove magnifying lens
    [textFieldSearch setLeftViewMode:UITextFieldViewModeNever];
    
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [JABlack300Color CGColor];
    
    [self.searchBarBackground addSubview:self.searchBar];
    UIImage *searchIcon = [UIImage imageNamed:@"searchIcon"];
    
    self.searchIconImageView = [[UIImageView alloc] initWithImage:searchIcon];
    self.searchIconImageView.frame = CGRectMake(self.searchBar.frame.size.width - horizontalMargin - searchIcon.size.width,(self.searchBar.frame.size.height - searchIcon.size.height) / 2, searchIcon.size.width, searchIcon.size.height);
    
    [self.searchBar addSubview:self.searchIconImageView];
    
    [self reloadSearchBar];
}

- (void)setSearchBarText:(NSString*)text {
    _searchBarText = text;
}

- (void)reloadSearchBar {
    self.searchBarBackground.frame = CGRectMake(self.view.bounds.origin.x,
                                                self.view.bounds.origin.y,
                                                self.view.bounds.size.width,
                                                kSearchViewBarHeight);
    CGFloat horizontalMargin = 3.0f; //adjustment to native searchbar margin
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        horizontalMargin = 10.0f;
    }
    self.searchBar.frame = CGRectMake(self.searchBarBackground.bounds.origin.x + horizontalMargin,
                                      self.searchBarBackground.bounds.origin.y,
                                      self.searchBarBackground.bounds.size.width - horizontalMargin * 2,
                                      self.searchBarBackground.bounds.size.height - 1.0f);
    
    self.searchIconImageView.frame = CGRectMake(self.searchBar.frame.size.width - 12.0 - self.searchIconImageView.frame.size.width,
                                                (self.searchBar.frame.size.height - self.searchIconImageView.frame.size.height) / 2,
                                                self.searchIconImageView.frame.size.width,
                                                self.searchIconImageView.frame.size.height);
    
    UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
    textFieldSearch.textAlignment = NSTextAlignmentLeft;
    
    if(RI_IS_RTL){
        
        [textFieldSearch flipViewAlignment];
        [self.searchIconImageView flipViewPositionInsideSuperview];
        [self.searchBar setPositionAdjustment:UIOffsetMake(-self.searchBar.frame.size.width + 48.0f, 0) forSearchBarIcon:UISearchBarIconClear];
        [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(24.0f, 0)];
    }
}

#pragma mark Search Bar && Search Results View Delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"%@", searchBar.text);
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
{
    [[MainTabBarViewController topNavigationController] showSearchView];
    return NO;
}

# pragma mark - Loading View
- (void)showLoading {
    self.requestNumber++;
    
    [self changeLoadingFrame:[[UIScreen mainScreen] bounds] orientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if (1 == self.requestNumber) {
        [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingView];
        [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingAnimation];
        
        [self.loadingAnimation startAnimating];
        
        [UIView animateWithDuration:0.4f
                         animations: ^{
                             self.loadingView.alpha = 0.5f;
                             self.loadingAnimation.alpha = 0.5f;
                         }];
    }
}

- (void)hideLoading {
    self.requestNumber--;
    if (self.requestNumber < 0) {
        self.requestNumber = 0;
    }
    if (0 == self.requestNumber) {
        [UIView animateWithDuration:0.4f
                         animations: ^{
                             self.loadingView.alpha = 0.0f;
                             self.loadingAnimation.alpha = 0.0f;
                         } completion: ^(BOOL finished) {
                             [self.loadingView removeFromSuperview];
                             [self.loadingAnimation removeFromSuperview];
                         }];
    }
}

- (void)cancelLoading {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelLoadingNotificationName
                                                        object:nil];
}

# pragma mark Message View
- (void)showMessage:(NSString *)message success:(BOOL)success {
    UIViewController *rootViewController = [ViewControllerManager topViewController];
    
    [[NotificationBarView sharedInstance] show:rootViewController text:message isSuccess:success];
    
    /*
    UIViewController *rootViewController = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    if (!VALID_NOTEMPTY(self.messageView, JAMessageView)) {
        self.messageView = [[JAMessageView alloc] initWithFrame:CGRectMake(0, 64, self.bounds.size.width, kMessageViewHeight)];
        [self.messageView setupView];
    }else{
        [self.messageView setFrame:CGRectMake(0, 64, self.bounds.size.width, kMessageViewHeight)];
    }
    
    if (!VALID_NOTEMPTY([self.messageView superview], UIView)) {
        [rootViewController.view addSubview:self.messageView];
    }
    [self.messageView setTitle:message success:success];*/
    
}

- (void)removeMessageView {
    [[NotificationBarView sharedInstance] dismiss];

    /*[self.messageView removeFromSuperview];*/
    
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
        //        [self.noConnectionView removeFromSuperview];
        
    } else {
        self.noConnectionView = [JANoConnectionView getNewJANoConnectionViewWithFrame:self.viewBounds];
        
        // This is to avoid a retain cycle
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
    
    _noConnectionViewFrame = CGRectMake(0.0f,
                                        0.0f,
                                        [[UIScreen mainScreen] bounds].size.width,
                                        [[UIScreen mainScreen] bounds].size.height);
    
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
            }
            else if (1 == [objects count]) {
                ((void (*)(id, SEL, id))[viewController methodForSelector:selector])(viewController, selector, [objects objectAtIndex:0]);
            }
            else if (2 == [objects count]) {
                ((void (*)(id, SEL, id, id))[viewController methodForSelector:selector])(viewController, selector, [objects objectAtIndex:0], [objects objectAtIndex:1]);
            }
        }
    };
    if ([RICustomer checkIfUserIsLogged]) {
        [RICustomer autoLogin:^(BOOL success, NSDictionary *entities, NSString *loginMethod) {
            if (success) {
                block();
            } else {
                [RICustomer cleanCustomerFromDB];
                [(JACenterNavigationController *)self.navigationController performProtectedBlock:^(BOOL userHadSession) {
                    block();
                }];
            }
        }];
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
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
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
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
    if (self.searchBarIsVisible) {
        [self reloadSearchBar];
    }
    self.orientation = [[UIApplication sharedApplication] statusBarOrientation];
}


//TEMP FUNCTION
-(NSArray *) extractSuccessMessages:(id)dataMessages {
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

-(void) publishScreenLoadTime {
    if(_hasAppeared == NO) {
        NSTimeInterval executionTime = [[NSDate date] timeIntervalSinceDate:_startLoadingTime];
        NSString *screenName = [self getPerformanceTrackerScreenName];
        if(screenName) {
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:[NSNumber numberWithDouble:executionTime] reference:screenName label:[self getPerformanceTrackerLabel] ?: @""];
        }
        _hasAppeared = YES;
    }
}

-(NSString *)getPerformanceTrackerLabel {
    return nil;
}

- (NSString *)getPerformanceTrackerScreenName {
    return [self getScreenName];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getDataTrackerAlias {
    return nil;
}

- (NSString *)getScreenName {
    return nil;
}

@end
