//
//  JABaseViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAAppDelegate.h"

@interface JABaseViewController ()

@property (assign, nonatomic) int requestNumber;
@property (strong, nonatomic) UIView *loadingView;
@property (nonatomic, strong) UIImageView *loadingAnimation;

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadNavBar];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOnLeftSwipePanelNotification
                                                        object:nil];
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

@end
