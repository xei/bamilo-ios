//
//  JACategoriesViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 19/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACategoriesViewController.h"
#import "JAClickableView.h"

@interface JACategoriesViewController ()

@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray* categories;
@property (nonatomic, assign) RIApiResponse apiResponse;

@end

@implementation JACategoriesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.screenName = @"ShopCategories";
    self.A4SViewControllerAlias = @"CATEGORY";
    
    self.view.backgroundColor = JABackgroundGrey;
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 5.0f;
    [self.view addSubview:self.contentView];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds];
    self.tableView.layer.cornerRadius = 5.0f;
    [self.contentView addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self continueLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backButtonPressed)
                                                 name:kDidPressBackNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.contentView setFrame:CGRectMake(6.0f,
                                          6.0f,
                                          self.view.frame.size.width - 6.0f*2,
                                          1)];
    [self.tableView reloadData];
    
    CGFloat contentHeight = [self tableView:self.tableView heightForRowAtIndexPath:nil] * [self tableView:self.tableView numberOfRowsInSection:0];
    CGFloat maxHeight = self.view.frame.size.height - 6.0f*2;
    if (contentHeight > maxHeight) {
        [self.tableView setScrollEnabled:YES];
        contentHeight = maxHeight;
    } else {
        [self.tableView setScrollEnabled:NO];
    }
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x,
                                          self.contentView.frame.origin.y,
                                          self.contentView.frame.size.width,
                                          contentHeight)];
    [self.tableView setFrame:self.contentView.bounds];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

- (void)continueLoading
{
    if(self.apiResponse == RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    if (VALID_NOTEMPTY(self.currentCategory, RICategory)) {
        [self categoryLoadingFinished:[self.currentCategory.children array]];
    } else {
        [RICategory getCategoriesWithSuccessBlock:^(id categories) {
            [self categoryLoadingFinished:categories];
            [self removeErrorView];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
            
            [self removeErrorView];
            self.apiResponse = apiResponse;
            
            if(self.firstLoading)
            {
                NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                self.firstLoading = NO;
            }
            
            if(RIApiResponseMaintenancePage == apiResponse)
            {
                [self showMaintenancePage:@selector(continueLoading) objects:nil];
            }
            else
            {
                BOOL noConnection = NO;
                if (RIApiResponseNoInternetConnection == apiResponse)
                {
                    noConnection = YES;
                }
                [self showErrorView:noConnection startingY:0.0f selector:@selector(continueLoading) objects:nil];
            }
            
            [self hideLoading];
        }];
    }
}

- (void)categoryLoadingFinished:(NSArray*)categories
{
    [self hideLoading];
    
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
    
    self.categories = categories;
    [self.tableView reloadData];
    
    CGFloat contentHeight = [self tableView:self.tableView heightForRowAtIndexPath:nil] * [self tableView:self.tableView numberOfRowsInSection:0];
    CGFloat maxHeight = self.view.frame.size.height - 64.0f - 6.0f*2;
    if (contentHeight > maxHeight) {
        [self.tableView setScrollEnabled:YES];
        contentHeight = maxHeight;
    } else {
        [self.tableView setScrollEnabled:NO];
    }
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x,
                                          self.contentView.frame.origin.y,
                                          self.contentView.frame.size.width,
                                          contentHeight)];
    [self.tableView setFrame:self.contentView.bounds];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }    
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CGFloat total = self.categories.count + 1;//add one for title
    if (VALID_NOTEMPTY(self.currentCategory, RICategory)) {
        total++;
    }
    return total;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"categoryCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (UIView* view in cell.subviews) {
        if ([view isKindOfClass:[JAClickableView class]] || -1 == view.tag) { //remove the clickable view or separator
            [view removeFromSuperview];
        }
    }
    //add the new clickable view
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
    clickView.tag = indexPath.row;
    [clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:clickView];
    
    
    //add the new separator
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                 43.0f,
                                                                 self.view.frame.size.width,
                                                                 1)];
    separator.tag = -1;
    separator.backgroundColor = JALabelGrey;
    [cell addSubview:separator];
    
    NSInteger realIndex = indexPath.row;
    
    if (VALID_NOTEMPTY(self.backTitle, NSString)) {
        //has back cell
        if (0 == realIndex) {
            //this is the back cell
            cell.textLabel.text = self.backTitle;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
            cell.textLabel.textColor = UIColorFromRGB(0xc8c8c8);
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell.imageView setImage:[UIImage imageNamed:@"btn_back"]];
            return cell;
        }
        realIndex--;
    }
    
    [cell.imageView setImage:nil];
    
    if (VALID_NOTEMPTY(self.currentCategory, RICategory)) {
        //has current category
        if (0 == realIndex) {
            //this is the current category cell
            cell.textLabel.text = self.currentCategory.name;
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
            cell.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
    } else {
        //does not have current category
        if (0 == realIndex) {
            //this is the current category cell
            cell.textLabel.text = [STRING_CATEGORIES uppercaseString];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
            cell.textLabel.textColor = UIColorFromRGB(0xc8c8c8);
            cell.accessoryType = UITableViewCellAccessoryNone;
            clickView.enabled = NO;
            return cell;
        }
    }
    
    realIndex--;
    
    RICategory* category = [self.categories objectAtIndex:realIndex];
    
    cell.textLabel.text = category.name;
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
    cell.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
    if (VALID_NOTEMPTY(category.children, NSOrderedSet)) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)cellWasPressed:(UIControl*)sender
{
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger realIndex = indexPath.row;
    NSString* backButtonTitle = [STRING_CATEGORIES uppercaseString];
    
    if (VALID_NOTEMPTY(self.backTitle, NSString)) {
        //has back cell
        if (0 == realIndex) {
            //this is the back cell
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        realIndex--;
    }
    
    if (VALID_NOTEMPTY(self.currentCategory, RICategory)) {
        //has current category
        
        if (0 == realIndex) {
            //this is the current category cell
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectCategoryFromCenterPanelNotification
                                                                object:@{@"category":self.currentCategory}];
            return;
        }
        backButtonTitle = self.currentCategory.name;
    } else {
        if (0 == realIndex) {
            //do nothing
            return;
        }
    }
    
    realIndex--;
    
    RICategory* category = [self.categories objectAtIndex:realIndex];
    
    if (VALID_NOTEMPTY(category.children, NSOrderedSet)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithAllCategoriesNofication
                                                            object:@{@"category":category}
                                                          userInfo:@{@"backButtonTitle":backButtonTitle}];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectCategoryFromCenterPanelNotification
                                                            object:@{@"category":category}];
    }
}

#pragma mark - Button Actions

- (void)backButtonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

@end
