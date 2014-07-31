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

@property (nonatomic, assign)NSInteger requestCount;

@end

@implementation JASplashViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showLoading];
    
    self.requestCount = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementRequestCount) name:RISectionRequestStartedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementRequestCount) name:RISectionRequestEndedNotificationName object:nil];

    [RIApi startApiWithSuccessBlock:^(id api) {
        
        if (0 >= self.requestCount) {
            [self procedeToFirstAppScreen];
        }
        
    } andFailureBlock:^(NSArray *errorMessage) {
        
        [self hideLoading];
        
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)incrementRequestCount
{
    self.requestCount++;
}

- (void)decrementRequestCount
{
    self.requestCount--;
    
    if (0 >= self.requestCount) {
        [self procedeToFirstAppScreen];
    }
}

- (void)procedeToFirstAppScreen
{
    UIViewController* rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootViewController"];
    
    [[[UIApplication sharedApplication] delegate] window].rootViewController = rootViewController;
    
    [self hideLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
