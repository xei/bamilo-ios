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
@property (strong, nonatomic) UIImageView *loadingImageView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingSpinner;

@end

@implementation JABaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOnLeftSwipePanelNotification object:nil];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationItem.hidesBackButton = YES;
    self.title = @"";
    
    self.view.backgroundColor = JABackgroundGrey;
    
    self.requestNumber = 0;
    
    self.loadingImageView = [[UIImageView alloc] initWithFrame:((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame];
    self.loadingImageView.backgroundColor = [UIColor blackColor];
    self.loadingImageView.alpha = 0.0f;
    self.loadingImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(cancelLoading)];
    [self.loadingImageView addGestureRecognizer:tap];
    
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingSpinner.center = self.loadingImageView.center;
    self.loadingImageView.alpha = 0.0f;
}

- (void) showLoading
{
    self.requestNumber++;
    
    if(1 == self.requestNumber) {
        [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingImageView];
        [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingSpinner];
        
        [self.loadingSpinner startAnimating];
        
        [UIView animateWithDuration:0.4f
                         animations:^{
                             self.loadingImageView.alpha = 0.6f;
                             self.loadingSpinner.alpha = 0.6f;
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
                             self.loadingImageView.alpha = 0.0f;
                             self.loadingSpinner.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             [self.loadingImageView removeFromSuperview];
                             [self.loadingSpinner removeFromSuperview];
                         }];
    }
}

- (void) cancelLoading
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelLoadingNotificationName
                                                        object:nil];
}

@end
