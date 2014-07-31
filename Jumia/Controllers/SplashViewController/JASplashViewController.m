//
//  JASplashViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASplashViewController.h"
#import "JARootViewController.h"
#import "RIApi.h"
#import "JAAppDelegate.h"

@interface JASplashViewController ()

@end

@implementation JASplashViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showLoading];

    [RIApi startApiWithSuccessBlock:^(id api) {
        
        UIViewController* rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootViewController"];
        
        [[[UIApplication sharedApplication] delegate] window].rootViewController = rootViewController;
        
        [self hideLoading];
        
    } andFailureBlock:^(NSArray *errorMessage) {
        
        [self hideLoading];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
