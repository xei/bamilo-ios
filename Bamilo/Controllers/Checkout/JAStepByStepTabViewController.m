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
@property (nonatomic, strong) NSMutableArray *viewControllersStackArray;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) UIView *tabIndicatorView;
@property (nonatomic) BOOL freeToMove;

@end

@implementation JAStepByStepTabViewController

- (UIView *)tabBarView {
    if (!VALID(_tabBarView, UIView)) {
        _tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kTabBarViewHeigh)];
        [self addTabs];
    }
    return _tabBarView;
}

- (BOOL)stackIsEmpty
{
    return (self.viewControllersStackArray.count == 1);
}

- (void)setIndexInit:(NSInteger)indexInit {
    _indexInit = indexInit;
    self.index = -1;
    self.freeToMove = NO;
    self.viewControllersStackArray = [NSMutableArray new];
    if (self.actualViewController) {
        [self.actualViewController.view removeFromSuperview];
        self.actualViewController = nil;
    }
}

- (UIView *)tabIndicatorView {
    if (!VALID(_tabIndicatorView, UIView)) {
        _tabIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tabBarView.height-2, kTabBarButtonWidth, 2)];
        [_tabIndicatorView setBackgroundColor:JAOrange1Color];
    }
    return _tabIndicatorView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewControllersStackArray = [NSMutableArray new];
    [self.view setBackgroundColor:JAWhiteColor];
    [self.view addSubview:self.tabBarView];
    self.index = -1;
//    [self goToIndex:self.indexInit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCountry:)
                                                 name:kUpdateCountryNotification
                                               object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.actualViewController viewWillLayoutSubviews];
    [self.tabBarView setXCenterAligned];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.actualViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.actualViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)goToView:(UIButton *)button {
    if ([self.stepByStepModel ignoreStep:button.tag]) {
        return;
    }
    [self goToIndex:button.tag];
}

- (void)goToIndex:(NSInteger)index {
    if (index == self.index) {
        return;
    }
    
    UIViewController *newViewController = [self getViewForIndex:index];
    if (VALID(newViewController, UIViewController)) {
        [UIView animateWithDuration:.2 animations:^{
            [self.tabIndicatorView setX:[self getButtonWithTag:index].x];
        }];
        [self setViewController:newViewController forIndex:index];
    }
}

- (void)onOrientationChanged {
    [super onOrientationChanged];
    self.actualViewController.view.height = self.view.height - self.tabBarView.height;
    self.actualViewController.view.width = self.view.width;
    [(JABaseViewController *)self.actualViewController onOrientationChanged];
}

- (void)setViewController:(UIViewController *)newViewController forIndex:(NSInteger)index {
    [self showLoading];
    CGFloat offset = self.view.width;
    if (index < self.index) { // rolling left
        offset *= -1;
    }
    
    UIViewController *oldViewController = self.actualViewController;
    
    [newViewController.view setX:offset];
    [newViewController.view setY:self.tabBarView.height];
    newViewController.view.height = self.view.height - self.tabBarView.height;
    newViewController.view.width = self.view.width;
    [newViewController viewWillAppear:YES];
    [self.view addSubview:newViewController.view];
    [newViewController.view.layer removeAllAnimations];
    [UIView animateWithDuration:.2 animations:^{
        [newViewController.view setX:0.f];
    } completion:^(BOOL finished) {
        if (!oldViewController) {
            [self setContentView:newViewController];
        }
    }];

    if (oldViewController) {
        [oldViewController.view.layer removeAllAnimations];
        [oldViewController viewWillDisappear:YES];
        [UIView animateWithDuration:.4 animations:^{
            [oldViewController.view setX:-1*offset];
        } completion:^(BOOL finished) {
            [oldViewController.view removeFromSuperview];
            [oldViewController viewDidDisappear:YES];
            [self setContentView:newViewController];
        }];
    }
    
    self.index = index;
}

- (void)setContentView:(UIViewController *)viewController {
    [self.viewControllersStackArray addObject:viewController];
    if (!self.freeToMove) {
        for (UIViewController *oneViewController in [self.viewControllersStackArray mutableCopy]) {
            if (oneViewController.view.tag > viewController.view.tag || (oneViewController.view.tag != viewController.view.tag && [self.stepByStepModel ignoreStep:oneViewController.view.tag])) {
                [self.viewControllersStackArray removeObject:oneViewController];
            }
        }
    }
    if([self.stepByStepModel isFreeToChoose:viewController]) {
        self.freeToMove = YES;
    }
    
    for (UIView *oneView in [self.tabBarView subviews]) {
        if ([oneView isKindOfClass:[JACheckoutButton class]]) {
            if (!self.freeToMove) {
                [(JACheckoutButton *)oneView setEnabled:oneView.tag < viewController.view.tag];
            }else{
                [(JACheckoutButton *)oneView setEnabled:YES];
            }
            if ([self.stepByStepModel ignoreStep:oneView.tag]) {
                [(JACheckoutButton *)oneView setEnabled:NO];
            }
        }
    }
    [UIView animateWithDuration:.2 animations:^{
        [self.tabIndicatorView setX:[self getButtonWithTag:viewController.view.tag].x];
    }];
    // no need to trigger this! it's automatically triggered
//    [viewController viewDidAppear:YES];
    
    self.actualViewController = viewController;
//    if ([viewController isKindOfClass:[JABaseViewController class]]) {
//        [self setNavBarLayout:[(JABaseViewController *)viewController navBarLayout]];
//    }
    [self hideLoading];
}

- (UIViewController *)getViewForIndex:(NSInteger)index {
    UIViewController *viewControllerToReturn = nil;
    for (UIViewController *viewController in [self.viewControllersStackArray mutableCopy]) {
        if (viewController.view.tag == index) {
            viewControllerToReturn = viewController;
            [self.viewControllersStackArray removeObject:viewController];
        }
    }
    if (!VALID_NOTEMPTY(viewControllerToReturn, UIViewController)) {
        [self.stepByStepModel goToIndex:index];
    }
    return viewControllerToReturn;
}

- (UIView *)getButtonWithTag:(NSInteger)tag {
    for (UIView *oneView in [self.tabBarView subviews]) {
        if (oneView.tag == tag)
            return oneView;
    }
    return 0;
}

- (void)goToViewController:(UIViewController *)viewController {
    NSInteger index = [self.stepByStepModel getIndexForViewController:viewController];
    [viewController.view setTag:index];
    if ([self.stepByStepModel isClassBase:viewController]) {
        for (UIViewController *viewControllerFromStack in [self.viewControllersStackArray mutableCopy]) {
            if (index == viewControllerFromStack.view.tag) {
                [self.viewControllersStackArray removeObject:viewControllerFromStack];
                [self setViewController:viewController forIndex:viewControllerFromStack.view.tag];
                return;
            }
        }
    }
    for (UIViewController *viewControllerFromStack in [self.viewControllersStackArray mutableCopy]) {
        if ([viewController class] == [viewControllerFromStack class]) {
            if (self.actualViewController != viewControllerFromStack) {
                [self.viewControllersStackArray removeObject:viewControllerFromStack];
                [self setViewController:viewControllerFromStack forIndex:viewControllerFromStack.view.tag];
            }
            return;
        }
    }
    [self setViewController:viewController forIndex:index];
}

- (BOOL)sendBack {
    [self.viewControllersStackArray removeObject:[self.viewControllersStackArray lastObject]];
    UIViewController *lastToReload = [self.viewControllersStackArray lastObject];
    if (VALID_NOTEMPTY(lastToReload, UIViewController)) {
        [self.viewControllersStackArray removeObject:lastToReload];
        [self setViewController:lastToReload forIndex:self.viewControllersStackArray.count-1];
        return YES;
    }
    return NO;
}

- (void)updateCountry:(NSNotification *)notification {
    [[self.tabBarView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addTabs];
}

- (void)addTabs {
    for (int i = 0; i < self.stepByStepModel.viewControllersArray.count; i++) {
        JACheckoutButton *button1 = [[JACheckoutButton alloc] initWithFrame:CGRectMake(i*kTabBarButtonWidth, 8, kTabBarButtonWidth, _tabBarView.height-10)];
        if (VALID([self.stepByStepModel getTitleForIndex:i], NSString)) {
            [button1 setTitle:[self.stepByStepModel getTitleForIndex:i] forState:UIControlStateNormal];
        }
        if (VALID([self.stepByStepModel getIconForIndex:i], UIImage)) {
            [button1 setImage:[self.stepByStepModel getIconForIndex:i]];
            [button1 setTintColor:JABlackColor];
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

@end
