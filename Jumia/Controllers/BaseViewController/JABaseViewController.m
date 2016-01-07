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
#import "JAKickoutView.h"
#import "JAFallbackView.h"
#import "JASearchResultsView.h"
#import "JASearchView.h"

#define kSearchViewBarHeight 32.0f

@interface JABaseViewController () {
    CGRect _noConnectionViewFrame;
    NSString* _searchBarText;
    BOOL rotation;
}

@property (assign, nonatomic) int requestNumber;
@property (strong, nonatomic) UIView *loadingView;
@property (nonatomic, strong) UIImageView *loadingAnimation;
@property (strong, nonatomic) JANoConnectionView *noConnectionView;
@property (strong, nonatomic) JAMessageView *messageView;
@property (strong, nonatomic) JAMaintenancePage *maintenancePage;
@property (strong, nonatomic) JAKickoutView *kickoutView;
@property (nonatomic, strong) UIView *searchBarBackground;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIImageView *searchIconImageView;
@property (nonatomic, strong) JASearchResultsView *searchResultsView;
@property (nonatomic, strong) JASearchView *searchView;
@property (nonatomic, strong) UIButton *searchBarBackButton;

@end

@implementation JABaseViewController

- (CGRect)viewBounds {
    CGFloat topOffset = 0.0f;
    CGFloat bottomOffset = 0.0f;
    if (self.searchBarIsVisible) {
        topOffset += kSearchViewBarHeight;
    }
    if (self.tabBarIsVisible) {
        bottomOffset += kTabBarHeight;
    }
    return CGRectMake(self.view.bounds.origin.x,
                      self.view.bounds.origin.y + topOffset,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - topOffset - bottomOffset);
}

- (CGRect)bounds {
    CGFloat offset = 0.0f;
    CGFloat heightOffset = 0.0f;
    if (self.searchBarIsVisible) {
        offset = kSearchViewBarHeight;
    }
    if (self.navigationController.navigationBar) {
        heightOffset = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    }
    return CGRectMake(self.view.bounds.origin.x,
                      self.view.bounds.origin.y + offset,
                      self.view.bounds.size.width,
                      self.view.bounds.size.height - offset - heightOffset);
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        JANavigationBarLayout *defaultLayout = [[JANavigationBarLayout alloc] init];
        self.navBarLayout = defaultLayout;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        JANavigationBarLayout *defaultLayout = [[JANavigationBarLayout alloc] init];
        self.navBarLayout = defaultLayout;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        JANavigationBarLayout *defaultLayout = [[JANavigationBarLayout alloc] init];
        self.navBarLayout = defaultLayout;
    }
    return self;
}

- (void)viewDidLoad {
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
    
    UIImage *image = [UIImage imageNamed:@"loadingAnimationFrame1"];
    
    int lastFrame = 24;
    if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"] || [[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"]) {
        lastFrame = 6;
    }else if([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
    {
        lastFrame = 8;
    }
    self.loadingAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          image.size.width,
                                                                          image.size.height)];
    self.loadingAnimation.animationDuration = 1.0f;
    NSMutableArray *animationFrames = [NSMutableArray new];
    for (int i = 1; i <= lastFrame; i++) {
        NSString *frameName = [NSString stringWithFormat:@"loadingAnimationFrame%d", i];
        UIImage *frame = [UIImage imageNamed:frameName];
        [animationFrames addObject:frame];
    }
    self.loadingAnimation.animationImages = [animationFrames copy];
    self.loadingAnimation.center = self.loadingView.center;
    
    self.loadingView.alpha = 0.0f;
    
}

- (void)appWillEnterForeground
{
}

- (void)appDidEnterBackground
{
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    rotation = YES;
    [self changeLoadingFrame:[[UIScreen mainScreen] bounds] orientation:toInterfaceOrientation];
    
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    if (VALID_NOTEMPTY(self.maintenancePage, JAMaintenancePage)) {
        [self.maintenancePage setupMaintenancePage:CGRectMake(0.0f, 0.0f, window.frame.size.height, window.frame.size.width) orientation:toInterfaceOrientation];
    }
    
    if (VALID_NOTEMPTY(self.kickoutView, JAKickoutView)) {
        [self.kickoutView setupKickoutView:CGRectMake(0.0f, 0.0f, window.frame.size.height, window.frame.size.width) orientation:toInterfaceOrientation];
    }
    
    if (VALID_NOTEMPTY(self.searchView, JASearchView)) {
        [self.searchView removeFromSuperview];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (rotation) {
        [self onOrientationChanged];
    }
    rotation = NO;
}

- (void)onOrientationChanged
{
    
}

- (void)changeLoadingFrame:(CGRect)frame orientation:(UIInterfaceOrientation)orientation {
    CGFloat screenWidth = frame.size.width;
    CGFloat screenHeight = frame.size.height;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        if (screenWidth > screenHeight) {
            self.loadingView.frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
        else {
            self.loadingView.frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
    }
    else {
        if (screenWidth > screenHeight) {
            self.loadingView.frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
        else {
            self.loadingView.frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
    }
    
    self.loadingAnimation.center = self.loadingView.center;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    CGRect viewFrame = self.view.frame;
    CGFloat screenWidth = viewFrame.size.width;
    CGFloat screenHeight = viewFrame.size.height;
    
    if (VALID_NOTEMPTY(self.noConnectionView, JANoConnectionView)) {
        
        self.noConnectionView.frame = CGRectMake(_noConnectionViewFrame.origin.x,
                                                 _noConnectionViewFrame.origin.y,
                                                 screenWidth,
                                                 screenHeight);
        [self.noConnectionView reDraw];
        [self.view bringSubviewToFront:self.noConnectionView];
    }
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    if (VALID_NOTEMPTY(self.maintenancePage, JAMaintenancePage)) {
        [self.maintenancePage setupMaintenancePage:CGRectMake(0.0f, 0.0f, window.frame.size.width, window.frame.size.height) orientation:self.interfaceOrientation];
    }
    if (VALID_NOTEMPTY(self.kickoutView, JAKickoutView)) {
        [self.kickoutView setupKickoutView:CGRectMake(0.0f, 0.0f, window.frame.size.width, window.frame.size.height) orientation:self.interfaceOrientation];
    }
    if (self.searchBarIsVisible) {
        [self reloadSearchBar];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadNavBar];
    [self reloadTabBar];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOnMenuSwipePanelNotification
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sideMenuIsOpening)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSearchView)
                                                 name:kDidPressSearchButtonNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:kAppDidEnterBackground object:nil];
    
    if (self.searchBarIsVisible) {
        [self showSearchBar];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppWillEnterForeground object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAppDidEnterBackground object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidPressSearchButtonNotification object:nil];
}

- (void)sideMenuIsOpening {
    [self.searchResultsView popSearchResults];
}

- (NSUInteger)supportedInterfaceOrientations {
    NSUInteger supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    }
    return supportedInterfaceOrientations;
}

- (void)reloadNavBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeNavigationBarNotification
                                                        object:self.navBarLayout];
}

- (void)reloadTabBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBarVisibility
                                                        object:[NSNumber numberWithBool:self.tabBarIsVisible]];
}

#pragma mark - Search Bar

- (void)showSearchView
{
    UIView* window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view;
    if (self.searchView) {
        [self.searchView removeFromSuperview];
    }
    if (NO == self.searchViewAlwaysHidden) {
        self.searchView = [[JASearchView alloc] initWithFrame:window.bounds];
        [window addSubview:self.searchView];
    }
    if (VALID_NOTEMPTY(_searchBarText, NSString)) {
        [self.searchView setSearchBarText:_searchBarText];
    }
}

- (void)showSearchBar {
    self.searchBarBackground = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                        self.view.bounds.origin.y,
                                                                        self.view.bounds.size.width,
                                                                        kSearchViewBarHeight)];
    self.searchBarBackground.backgroundColor = JANavBarBackgroundGrey;
    [self.view addSubview:self.searchBarBackground];
    
    CGFloat horizontalMargin = 12.0f; //value by design
    CGFloat verticalMargin = 3.0f; //value by design
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(self.searchBarBackground.bounds.origin.x + horizontalMargin,
                                                                   self.searchBarBackground.bounds.origin.y + verticalMargin,
                                                                   self.searchBarBackground.bounds.size.width - horizontalMargin * 2,
                                                                   self.searchBarBackground.bounds.size.height - verticalMargin * 2)];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = JANavBarBackgroundGrey;
    self.searchBar.placeholder = STRING_SEARCH_PLACEHOLDER;
    self.searchBar.showsCancelButton = NO;

    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTintColor:[UIColor orangeColor]];
    
    UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
    textFieldSearch.font = [UIFont fontWithName:kFontRegularName size:textFieldSearch.font.pointSize];
    textFieldSearch.backgroundColor = [UIColor colorWithRed:242.0 / 255.0 green:242.0 / 255.0 blue:242.0 / 255.0 alpha:1.0f];
    //remove magnifying lens
    [textFieldSearch setLeftViewMode:UITextFieldViewModeNever];
    
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [JANavBarBackgroundGrey CGColor];
    
    [self.searchBarBackground addSubview:self.searchBar];
    UIImage *searchIcon = [UIImage imageNamed:@"searchIcon"];
    
    self.searchIconImageView = [[UIImageView alloc] initWithImage:searchIcon];
    self.searchIconImageView.frame = CGRectMake(self.searchBar.frame.size.width - horizontalMargin - searchIcon.size.width,
                                                (self.searchBar.frame.size.height - searchIcon.size.height) / 2,
                                                searchIcon.size.width,
                                                searchIcon.size.height);
    
    [self.searchBar addSubview:self.searchIconImageView];
    
    [self reloadSearchBar];
}

- (void)setSearchBarText:(NSString*)text {
    _searchBarText = text;
}

- (void)reloadSearchBar {
    self.searchBarBackground.frame = CGRectMake(self.view.bounds.origin.x,
                                                self.view.bounds.origin.y,
                                                self.view.bounds.size.width,
                                                kSearchViewBarHeight);
    CGFloat horizontalMargin = 12.0f; //value by design
    CGFloat verticalMargin = 2.0f; //value by design
    self.searchBar.frame = CGRectMake(self.searchBarBackground.bounds.origin.x + horizontalMargin,
                                      self.searchBarBackground.bounds.origin.y + verticalMargin,
                                      self.searchBarBackground.bounds.size.width - horizontalMargin * 2,
                                      self.searchBarBackground.bounds.size.height - verticalMargin * 2);
    
    self.searchIconImageView.frame = CGRectMake(self.searchBar.frame.size.width - horizontalMargin - self.searchIconImageView.frame.size.width,
                                                (self.searchBar.frame.size.height - self.searchIconImageView.frame.size.height) / 2,
                                                self.searchIconImageView.frame.size.width,
                                                self.searchIconImageView.frame.size.height);
    
    UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
    textFieldSearch.textAlignment = NSTextAlignmentLeft;
    
    if(RI_IS_RTL){
        
        [textFieldSearch flipViewAlignment];
        [self.searchIconImageView flipViewPositionInsideSuperview];
        [self.searchBar setPositionAdjustment:UIOffsetMake(-self.searchBar.frame.size.width + 48.0f, 0) forSearchBarIcon:UISearchBarIconClear];
        [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(24.0f, 0)];
    }
    
    [self.searchResultsView reloadFrame:CGRectMake([self viewBounds].origin.x,
                                                   [self viewBounds].origin.y,
                                                   [self viewBounds].size.width,
                                                   [self viewBounds].size.height - kTabBarHeight)];
}

#pragma mark Search Bar && Search Results View Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchResultsView searchFor:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchResultsView.searchText = searchText;
    if (0 < searchText.length) {
        self.searchIconImageView.hidden = YES;
    }
    else {
        self.searchIconImageView.hidden = NO;
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
{
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    self.searchBarBackButton = [[UIButton alloc] initWithFrame:CGRectMake(window.bounds.origin.x,
                                                                          window.bounds.origin.y + 20.0f,
                                                                          80.0f,
                                                                          44.0f)];
    [self.searchBarBackButton setImageEdgeInsets:UIEdgeInsetsMake(0.0f,
                                                                  10.0f,
                                                                  0.0f,
                                                                  0.0f)];
    self.searchBarBackButton.backgroundColor = JANavBarBackgroundGrey;
    [self.searchBarBackButton setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [self.searchBarBackButton setImage:[UIImage imageNamed:@"btn_back_pressed"] forState:UIControlStateHighlighted];
    [self.searchBarBackButton setImage:[UIImage imageNamed:@"btn_back_pressed"] forState:UIControlStateSelected];
    self.searchBarBackButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [window addSubview:self.searchBarBackButton];
    if (RI_IS_RTL) {
        [self.searchBarBackButton flipViewPositionInsideSuperview];
        [self.searchBarBackButton flipViewImage];
        [self.searchBarBackButton flipViewAlignment];
    }
    
    self.searchResultsView = [[JASearchResultsView alloc] initWithFrame:CGRectMake([self viewBounds].origin.x,
                                                                                   [self viewBounds].origin.y,
                                                                                   [self viewBounds].size.width,
                                                                                   [self viewBounds].size.height + kTabBarHeight)];
    self.searchResultsView.delegate = self;
    [self.view addSubview:self.searchResultsView];
    [self.searchResultsView setSearchText:@""];

    [self.searchBarBackButton addTarget:self.searchResultsView action:@selector(popSearchResults) forControlEvents:UIControlEventTouchUpInside];
    
    return YES;
}

- (void)searchResultsViewWillPop {
    [self.searchBarBackButton removeFromSuperview];
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.searchIconImageView.hidden = NO;
    //    //remove results
    //    [self.searchBar performSelector: @selector(resignFirstResponder)
    //                         withObject: nil
    //                         afterDelay: 0.1];
}

# pragma mark Loading View

- (void)showLoading {
    self.requestNumber++;
    
    [self changeLoadingFrame:[[UIScreen mainScreen] bounds] orientation:self.interfaceOrientation];
    
    if (1 == self.requestNumber) {
        [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingView];
        [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingAnimation];
        
        [self.loadingAnimation startAnimating];
        
        [UIView animateWithDuration:0.4f
                         animations: ^{
                             self.loadingView.alpha = 0.5f;
                             self.loadingAnimation.alpha = 0.5f;
                         }];
    }
}

- (void)hideLoading {
    self.requestNumber--;
    if (self.requestNumber < 0) {
        self.requestNumber = 0;
    }
    if (0 == self.requestNumber) {
        [UIView animateWithDuration:0.4f
                         animations: ^{
                             self.loadingView.alpha = 0.0f;
                             self.loadingAnimation.alpha = 0.0f;
                         } completion: ^(BOOL finished) {
                             [self.loadingView removeFromSuperview];
                             [self.loadingAnimation removeFromSuperview];
                         }];
    }
}

- (void)cancelLoading {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCancelLoadingNotificationName
                                                        object:nil];
}

# pragma mark Message View

- (void)showMessage:(NSString *)message success:(BOOL)success {
    UIViewController *rootViewController = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
    
    if (!VALID_NOTEMPTY(self.messageView, JAMessageView)) {
        self.messageView = [JAMessageView getNewJAMessageView];
        [self.messageView setupView];
    }
    
    if (!VALID_NOTEMPTY([self.messageView superview], UIView)) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        CGFloat width = rootViewController.view.frame.size.width;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            if (width < rootViewController.view.frame.size.height) {
                width = rootViewController.view.frame.size.height;
            }
        }
        else {
            if (width > rootViewController.view.frame.size.height) {
                width = rootViewController.view.frame.size.height;
            }
        }
        
        [self.messageView setFrame:CGRectMake(self.messageView.frame.origin.x,
                                              self.messageView.frame.origin.y,
                                              width,
                                              self.messageView.frame.size.height)];
        [rootViewController.view addSubview:self.messageView];
    }
    
    [self.messageView setTitle:message success:success];
}

- (void)removeMessageView {
    [self.messageView removeFromSuperview];
}

# pragma mark Error Views

- (void)onSuccessResponse:(RIApiResponse)apiResponse messages:(NSArray *)successMessages showMessage:(BOOL)showMessage
{
    [self removeErrorView];
    if (showMessage) {
        [self showMessage:[successMessages componentsJoinedByString:@","] success:YES];
    }
}

- (void)onErrorResponse:(RIApiResponse)apiResponse messages:(NSArray *)errorMessages showAsMessage:(BOOL)showAsMessage selector:(SEL)selector objects:(NSArray *)objects
{
    [self removeErrorView];
    if (RIApiResponseMaintenancePage == apiResponse) {
        [self showMaintenancePage:selector objects:objects];
    }
    else if(RIApiResponseKickoutView == apiResponse)
    {
        [self showKickoutView:selector objects:objects];
    }
    else if (RIApiResponseNoInternetConnection == apiResponse)
    {
        if (showAsMessage) {
            [self showMessage:STRING_NO_CONNECTION success:NO];
        }else{
            [self showErrorView:YES startingY:self.viewBounds.origin.y selector:selector objects:objects];
        }
    }else if (showAsMessage) {
        [self showMessage:[errorMessages componentsJoinedByString:@","] success:NO];
    }else{
        [self showErrorView:NO startingY:self.viewBounds.origin.y selector:selector objects:objects];
    }
}

- (void)showErrorView:(BOOL)isNoInternetConnection startingY:(CGFloat)startingY selector:(SEL)selector objects:(NSArray *)objects {
    if (VALID_NOTEMPTY(self.noConnectionView, JANoConnectionView)) {
//        [self.noConnectionView removeFromSuperview];
        
    }else{
        self.noConnectionView = [JANoConnectionView getNewJANoConnectionViewWithFrame:self.viewBounds];
        
        // This is to avoid a retain cycle
        __block JABaseViewController *viewController = self;
        [self.noConnectionView setRetryBlock: ^(BOOL dismiss)
         {
             if ([viewController respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                 if (ISEMPTY(objects)) {
                     [viewController performSelector:selector];
                 }
                 else if (1 == [objects count]) {
                     [viewController performSelector:selector withObject:[objects objectAtIndex:0]];
                 }
                 else if (2 == [objects count]) {
                     [viewController performSelector:selector withObject:[objects objectAtIndex:0] withObject:[objects objectAtIndex:1]];
                 }
#pragma clang diagnostic pop
             }
         }];
        [self.view addSubview:self.noConnectionView];
    }
    
    [self.noConnectionView setupNoConnectionViewForNoInternetConnection:isNoInternetConnection];
    
    _noConnectionViewFrame = CGRectMake(0.0f,
                                              0.0f,
                                              [[UIScreen mainScreen] bounds].size.width,
                                              [[UIScreen mainScreen] bounds].size.height);
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        if (_noConnectionViewFrame.size.width > _noConnectionViewFrame.size.height) {
            _noConnectionViewFrame  = CGRectMake(0.0f, startingY, _noConnectionViewFrame.size.height, _noConnectionViewFrame.size.width - startingY);
        }
        else {
            _noConnectionViewFrame  = CGRectMake(0.0f, startingY, _noConnectionViewFrame.size.width, _noConnectionViewFrame.size.height - startingY);
        }
    }
    else {
        if (_noConnectionViewFrame.size.width > _noConnectionViewFrame.size.height) {
            _noConnectionViewFrame  = CGRectMake(0.0f, startingY, _noConnectionViewFrame.size.width, _noConnectionViewFrame.size.height - startingY);
        }
        else {
            _noConnectionViewFrame  = CGRectMake(0.0f, startingY, _noConnectionViewFrame.size.height, _noConnectionViewFrame.size.width - startingY);
        }
    }
    
    [self.noConnectionView setFrame:_noConnectionViewFrame];
    
    [self.view bringSubviewToFront:self.noConnectionView];
}

- (void)removeErrorView {
    [self.noConnectionView removeFromSuperview];
    self.noConnectionView = nil;
}

- (void)showMaintenancePage:(SEL)selector objects:(NSArray *)objects {
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    
    self.maintenancePage = [JAMaintenancePage getNewJAMaintenancePage];
    [self.maintenancePage setupMaintenancePage:window.frame orientation:self.interfaceOrientation];
    __block JABaseViewController *viewController = self;
    [self.maintenancePage setRetryBlock: ^(BOOL dismiss)
     {
         if ([viewController respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             if (ISEMPTY(objects)) {
                 [viewController performSelector:selector];
             }
             else if (1 == [objects count]) {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0]];
             }
             else if (2 == [objects count]) {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0] withObject:[objects objectAtIndex:1]];
             }
#pragma clang diagnostic pop
         }
     }];
    
    for (UIView *view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAMaintenancePage class]]) {
            [view removeFromSuperview];
        }
    }
    
    [window.rootViewController.view addSubview:self.maintenancePage];
}

- (void)removeMaintenancePage {
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    for (UIView *view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAMaintenancePage class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}

- (void)showKickoutView:(SEL)selector objects:(NSArray *)objects {
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    
    self.kickoutView = [[JAKickoutView alloc] init];
    [self.kickoutView setupKickoutView:window.frame orientation:self.interfaceOrientation];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    __block JABaseViewController *viewController = self;
    [self.kickoutView setRetryBlock: ^(BOOL dismiss)
     {
         if ([viewController respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             if (ISEMPTY(objects)) {
                 [viewController performSelector:selector];
             }
             else if (1 == [objects count]) {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0]];
             }
             else if (2 == [objects count]) {
                 [viewController performSelector:selector withObject:[objects objectAtIndex:0] withObject:[objects objectAtIndex:1]];
             }
#pragma clang diagnostic pop
         }
     }];
    
    for (UIView *view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAKickoutView class]]) {
            [view removeFromSuperview];
        }
    }
    
    [window.rootViewController.view addSubview:self.kickoutView];
}

- (void)removeKickoutView {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    UIWindow *window = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window;
    for (UIView *view in window.rootViewController.view.subviews) {
        if ([view isKindOfClass:[JAKickoutView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}

@end
