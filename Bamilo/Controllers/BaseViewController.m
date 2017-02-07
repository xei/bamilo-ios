//
//  BaseViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.hidesBackButton = YES;
    self.title = nil;
    
    self.view.backgroundColor = JABackgroundGrey;
    
    self.navBarLayout = [[JANavigationBarLayout alloc] init];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateNavBar];
    
    [self requestNavigationBarReload];
    [self requestTabBarReload];
    
    if([self getIsSideMenuAvailable]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOnMenuSwipePanelNotification object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:kAppDidEnterBackground object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTurnOnMenuSwipePanelNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppDidEnterBackground object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Private Methods
-(void)requestNavigationBarReload {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeNavigationBarNotification object:self.navBarLayout];
}

-(void)requestTabBarReload {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBarVisibility object:[NSNumber numberWithBool:[self getTabBarVisible]]];
}

#pragma mark - Public Methods
-(void)updateNavBar {
    return;
}

#pragma mark - SideMenuProtocol
-(BOOL)getIsSideMenuAvailable {
    return YES;
}

#pragma mark - TabBarProtocol
-(BOOL)getTabBarVisible {
    return NO;
}

@end
