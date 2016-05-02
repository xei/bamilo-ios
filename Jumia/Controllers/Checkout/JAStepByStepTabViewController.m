//
//  JAStepByStepTabViewController.m
//  Jumia
//
//  Created by Jose Mota on 28/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAStepByStepTabViewController.h"
#import "JACheckoutButton.h"

#define kTabBarViewHeigh 50
#define kTabBarButtonWidth 80

@interface JAStepByStepTabViewController ()

@property (nonatomic, strong) UIView *tabBarView;
@property (nonatomic, strong) UIViewController *actualViewController;
@property (nonatomic) NSLock *animationLock;
@property (nonatomic, strong) NSMutableArray *viewControllersStackArray;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UIView *tabIndicatorView;

@end

@implementation JAStepByStepTabViewController

- (UIView *)tabBarView
{
    if (!VALID(_tabBarView, UIView)) {
        _tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kTabBarViewHeigh)];
        for (int i = 0; i < self.stepByStepModel.viewControllersArray.count; i++)
        {
            JACheckoutButton *button1 = [[JACheckoutButton alloc] initWithFrame:CGRectMake(i*kTabBarButtonWidth, 8, kTabBarButtonWidth, _tabBarView.height-16)];
            if (VALID([self.stepByStepModel getTitleForIndex:i], NSString)) {
                [button1 setTitle:[self.stepByStepModel getTitleForIndex:i] forState:UIControlStateNormal];
            }
            if (VALID([self.stepByStepModel getIconForIndex:i], UIImage)) {
                [button1 setImage:[self.stepByStepModel getIconForIndex:i]];
                [button1 setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
            }
            [button1 setTag:i];
            [button1 addTarget:self action:@selector(goToView:) forControlEvents:UIControlEventTouchUpInside];
            [_tabBarView addSubview:button1];
        }
        [_tabBarView setWidth:CGRectGetMaxX([[_tabBarView subviews] lastObject].frame)];
        [_tabBarView addSubview:self.tabIndicatorView];
        [_tabBarView setXCenterAligned];
        if (RI_IS_RTL) {
            [_tabBarView flipAllSubviews];
        }
    }
    return _tabBarView;
}

- (BOOL)stackIsEmpty
{
    return (self.viewControllersStackArray.count == 1);
}

- (void)setIndexInit:(NSInteger)indexInit
{
    _indexInit = indexInit;
    self.index = -1;
    self.viewControllersStackArray = [NSMutableArray new];
    if (self.actualViewController) {
        [self.actualViewController.view removeFromSuperview];
        self.actualViewController = nil;
    }
}

- (UIView *)tabIndicatorView
{
    if (!VALID(_tabIndicatorView, UIView)) {
        _tabIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tabBarView.height-2, kTabBarButtonWidth, 2)];
        [_tabIndicatorView setBackgroundColor:JAOrange1Color];
    }
    return _tabIndicatorView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewControllersStackArray = [NSMutableArray new];
    self.animationLock = [NSLock new];
    [self.view setBackgroundColor:JAWhiteColor];
    [self.view addSubview:self.tabBarView];
    self.index = -1;
    [self goToIndex:self.indexInit];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    for (UIViewController *viewController in self.viewControllersStackArray) {
        [viewController viewWillLayoutSubviews];
    }
    [self.tabBarView setXCenterAligned];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    for (UIViewController *viewController in self.viewControllersStackArray) {
        [viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    for (UIViewController *viewController in self.viewControllersStackArray) {
        [viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

- (void)goToView:(UIButton *)button
{
    if ([self.stepByStepModel ignoreStep:button.tag]) {
        return;
    }
    [self goToIndex:button.tag];
    [button setEnabled:NO];
    if (!self.stepByStepModel.freeToChoose) {
        for (UIView *oneView in [self.tabBarView subviews]) {
            if ([oneView isKindOfClass:[JACheckoutButton class]]) {
                [(JACheckoutButton *)oneView setEnabled:oneView.tag < button.tag];
            }
        }
    }
    [UIView animateWithDuration:.2 animations:^{
        [self.tabIndicatorView setX:[self getButtonWithTag:button.tag].x];
    }];
}

- (void)goToIndex:(NSInteger)index
{
    if (index == self.index) {
        return;
    }
    
    UIViewController *newViewController = [self getViewForIndex:index];
    if (VALID(newViewController, UIViewController)) {
        [self setViewController:newViewController forIndex:index];
    }
}

- (void)setViewController:(UIViewController *)newViewController forIndex:(NSInteger)index
{
    [newViewController viewWillAppear:YES];
    CGFloat offset = self.view.width;
    if (index < self.index) { // rolling left
        offset *= -1;
    }
    [newViewController.view setX:offset];
    [newViewController.view setY:self.tabBarView.height];
    newViewController.view.height = self.view.height - self.tabBarView.height;
    [self.view addSubview:newViewController.view];
    [UIView animateWithDuration:.2 animations:^{
        [newViewController.view setX:0.f];
    } completion:^(BOOL finished) {
        if (!self.actualViewController) {
            [self setContentView:newViewController];
            [self.actualViewController.view setNeedsDisplay];
        }
    }];
    
    if (self.actualViewController) {
        [self.actualViewController viewWillDisappear:YES];
        [UIView animateWithDuration:.4 animations:^{
            [self.actualViewController.view setX:-1*offset];
        } completion:^(BOOL finished) {
            [self.actualViewController.view removeFromSuperview];
            [self.actualViewController viewDidDisappear:YES];
            [self setContentView:newViewController];
        }];
    }
    self.index = index;
}

- (UIViewController *)getViewForIndex:(NSInteger)index
{
    UIViewController *viewControllerToReturn = nil;
    for (UIViewController *viewController in [self.viewControllersStackArray mutableCopy]) {
        if (viewController.view.tag == index) {
            viewControllerToReturn = viewController;
            [self.viewControllersStackArray removeObject:viewController];
        }
    }
    return viewControllerToReturn;
}

- (void)setContentView:(UIViewController *)viewController
{
    self.actualViewController = viewController;
    [self.viewControllersStackArray addObject:viewController];
    if (!self.stepByStepModel.freeToChoose) {
        for (UIViewController *oneViewController in [self.viewControllersStackArray mutableCopy]) {
            if (oneViewController.view.tag > viewController.view.tag) {
                [self.viewControllersStackArray removeObject:oneViewController];
            }
        }
    }
    
    if (!self.stepByStepModel.freeToChoose) {
        for (UIView *oneView in [self.tabBarView subviews]) {
            if ([oneView isKindOfClass:[JACheckoutButton class]]) {
                [(JACheckoutButton *)oneView setEnabled:oneView.tag < viewController.view.tag];
            }
        }
    }
    [UIView animateWithDuration:.2 animations:^{
        [self.tabIndicatorView setX:[self getButtonWithTag:viewController.view.tag].x];
    }];
    [viewController viewDidAppear:YES];
}

- (UIView *)getButtonWithTag:(NSInteger)tag
{
    for (UIView *oneView in [self.tabBarView subviews]) {
        if (oneView.tag == tag)
            return oneView;
    }
    return 0;
}

- (void)goToViewController:(UIViewController *)viewController
{
    NSInteger index = [self.stepByStepModel getIndexForViewController:viewController];
    [viewController.view setTag:index];
    [self setViewController:viewController forIndex:index];
}

- (void)sendBack
{
    [self.viewControllersStackArray removeObject:[self.viewControllersStackArray lastObject]];
    UIViewController *lastToReload = [self.viewControllersStackArray lastObject];
    [self.viewControllersStackArray removeObject:lastToReload];
    [self setViewController:lastToReload forIndex:self.viewControllersStackArray.count-1];
}

@end
