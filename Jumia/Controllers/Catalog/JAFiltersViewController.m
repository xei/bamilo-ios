//
//  JAFiltersViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 05/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAFiltersViewController.h"
#import "JAFilterCell.h"
#import "RIFilter.h"
#import "JAGenericFiltersView.h"
#import "JAPriceFiltersView.h"

@interface JAFiltersViewController () <UITableViewDataSource, UITableViewDelegate, JAFiltersViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) JAFiltersView* currentFilterView;
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@property (nonatomic, strong) JAClickableView* clearAllView;
@property (nonatomic, strong) UIView* bottomSeparator;
@property (nonatomic, strong) UIView* verticalSeparator;

@end

@implementation JAFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBarLayout.title = STRING_FILTERS;
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.doneButtonTitle = STRING_APPLY;
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.clearAllView = [[JAClickableView alloc] init];
    self.clearAllView.backgroundColor = [UIColor whiteColor];
    [self.clearAllView setFont:[UIFont fontWithName:kFontRegularName size:14.0f]];
    [self.clearAllView setTitle:STRING_CLEAR_ALL forState:UIControlStateNormal];
    [self.clearAllView setTitleColor:JASysBlueColor forState:UIControlStateNormal];
    [self.clearAllView addTarget:self action:@selector(clearAllFilters) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clearAllView];
    
    self.bottomSeparator = [[UIView alloc] init];
    self.bottomSeparator.backgroundColor = JABlack400Color;
    [self.clearAllView addSubview:self.bottomSeparator];
    
    self.verticalSeparator = [[UIView alloc] init];
    self.verticalSeparator.backgroundColor = JABlack400Color;
    [self.view addSubview:self.verticalSeparator];
    
    [self selectIndex:0];
    [self updateTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyButtonPressed)
                                                 name:kDidPressDoneNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTitle
{
    NSInteger totalSelected = 0;
    for (RIFilter* filter in self.filtersArray) {
        if ([filter.uid isEqualToString:@"price"]) {
            RIFilterOption* option = [filter.options firstObject];
            if (option.lowerValue > option.min || option.upperValue < option.max || YES == option.discountOnly) {
                totalSelected++;
            }
        } else {
            for (RIFilterOption* option in filter.options) {
                if (option.selected) {
                    totalSelected++;
                }
            }
        }
    }
    NSString* newTitle;
    if (0 == totalSelected) {
        newTitle = STRING_FILTERS;
    } else {
        newTitle = [NSString stringWithFormat:@"%@ (%ld)", STRING_FILTERS, (long)totalSelected];
    }
    if (NO == [newTitle isEqualToString:self.navBarLayout.title]) {
        //the title changed, force a reload
        self.navBarLayout.title = newTitle;
        [self reloadNavBar];
    }
}

-(void)viewWillLayoutSubviews
{
    self.clearAllView.frame = CGRectMake(self.view.bounds.origin.x,
                                         self.view.bounds.size.height - 48.0f,
                                         self.view.bounds.size.width,
                                         48.0f);
    
    self.bottomSeparator.frame = CGRectMake(self.clearAllView.bounds.origin.x,
                                            self.clearAllView.bounds.origin.y,
                                            self.clearAllView.bounds.size.width,
                                            1.0f);
    CGFloat sideBarWidth = 120.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        sideBarWidth = 256.0f;
    }
    self.tableView.frame = CGRectMake(self.view.bounds.origin.x,
                                      self.view.bounds.origin.y,
                                      sideBarWidth,
                                      self.view.bounds.size.height - self.clearAllView.frame.size.height);
    
    self.verticalSeparator.frame = CGRectMake(CGRectGetMaxX(self.tableView.frame) - 1.0f,
                                              self.tableView.frame.origin.y,
                                              1.0f,
                                              self.tableView.frame.size.height);
    
    self.currentFilterView.frame = CGRectMake(CGRectGetMaxX(self.tableView.frame),
                                              self.view.bounds.origin.y,
                                              self.view.bounds.size.width - self.tableView.frame.size.width,
                                              self.view.bounds.size.height - self.clearAllView.frame.size.height);
    [self.currentFilterView reload];
    
    if (RI_IS_RTL) {
        [self.tableView flipViewPositionInsideSuperview];
        [self.verticalSeparator flipViewPositionInsideSuperview];
        [self.currentFilterView flipViewPositionInsideSuperview];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filtersArray.count;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JAFilterCell height];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"filterCell";
    
    JAFilterCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[JAFilterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    RIFilter* filter = [self.filtersArray objectAtIndex:indexPath.row];
    
    BOOL cellIsSelected = NO;
    if (indexPath.row == self.selectedIndexPath.row) {
        cellIsSelected = YES;
    }
    
    CGFloat margin = 16.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        margin = 32.0f;
    }
    [cell setupWithFilter:filter cellIsSelected:cellIsSelected width:tableView.frame.size.width margin:margin];
    cell.clickView.tag = indexPath.row;
    [cell.clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)cellWasPressed:(UIControl*)sender
{
    [self selectIndex:sender.tag];
}

- (void)selectIndex:(NSInteger)index
{
    NSIndexPath* oldSelectedIndexPath = self.selectedIndexPath;
    self.selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    if (VALID_NOTEMPTY(oldSelectedIndexPath, NSIndexPath) && oldSelectedIndexPath.row == self.selectedIndexPath.row) {
        return; //DO NOTHING
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:oldSelectedIndexPath, self.selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.currentFilterView removeFromSuperview];
    
    RIFilter* filter = [self.filtersArray objectAtIndex:index];
    
    if ([filter.uid isEqualToString:@"price"]) {
        
        self.currentFilterView = [[[NSBundle mainBundle] loadNibNamed:@"JAPriceFiltersView" owner:self options:nil] objectAtIndex:0];

        self.currentFilterView.frame = self.currentFilterView.frame = CGRectMake(CGRectGetMaxX(self.tableView.frame),
                                                                                 self.view.bounds.origin.y,
                                                                                 self.view.bounds.size.width - self.tableView.frame.size.width,
                                                                                 self.view.bounds.size.height);
        
        [(JAPriceFiltersView*)self.currentFilterView initializeWithPriceFilterOption:[filter.options firstObject]];
    } else {
        
        self.currentFilterView = [[[NSBundle mainBundle] loadNibNamed:@"JAGenericFiltersView" owner:self options:nil] objectAtIndex:0];

        self.currentFilterView.frame = self.currentFilterView.frame = CGRectMake(CGRectGetMaxX(self.tableView.frame),
                                                                                 self.view.bounds.origin.y,
                                                                                 self.view.bounds.size.width - self.tableView.frame.size.width,
                                                                                 self.view.bounds.size.height);
        
        [(JAGenericFiltersView*)self.currentFilterView initializeWithFilter:filter isLandscape:YES];
    }
    self.currentFilterView.filtersViewDelegate = self;
    [self.view addSubview:self.currentFilterView];
}


#pragma mark - JAFiltersViewDelegate

- (void)updatedValues;
{
    UITableViewRowAnimation animation = UITableViewRowAnimationAutomatic;
    RIFilter* filter = [self.filtersArray objectAtIndex:self.selectedIndexPath.row];
    if ([filter.uid isEqualToString:@"price"]) {
        animation = UITableViewRowAnimationNone;
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:animation];
    [self updateTitle];
}

#pragma Button Logic

- (void)clearAllFilters
{
    for (RIFilter* filter in self.filtersArray) {
        if ([filter.uid isEqualToString:@"price"]) {
            RIFilterOption* option = [filter.options firstObject];
            option.lowerValue = option.min;
            option.upperValue = option.max;
            option.discountOnly = NO;
        } else {
            for (RIFilterOption* option in filter.options) {
                option.selected = NO;
            }
        }
    }
    [self.tableView reloadData];
    [self updateTitle];
    NSInteger indexToReload = self.selectedIndexPath.row;
    self.selectedIndexPath = nil;
    [self selectIndex:indexToReload];
}

- (void)applyButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatedFilters:)]) {
        [self.delegate updatedFilters:self.filtersArray];
    }
}


@end
