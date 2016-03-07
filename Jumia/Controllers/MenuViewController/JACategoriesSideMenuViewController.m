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

@interface JACategoriesSideMenuViewController ()

@property (nonatomic, strong)NSArray* categoriesArray;
@property (nonatomic, strong)UITableView* tableView;
@property (nonatomic, strong)NSMutableArray* tableViewCategoriesArray;

@property (strong, nonatomic) UIView *loadingView;
@property (nonatomic, strong) UIImageView *loadingAnimation;

@end

@implementation JACategoriesSideMenuViewController

# pragma mark Loading View
//THIS IS NOT A BASE VIEW CONTROLLER SO IT NEEDS ITS OWN LOADING VIEW

- (void)initLoading
{
    self.loadingView = [[UIImageView alloc] initWithFrame:((JAAppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController.view.frame];
    self.loadingView.backgroundColor = [UIColor blackColor];
    self.loadingView.alpha = 0.0f;
    self.loadingView.userInteractionEnabled = YES;
    
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
    
    [UIView animateWithDuration:0.4f
                     animations: ^{
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

    self.view.backgroundColor = JANavBarBackgroundGrey;
    
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:kSideMenuShouldReload object:nil];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCategories) name:kSideMenuShouldReload object:nil];
    
    [self reloadCategories];

}

- (void)reloadCategories
{
    [self showLoading];
    [RICategory getCategoriesWithSuccessBlock:^(id categories) {
        
        self.categoriesArray = [NSArray arrayWithArray:(NSArray *)categories];
        [self categoriesLoaded];
        
        [self hideLoading];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
        
        [self hideLoading];
    }];
}

- (void)categoriesLoaded
{
    self.tableViewCategoriesArray = [NSMutableArray new];
    for (RICategory* category in self.categoriesArray) {
        [self.tableViewCategoriesArray addObject:category];
        for (RICategory* levelOneCategory in category.children) {
            [self.tableViewCategoriesArray addObject:levelOneCategory];
        }
    }
    [self.tableView reloadData];
}

- (void)popToRoot
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //manually add the status bar height into the calculations
    CGFloat statusBarHeight = 0.0f;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        statusBarHeight = 20.0f;
    }
    [self.tableView setFrame:CGRectMake(self.view.bounds.origin.x,
                                        self.view.bounds.origin.y + statusBarHeight,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height - statusBarHeight)];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    //manually add the status bar height into the calculations
    CGFloat statusBarHeight = 0.0f;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        statusBarHeight = 20.0f;
    }
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView setFrame:CGRectMake(self.view.bounds.origin.x,
                                        self.view.bounds.origin.y + statusBarHeight,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height - statusBarHeight)];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RICategory* category = [self.tableViewCategoriesArray objectAtIndex:indexPath.row];
    return [JACategoriesSideMenuCell heightForCategory:category];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableViewCategoriesArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    
    JACategoriesSideMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[JACategoriesSideMenuCell alloc] initWithReuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    
    RICategory* category = [self.tableViewCategoriesArray objectAtIndex:indexPath.row];
    
    BOOL isOpen = NO;
    BOOL hasSeparator = NO;
    if (self.tableViewCategoriesArray.count -1 != indexPath.row) {
        //not the last cell
        //check the next cell's category
        RICategory* nextCategory = [self.tableViewCategoriesArray objectAtIndex:indexPath.row + 1];
        if ([nextCategory.level integerValue] > [category.level integerValue]) {
            isOpen = YES;
        }
        if (1 <= [nextCategory.level integerValue]) {
            hasSeparator = YES;
        }
    }
    
    [cell setupWithCategory:category width:256.0f hasSeparator:hasSeparator isOpen:isOpen];
    
    return cell;
}

- (void)categoryWasSelected:(RICategory*)category;
{
    UITableViewRowAnimation animationInsert = UITableViewRowAnimationLeft;
    UITableViewRowAnimation animationDelete = UITableViewRowAnimationRight;
    if (RI_IS_RTL) {
        animationInsert = UITableViewRowAnimationRight;
        animationDelete = UITableViewRowAnimationLeft;
    }
    
    //based on category, find the index
    NSInteger index = 0;
    for (int i = 0; i < self.tableViewCategoriesArray.count; i++) {
        RICategory* tableCategory = [self.tableViewCategoriesArray objectAtIndex:i];
        if (tableCategory == category) {
            //found it
            index = i;
            break;
        }
    }
    
    if (1 == [category.level integerValue] && VALID_NOTEMPTY(category.children, NSOrderedSet)) {
        
        //this level 1 has children, find out if we're supposed to open or close
        
        BOOL isOpen = NO;
        if (self.tableViewCategoriesArray.count -1 != index) {
            //not the last cell
            //check the next cell's category
            RICategory* nextCategory = [self.tableViewCategoriesArray objectAtIndex:index + 1];
            if ([nextCategory.level integerValue] > [category.level integerValue]) {
                isOpen = YES;
            }
        }
        
        if (isOpen) {
            //close
            NSMutableArray* deleteIndexPaths = [NSMutableArray new];
            for (NSInteger i = index+category.children.count; i > index; i--) {
                //this for goes backwards so that we can remove the items from the arrays without the index problems
                
                [self.tableViewCategoriesArray removeObjectAtIndex:i];
                
                [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:animationDelete];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            
        } else {
            //open
            NSMutableArray* insertIndexPaths = [NSMutableArray new];
            for (int i = 0; i < category.children.count; i++) {
                RICategory* child = [category.children objectAtIndex:i];
                
                NSInteger newIndex = index + i + 1;
                [self.tableViewCategoriesArray insertObject:child atIndex:newIndex];

                [insertIndexPaths addObject:[NSIndexPath indexPathForRow:newIndex inSection:0]];
            }
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:animationInsert];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
        }
    } else {
    
        //not a level 1 with children means we just have to open the category
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification
                                                            object:@{@"category":category}];
    }
}

@end
