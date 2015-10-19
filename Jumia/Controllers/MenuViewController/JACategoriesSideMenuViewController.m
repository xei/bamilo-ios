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

@interface JACategoriesSideMenuViewController ()

@property (nonatomic, strong)UITableView* tableView;
@property (nonatomic, strong)NSMutableArray* tableViewCategoriesArray;

@end

@implementation JACategoriesSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.A4SViewControllerAlias = @"SUBCATEGORY";
    
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToRoot) name:kSideMenuShouldReload object:nil];

    self.tableViewCategoriesArray = [NSMutableArray new];
    for (RICategory* category in self.categoriesArray) {
        [self.tableViewCategoriesArray addObject:category];
        for (RICategory* levelOneCategory in category.children) {
            [self.tableViewCategoriesArray addObject:levelOneCategory];
        }
    }
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
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
    
    [self.tableView setFrame:self.view.bounds];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView setFrame:self.view.bounds];
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
    
    [cell setupWithCategory:category hasSeparator:hasSeparator isOpen:isOpen];
    
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
