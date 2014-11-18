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

@interface JABaseViewController ()

@property (assign, nonatomic) int requestNumber;
@property (strong, nonatomic) UIView *loadingView;
@property (nonatomic, strong) UIImageView *loadingAnimation;
@property (strong, nonatomic) JANoConnectionView *noConnectionView;

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
    self.loadingAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          image.size.width,
                                                                          image.size.height)];
    self.loadingAnimation.animationDuration = 1.0f;
    NSMutableArray* animationFrames = [NSMutableArray new];
    for (int i = 1; i <= 24; i++) {
        NSString* frameName = [NSString stringWithFormat:@"loadingAnimationFrame%d", i];
        UIImage* frame = [UIImage imageNamed:frameName];
        [animationFrames addObject:frame];
    }
    self.loadingAnimation.animationImages = [animationFrames copy];
    self.loadingAnimation.center = self.loadingView.center;
    
    self.loadingView.alpha = 0.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLoadingFrame:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)changeLoadingFrame:(NSNotification *)notification
{
    CGSize size = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame.size;
    CGFloat screenWidth = size.width;
    CGFloat screenHeight = size.height;
    
    if(VALID_NOTEMPTY(notification, NSNotification))
    {
        UIDevice *device = notification.object;
        
        // if the orientation is in portrati means that the device was just rotate to landscape.
        if(UIInterfaceOrientationIsPortrait(device.orientation))
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
        self.noConnectionView.frame =  CGRectMake(0, 0, screenWidth, screenHeight);
        [self.view bringSubviewToFront:self.noConnectionView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadNavBar];
    
    CGSize size = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame.size;
    CGFloat screenWidth = size.width;
    CGFloat screenHeight = size.height;
    
    if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation))
    {
        self.loadingView.frame  = CGRectMake(0, 0, screenWidth, screenHeight);
    }
    else
    {
        self.loadingView.frame  = CGRectMake(0, 0, screenHeight, screenWidth);
    }
    
    self.loadingAnimation.center = self.loadingView.center;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOnLeftSwipePanelNotification
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

- (void) showLoading
{
    self.requestNumber++;
    
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
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    
    JAMessageView *messageView = [JAMessageView getNewJAMessageView];
    [messageView setTitle:message success:success addTo:window.rootViewController];
}

- (void)removeMessageView
{
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    if(VALID_NOTEMPTY(window.rootViewController, UIViewController) && VALID_NOTEMPTY(window.rootViewController.view, UIView))
    {
        for(UIView *view in window.rootViewController.view.subviews)
        {
            if([view isKindOfClass:[JAMessageView class]])
            {
                [view removeFromSuperview];
                break;
            }
        }
    }
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
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[JANoConnectionView class]])
        {
            [view removeFromSuperview];
            break;
        }
    }
}

- (void)showMaintenancePage:(SEL)selector objects:(NSArray*)objects
{
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    
    JAMaintenancePage *maintenancePage = [JAMaintenancePage getNewJAMaintenancePage];
    [maintenancePage setupMaintenancePage:window.frame];
    [maintenancePage setRetryBlock:^(BOOL dismiss)
     {
         if([self respondsToSelector:selector])
         {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             if(ISEMPTY(objects))
             {
                 [self performSelector:selector];
             }
             else if(1 == [objects count])
             {
                 [self performSelector:selector withObject:[objects objectAtIndex:0]];
             }
             else if(2 == [objects count])
             {
                 [self performSelector:selector withObject:[objects objectAtIndex:0] withObject:[objects objectAtIndex:1]];
             }
#pragma clang diagnostic pop
         }
     }];
    
    for (UIView* view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAMaintenancePage class]]) {
            [view removeFromSuperview];
        }
    }
    
    [window.rootViewController.view addSubview:maintenancePage];
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
