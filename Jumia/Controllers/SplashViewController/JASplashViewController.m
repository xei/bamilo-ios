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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [RIApi startApiWithSuccessBlock:^(id api) {
        
        UIViewController* rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootViewController"];
        
        [[[UIApplication sharedApplication] delegate] window].rootViewController = rootViewController;
        
    } andFailureBlock:^(NSArray *errorMessage) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
