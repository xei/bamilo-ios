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
#import "JAFallbackView.h"
#import "JASearchView.h"

@interface JABaseViewController ()

@property (assign, nonatomic) int requestNumber;
@property (strong, nonatomic) UIView *loadingView;
@property (nonatomic, strong) UIImageView *loadingAnimation;
@property (strong, nonatomic) JANoConnectionView *noConnectionView;
@property (strong, nonatomic) JAMessageView *messageView;
@property (strong, nonatomic) JAMaintenancePage *maintenancePage;
@property (nonatomic, strong) JASearchView* searchView;

@end

@implementation JABaseViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        JANavigationBarLayout* defaultLayout = [[JANavigationBarLayout alloc] init];
        self.navBarLayout = defaultLayout;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        JANavigationBarLayout* defaultLayout = [[JANavigationBarLayout alloc] init];
        self.navBarLayout = defaultLayout;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.firstLoading = YES;
    
    self.screenName = @"";
    
    self.startLoadingTime = [NSDate date];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.hidesBackButton = YES;
    self.title = @"";
    
    self.view.backgroundColor = JABackgroundGrey;
    
    self.requestNumber = 0;
    
    self.loadingView = [[UIImageView alloc] initWithFrame:((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame];
    self.loadingView.backgroundColor = [UIColor blackColor];
    self.loadingView.alpha = 0.0f;
    self.loadingView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(cancelLoading)];
    [self.loadingView addGestureRecognizer:tap];
    
    UIImage* image = [UIImage imageNamed:@"loadingAnimationFrame1"];
    
    int lastFrame = 24;
    if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"] || [[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
    {
        lastFrame = 6;
    }
    self.loadingAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          image.size.width,
                                                                          image.size.height)];
    self.loadingAnimation.animationDuration = 1.0f;
    NSMutableArray* animationFrames = [NSMutableArray new];
    for (int i = 1; i <= lastFrame; i++) {
        NSString* frameName = [NSString stringWithFormat:@"loadingAnimationFrame%d", i];
        UIImage* frame = [UIImage imageNamed:frameName];
        [animationFrames addObject:frame];
    }
    self.loadingAnimation.animationImages = [animationFrames copy];
    self.loadingAnimation.center = self.loadingView.center;
    
    self.loadingView.alpha = 0.0f;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self changeLoadingFrame:[[UIScreen mainScreen] bounds] orientation:toInterfaceOrientation];
    
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    if(VALID_NOTEMPTY(self.maintenancePage, JAMaintenancePage)){
        
        
        [self.maintenancePage setupMaintenancePage:CGRectMake(0.0f, 0.0f, window.frame.size.height, window.frame.size.width) orientation:toInterfaceOrientation];
    }
    
    if (VALID_NOTEMPTY(self.searchView, JASearchView)) {
        [self.searchView resetFrame:CGRectMake(0.0f,
                                               0.0f,
                                               window.frame.size.height,
                                               window.frame.size.width)
                        orientation:toInterfaceOrientation];
    }
}
- (void)changeLoadingFrame:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    CGFloat screenWidth = frame.size.width;
    CGFloat screenHeight = frame.size.height;
    
    if(UIInterfaceOrientationIsPortrait(orientation))
    {
        if(screenWidth > screenHeight)
        {
            self.loadingView.frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
        else
        {
            self.loadingView.frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
    }
    else
    {
        if(screenWidth > screenHeight)
        {
            self.loadingView.frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
        else
        {
            self.loadingView.frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
    }
    
    self.loadingAnimation.center = self.loadingView.center;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    CGRect viewFrame = self.view.frame;
    CGFloat screenWidth = viewFrame.size.width;
    CGFloat screenHeight = viewFrame.size.height;
    
    if(VALID_NOTEMPTY(self.noConnectionView, JANoConnectionView))
    {
        self.noConnectionView.frame = CGRectMake(self.noConnectionView.frame.origin.x,
                                                 self.noConnectionView.frame.origin.y,
                                                 screenWidth,
                                                 screenHeight);
        [self.view bringSubviewToFront:self.noConnectionView];
    }
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    if(VALID_NOTEMPTY(self.maintenancePage, JAMaintenancePage)){
        
        [self.maintenancePage setupMaintenancePage:CGRectMake(0.0f, 0.0f, window.frame.size.width, window.frame.size.height)orientation:self.interfaceOrientation];
    }
    if (VALID_NOTEMPTY(self.searchView, JASearchView)) {
        [self.searchView resetFrame:CGRectMake(0.0f,
                                               0.0f,
                                               window.frame.size.width,
                                               window.frame.size.height)
                        orientation:self.interfaceOrientation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadNavBar];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOnLeftSwipePanelNotification
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSearchView)
                                                 name:kDidPressSearchButtonNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDidPressSearchButtonNotification
                                                  object:nil];
}

- (NSUInteger)supportedInterfaceOrientations
{
    NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    }
    return supportedInterfaceOrientations;
}

- (void)reloadNavBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeNavigationBarNotification
                                                        object:self.navBarLayout];
}

- (void)showSearchView
{
    UIView* window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
    if (self.searchView) {
        [self.searchView removeFromSuperview];
    }
    self.searchView = [[JASearchView alloc] initWithFrame:window.bounds];
    [window addSubview:self.searchView];
}

- (void) showLoading
{
    self.requestNumber++;
    
    [self changeLoadingFrame:[[UIScreen mainScreen] bounds] orientation:self.interfaceOrientation];
    
    if(1 == self.requestNumber) {
        [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingView];
        [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingAnimation];
        
        [self.loadingAnimation startAnimating];
        
        [UIView animateWithDuration:0.4f
                         animations:^{
                             self.loadingView.alpha = 0.5f;
                             self.loadingAnimation.alpha = 0.5f;
                         }];
    }
}

- (void) hideLoading
{
    self.requestNumber--;
    if (self.requestNumber < 0) {
        self.requestNumber = 0;
    }
    if(0 == self.requestNumber) {
        [UIView animateWithDuration:0.4f
                         animations:^{
                             self.loadingView.alpha = 0.0f;
                             self.loadingAnimation.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             [self.loadingView removeFromSuperview];
                             [self.loadingAnimation removeFromSuperview];
                         }];
    }
}

- (void) cancelLoading
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelLoadingNotificationName
                                                        object:nil];
}

- (void)showMessage:(NSString*)message success:(BOOL)success
{
    UIViewController *rootViewController = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    if(!VALID_NOTEMPTY(self.messageView, JAMessageView))
    {
        self.messageView = [JAMessageView getNewJAMessageView];
        [self.messageView setupView];
    }
    
    if(!VALID_NOTEMPTY([self.messageView superview], UIView))
    {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        CGFloat width = rootViewController.view.frame.size.width;
        if(UIInterfaceOrientationIsLandscape(orientation))
        {
            if(width < rootViewController.view.frame.size.height)
            {
                width = rootViewController.view.frame.size.height;
            }
        }
        else
        {
            if(width > rootViewController.view.frame.size.height)
            {
                width = rootViewController.view.frame.size.height;
            }
        }
        
        [self.messageView setFrame:CGRectMake(self.messageView.frame.origin.x,
                                              self.messageView.frame.origin.y,
                                              width,
                                              self.messageView.frame.size.height)];
        [rootViewController.view addSubview:self.messageView];
    }
    
    [self.messageView setTitle:message success:success];
}

- (void)removeMessageView
{
    [self.messageView removeFromSuperview];
}

- (void)showErrorView:(BOOL)isNoInternetConnection startingY:(CGFloat)startingY selector:(SEL)selector objects:(NSArray*)objects
{
    if(VALID_NOTEMPTY(self.noConnectionView, JANoConnectionView))
    {
        [self.noConnectionView removeFromSuperview];
    }
    
    self.noConnectionView = [JANoConnectionView getNewJANoConnectionView];
    [self.noConnectionView setupNoConnectionViewForNoInternetConnection:isNoInternetConnection];
    self.noConnectionView.frame = CGRectMake(self.view.frame.origin.x,
                                             startingY,
                                             self.view.frame.size.width,
                                             self.view.frame.size.height);
    
    // This is to avoid a retain cycle
    __block JABaseViewController *viewController = self;
    [self.noConnectionView setRetryBlock:^(BOOL dismiss)
     {
         if([viewController respondsToSelector:selector])
         {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             if(ISEMPTY(objects))
             {
                 [viewController performSelector:selector];
             }
             else if(1 == [objects count])
             {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0]];
             }
             else if(2 == [objects count])
             {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0] withObject:[objects objectAtIndex:1]];
             }
#pragma clang diagnostic pop
         }
     }];
    
    [self.view addSubview:self.noConnectionView];
}

- (void)removeErrorView
{
    [self.noConnectionView removeFromSuperview];
}

- (void)showMaintenancePage:(SEL)selector objects:(NSArray*)objects
{
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    
    self.maintenancePage = [JAMaintenancePage getNewJAMaintenancePage];
    [self.maintenancePage setupMaintenancePage:window.frame orientation:self.interfaceOrientation];
    __block JABaseViewController *viewController = self;
    [self.maintenancePage setRetryBlock:^(BOOL dismiss)
     {
         if([viewController respondsToSelector:selector])
         {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             if(ISEMPTY(objects))
             {
                 [viewController performSelector:selector];
             }
             else if(1 == [objects count])
             {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0]];
             }
             else if(2 == [objects count])
             {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0] withObject:[objects objectAtIndex:1]];
             }
#pragma clang diagnostic pop
         }
     }];
    
    for (UIView* view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAMaintenancePage class]]) {
            [view removeFromSuperview];
        }
    }
    
    [window.rootViewController.view addSubview:self.maintenancePage];
}

- (void)removeMaintenancePage
{
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    for(UIView *view in window.rootViewController.view.subviews)
    {
        if([view isKindOfClass:[JAMaintenancePage class]])
        {
            [view removeFromSuperview];
            break;
        }
    }
}
@end
