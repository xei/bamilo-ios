//
//  JACategoriesSideMenuViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 15/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JACategoriesSideMenuViewController.h"
#import "RICategory.h"
#import "JAClickableView.h"
#import "JAAppDelegate.h"
#import "RIExternalCategory.h"
#import "JAButton.h"
#import "Bamilo-Swift.h"

@interface JACategoriesSideMenuViewController () <UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet SearchBarControl *searchbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarHeight;

@property (nonatomic, strong) NSArray* categoriesArray;
@property (nonatomic, strong) RIExternalCategory *externalCategory;
@property (nonatomic, strong) NSMutableArray* tableViewCategoriesArray;

@property (strong, nonatomic) UIView *loadingView;
@property (nonatomic, strong) UIImageView *loadingAnimation;

@property (nonatomic, strong) NSLock *reloadLock;
@property (nonatomic) BOOL categoriesLoadingError;
@property (nonatomic, strong) JAMessageView *messageView;

@property (nonatomic, strong) ScrollerBarFollower *navbarFollower;
@property (nonatomic, strong) ScrollerBarFollower *searchBarFollower;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarBottomToTopTableViewConstraint;

@end

@implementation JACategoriesSideMenuViewController {
    UITableViewRowAnimation animationInsert, animationDelete;
}

- (JAMessageView *)messageView {
    if (!VALID_NOTEMPTY(_messageView, JAMessageView)) {
        _messageView = [[JAMessageView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, kMessageViewHeight)];
        [_messageView setupView];
    }
    return _messageView;
}

# pragma mark Loading View
//THIS IS NOT A BASE VIEW CONTROLLER SO IT NEEDS ITS OWN LOADING VIEW

- (NSLock *)reloadLock {
    if (!VALID(_reloadLock, NSLock)) {
        _reloadLock = [NSLock new];
    }
    return _reloadLock;
}

- (void)initLoading {
    self.loadingView = [[UIImageView alloc] initWithFrame:((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame];
    self.loadingView.backgroundColor = [UIColor blackColor];
    self.loadingView.alpha = 0.0f;
    self.loadingView.userInteractionEnabled = YES;
    
    UIImage *image = [UIImage imageNamed:@"loadingAnimationFrame1"];
    
    int lastFrame = 8;
    
    self.loadingAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
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

- (void)showLoading {
    if (NO == VALID_NOTEMPTY(self.loadingView, UIView)) {
        [self initLoading];
    }
    
    [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingView];
    [((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view addSubview:self.loadingAnimation];
    
    [self.loadingAnimation startAnimating];
    
    [UIView animateWithDuration:0.4f
                     animations: ^{
                         self.loadingView.alpha = 0.5f;
                         self.loadingAnimation.alpha = 0.5f;
                     }];
}

- (void)hideLoading {
    [UIView animateWithDuration:0.4f animations: ^{
                         self.loadingView.alpha = 0.0f;
                         self.loadingAnimation.alpha = 0.0f;
                     } completion: ^(BOOL finished) {
                         [self.loadingView removeFromSuperview];
                         [self.loadingAnimation removeFromSuperview];
                     }];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.A4SViewControllerAlias = @"SUBCATEGORY";

    self.view.backgroundColor = JABlack300Color;
    
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:kSideMenuShouldReload object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCategories) name:kSideMenuShouldReload object:nil];
    animationInsert = UITableViewRowAnimationRight;
    animationDelete = UITableViewRowAnimationLeft;
    
    self.searchbar.searchView.textField.delegate = self;
    [self.view bringSubviewToFront:self.searchbar];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetNavbarStatusBar) name:@"appDidEnterForeground" object:nil];
}


- (void)reloadData {
    [self reloadCategories];
    [self reloadExternalLinks];
}

- (void)reloadCategories {
    [self showLoading];
    
    [RICategory getCategoriesWithSuccessBlock:^(id categories) {
        self.categoriesLoadingError = NO;
        self.categoriesArray = [NSArray arrayWithArray:(NSArray *)categories];
        [self categoriesLoaded];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
        self.categoriesLoadingError = YES;
        [self categoriesLoaded];
        [self hideLoading];
    }];
}

- (void)reloadExternalLinks {
    [self showLoading];
    [RIExternalCategory getExternalCategoryWithSuccessBlock:^(RIExternalCategory *externalCategory) {
        self.externalCategory = externalCategory;
        [self categoriesLoaded];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
        [self hideLoading];
    }];
}

- (void)categoriesLoaded {
    [self.reloadLock lock];
    
    NSInteger externalIndex = -1;
    if (VALID_VALUE(self.externalCategory, RIExternalCategory)) {
        externalIndex = self.externalCategory.position.integerValue;
    }
    
    self.tableViewCategoriesArray = [NSMutableArray new];
    int j = 0;
    for (RICategory* category in self.categoriesArray) {
        if (externalIndex == j) {
            [self.tableViewCategoriesArray addObject:self.externalCategory];
            for (RIExternalCategory *external in self.externalCategory.children) {
                [self.tableViewCategoriesArray addObject:external];
                externalIndex++;
            }
            externalIndex = -1;
        }
        [self.tableViewCategoriesArray addObject:category];
        if (category.level.integerValue == 0) {
            j++;
        }
        for (RICategory* levelOneCategory in category.children) {
            [self.tableViewCategoriesArray addObject:levelOneCategory];
        }
    } if (externalIndex != -1) {
        [self.tableViewCategoriesArray addObject:self.externalCategory];
        for (RIExternalCategory *external in self.externalCategory.children) {
            [self.tableViewCategoriesArray addObject:external];
            externalIndex++;
        }
    }
    
    [self.tableView reloadData];
    [self.reloadLock unlock];
    
    
    //assign scrollbar follower to bar views
    self.navbarFollower = [ScrollerBarFollower new];
    [self.navbarFollower setWithBarView:self.navigationController.navigationBar moveDirection:@"TOP"];
    self.searchBarFollower = [ScrollerBarFollower new];
    [self.searchBarFollower setWithBarView:self.searchbar moveDirection:@"TOP"];
    
    CGFloat tableViewTopOffset = self.navigationController.navigationBar.height;
    self.searchBarBottomToTopTableViewConstraint.constant = -tableViewTopOffset;
    
    [self.tableView setContentInset:UIEdgeInsetsMake(tableViewTopOffset, 0, 0, 0)];
    [self.tableView setContentOffset:CGPointMake(0, -tableViewTopOffset)];
    
    [self.navbarFollower followScrollViewWithScrollView:self.tableView delay: -tableViewTopOffset permittedMoveDistance: self.navigationController.navigationBar.height];
    [self.searchBarFollower followScrollViewWithScrollView:self.tableView delay: -tableViewTopOffset permittedMoveDistance:self.navigationController.navigationBar.height];
}

- (void)popToRoot {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self resetNavbarStatusBar];
}

- (void)resetNavbarStatusBar {
    [self.navbarFollower resetBarFrameWithAnimated:NO];
    [self.searchBarFollower resetBarFrameWithAnimated:NO];
}

#pragma mark - UITableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((self.categoriesLoadingError && indexPath.row > self.tableViewCategoriesArray.count-1) || self.tableViewCategoriesArray.count == 0) {
        return 40;
    }
    id category = [self.tableViewCategoriesArray objectAtIndex:indexPath.row];
    return [JACategoriesSideMenuCell heightForCategory:category];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.categoriesLoadingError) {
        return self.tableViewCategoriesArray.count + 1;
    }
    return self.tableViewCategoriesArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((self.categoriesLoadingError && indexPath.row > self.tableViewCategoriesArray.count - 1) || self.tableViewCategoriesArray.count == 0) {
        UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:@"retryCell"];
        if (!tableViewCell) {
            tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"retryCell"];
        }
        tableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        JAButton *retryButton = [[JAButton alloc] initAlternativeButtonWithTitle:STRING_TRY_AGAIN];
        [retryButton setFrame:CGRectMake(0.f, 0.f, tableView.width, tableViewCell.height)];
        [tableViewCell addSubview:retryButton];
        [retryButton addTarget:self action:@selector(reloadCategories) forControlEvents:UIControlEventTouchUpInside];
        return tableViewCell;
    }
    
    NSString *cellIdentifier = @"cell";
    
    JACategoriesSideMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[JACategoriesSideMenuCell alloc] initWithReuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    id category = [self.tableViewCategoriesArray objectAtIndex:indexPath.row];
    NSNumber *level = nil;
    if ([category isKindOfClass:[RICategory class]]) {
        level = [(RICategory *)category level];
    } else if ([category isKindOfClass:[RIExternalCategory class]]) {
        level = [(RIExternalCategory *)category level];
    }
    
    BOOL isOpen = NO;
    BOOL hasSeparator = NO;
    if (self.tableViewCategoriesArray.count - 1 != indexPath.row) {
        //not the last cell
        //check the next cell's category
        id nextCategory = [self.tableViewCategoriesArray objectAtIndex:indexPath.row + 1];
        NSNumber *nextLevel = nil;
        if ([nextCategory isKindOfClass:[RICategory class]]) {
            nextLevel = [(RICategory *)nextCategory level];
        } else if ([category isKindOfClass:[RIExternalCategory class]]) {
            nextLevel = [(RIExternalCategory *)nextCategory level];
        }
        if ([nextLevel integerValue] > [level integerValue]) {
            isOpen = YES;
        }
        if (1 <= [nextLevel integerValue]) {
            hasSeparator = YES;
        }
        
    }
    
    [cell setupWithCategory:category width:self.tableView.width hasSeparator:hasSeparator isOpen:isOpen];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.categoriesLoadingError && indexPath.row > self.tableViewCategoriesArray.count-1) {
        [self reloadData];
    }
}

- (void)categoryWasSelected:(id)category {
    NSNumber *level = [self getLevelForCategory:category];
    NSOrderedSet *children = [self getChildrenForCategory:category];
    NSInteger index = [self getIndexOfTheCategory:category];
    
    if (VALID_NOTEMPTY(children, NSOrderedSet)) {
        [self updateCategory:category children:children index:index level:level toClose:[self getIfToClose:index level:level]];
    } else {
        //This does not have children so just open up the category
        if ([category isKindOfClass:[RICategory class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification
                                                                object:@{@"category":category}];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[RITarget getURLStringforTargetString:[(RIExternalCategory *)category targetString]]]];
            
            NSMutableDictionary* externalLinkTrackingDictionary = [NSMutableDictionary new];
            [externalLinkTrackingDictionary setValue:@"ExternalLink" forKey:kRIEventCategoryKey];
            [externalLinkTrackingDictionary setValue:[(RIExternalCategory *)category label] forKey:kRIEventActionKey];
            [externalLinkTrackingDictionary setValue:@"CategoriesTree" forKey:kRIEventLabelKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCategoryExternalLink]
                                                      data:[externalLinkTrackingDictionary copy]];
        }
    }
}

- (void)showMessage:(NSString *)message success:(BOOL)success {
    if (!VALID(self.messageView.superview, JAMessageView)) {
        UIViewController *rootViewController = ((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
        [rootViewController.view addSubview:self.messageView];
    }
    [self.messageView setFrame:CGRectMake(0, 64, self.messageView.superview.width, kMessageViewHeight)];
    
    [self.messageView setTitle:message success:success];
}

#pragma mark - Helpers
- (NSNumber *)getLevelForCategory:(id)category {
    if ([category isKindOfClass:[RICategory class]]) {
        return [(RICategory *)category level];
    } else if ([category isKindOfClass:[RIExternalCategory class]]) {
        return [(RIExternalCategory *)category level];
    }
    
    return nil;
}

- (NSOrderedSet *)getChildrenForCategory:(id)category {
    if ([category isKindOfClass:[RICategory class]]) {
        return [(RICategory *)category children];
    } else if ([category isKindOfClass:[RIExternalCategory class]]) {
        return [(RIExternalCategory *)category children];
    }
    
    return nil;
}

- (void)updateCategory:(id)category children:(NSOrderedSet *)children index:(NSInteger)index level:(NSNumber *)level toClose:(BOOL)toClose {
    if (toClose) {
        //Close Down
        if(children.count > 0) {
            for(id sCategory in children) {
                NSNumber *sLevel = [self getLevelForCategory:sCategory];
                NSOrderedSet *sChildren = [self getChildrenForCategory:sCategory];
                NSInteger sIndex = [self getIndexOfTheCategory:sCategory];
                
                if([self getIfToClose:sIndex level:sLevel]) {
                    [self updateCategory:sCategory children:sChildren index:sIndex level:sLevel toClose:toClose];
                }
                
                [self removeChildFromTableView:sIndex];
            }
        } else {
            [self removeChildFromTableView:index];
        }
    } else {
        //Open Up
        [self addChildrenToTableView:children index:index];
    }
    
    [self updateRowInTableView:index];
}

-(NSInteger) getIndexOfTheCategory:(id)category {
    //based on category, find the index
    NSInteger index = 0;
    
    for (int i = 0; i < self.tableViewCategoriesArray.count; i++) {
        id tableCategory = [self.tableViewCategoriesArray objectAtIndex:i];
        if (tableCategory == category) {
            //found it
            index = i;
            break;
        }
    }
    return index;
}

-(BOOL) getIfToClose:(NSInteger)index level:(NSNumber *)level {
    BOOL isOpen = NO;
    
    if (self.tableViewCategoriesArray.count - 1 != index) {
        id nextCategory = [self.tableViewCategoriesArray objectAtIndex:index + 1];
        NSNumber *nextLevel = nil;
        if ([nextCategory isKindOfClass:[RICategory class]]) {
            nextLevel = [(RICategory *)nextCategory level];
        } else if ([nextCategory isKindOfClass:[RIExternalCategory class]]) {
            nextLevel = [(RIExternalCategory *)nextCategory level];
        }
        if ([nextLevel integerValue] > [level integerValue]) {
            isOpen = YES;
        }
    }
    
    return isOpen;
}

-(void) updateRowInTableView:(NSInteger)index {
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)removeChildFromTableView:(NSInteger)index {
    [self.tableViewCategoriesArray removeObjectAtIndex:index];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:animationDelete];
    [self.tableView endUpdates];
}

- (void)addChildrenToTableView:(NSOrderedSet *)children index:(NSInteger)index {
    //Open Up
    NSMutableArray* insertIndexPaths = [NSMutableArray new];
    for (int i = 0; i < [children count]; i++) {
        id child = [children objectAtIndex:i];
        
        NSInteger newIndex = index + i + 1;
        [self.tableViewCategoriesArray insertObject:child atIndex:newIndex];
        
        [insertIndexPaths addObject:[NSIndexPath indexPathForRow:newIndex inSection:0]];
    }
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:animationInsert];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

#pragma mark: - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self.navbarFollower resetBarFrameWithAnimated:NO];
    [self.searchBarFollower resetBarFrameWithAnimated:NO];
    
    [self performSegueWithIdentifier:@"ShowSearchView" sender:nil];
}

#pragma mark: - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.navbarFollower scrollViewDidScroll:scrollView];
    [self.searchBarFollower scrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.navbarFollower scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    [self.searchBarFollower scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

#pragma mark: DataTrackerProtocol
- (NSString *)getScreenName {
    return @"CategoryMenu";
}


#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_CATEGORIES;
}
//
//- (NavBarLeftButtonType)navBarleftButton {
//    return NavBarLeftButtonTypeSearch;
//}

@end
