//
//  JARootViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARootViewController.h"
#import "RIApi.h"

@interface JARootViewController ()

@end

@implementation JARootViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shouldResizeLeftPanel = YES;
    
    [RIApi startApiWithSuccessBlock:^(id api) {
        [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                    message:@"API started"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    } andFailureBlock:^(NSArray *errorMessage) {
        [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                   message:@"Error starting the API"
                                  delegate:nil
                         cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)awakeFromNib
{
    [self setLeftPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:@"homeViewController"]];
}

@end
