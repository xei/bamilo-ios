//
//  JAMainFiltersViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMainFiltersViewController.h"
#import "RIFilter.h"
#import "RICategory.h"
#import "JAClickableView.h"
#import "JAPriceFiltersView.h"
#import "JAGenericFiltersView.h"
#import "JAMainFilterCell.h"

@interface JAMainFiltersViewController ()

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIControl* lastSelectedClickView;
@property (nonatomic, strong)UIView* verticalSeparatorView;
@property (nonatomic, strong)UIView* landscapeContentView;
@property (nonatomic, assign)CGRect tableRectPortrait;
@property (nonatomic, assign)CGRect tableRectLandscape;

//@property (nonatomic, strong)NSNotification* currentOpenFilterNotification;

@end

@implementation JAMainFiltersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Filters";
    
    self.navBarLayout.title = STRING_FILTERS;
    self.navBarLayout.showEditButton = YES;
    self.navBarLayout.showDoneButton = YES;
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    self.verticalSeparatorView = [UIView new];
    self.verticalSeparatorView.backgroundColor = UIColorFromRGB(0xcccccc);
    [self.view addSubview:self.verticalSeparatorView];
    
    self.landscapeContentView = [UIView new];
    [self.view addSubview:self.landscapeContentView];
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter postNotificationName:kTurnOffMenuSwipePanelNotification
                                      object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(editButtonPressed)
                               name:kDidPressEditNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(doneButtonPressed)
                               name:kDidPressDoneNotification
                             object:nil];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.tableRectPortrait = CGRectMake(0.0f,
                                            0.0f,
                                            self.view.frame.size.height + 64.0f,
                                            self.view.frame.size.width - 64.0f);
        self.tableRectLandscape = CGRectMake(0.0f,
                                             0.0f,
                                             self.view.frame.size.width / 2,
                                             self.view.frame.size.height);
        [self.tableView setFrame:self.tableRectLandscape];
        [self.verticalSeparatorView setFrame:CGRectMake(CGRectGetMaxX(self.tableRectLandscape) - 1,
                                                        0.0f,
                                                        1.0f,
                                                        self.tableRectLandscape.size.height)];
        [self.landscapeContentView setFrame:CGRectMake(CGRectGetMaxX(self.tableRectLandscape),
                                                       0.0f,
                                                       self.tableRectLandscape.size.width,
                                                       self.tableRectLandscape.size.height)];
    } else {
        self.tableRectPortrait = CGRectMake(0.0f,
                                            0.0f,
                                            self.view.frame.size.width,
                                            self.view.frame.size.height);
        self.tableRectLandscape = CGRectMake(0.0f,
                                             0.0f,
                                             (self.view.frame.size.height + 64.0f) / 2,
                                             self.view.frame.size.width - 64.0f);
        [self.tableView setFrame:self.tableRectPortrait];
    }
    
    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"Filters"];
}

- (BOOL)checkEditButtonState
{
    NSInteger numberOfRows = [self tableView:self.tableView numberOfRowsInSection:0];
    BOOL buttonIsEnabled = NO;
    for (int i = 0; i < numberOfRows; i++) {
        if (YES == [self rowHasFiltersSelected:i]) {
            buttonIsEnabled = YES;
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEditShouldChangeStateNotification object:nil userInfo:@{@"enabled":[NSNumber numberWithBool:buttonIsEnabled]}];
    
    return buttonIsEnabled;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updatedValues];
    
    [self.tableView reloadData];
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.tableView setFrame:self.tableRectLandscape];
        [self.verticalSeparatorView setFrame:CGRectMake(CGRectGetMaxX(self.tableRectLandscape) - 1,
                                                        0.0f,
                                                        1.0f,
                                                        self.tableRectLandscape.size.height)];
        [self.landscapeContentView setFrame:CGRectMake(CGRectGetMaxX(self.tableRectLandscape),
                                                       0.0f,
                                                       self.tableRectLandscape.size.width,
                                                       self.tableRectLandscape.size.height)];
    } else {
        [self.tableView setFrame:self.tableRectPortrait];
        [self.verticalSeparatorView setFrame:CGRectZero];
        [self.landscapeContentView setFrame:CGRectZero];
        [self isClosing:nil];
        //        if (self.currentOpenFilterNotification) {
        //            [[NSNotificationCenter defaultCenter] postNotification:self.currentOpenFilterNotification];
        //        }
    }
    
    if (RI_IS_RTL) {
        [self.view flipSubviewPositions];
    }
}

#pragma mark - Button Actions

- (void)editButtonPressed
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [self checkEditButtonState];
}

- (void)doneButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatedFilters)]) {
        [self.delegate updatedFilters];
    }
}

#pragma mark - UITableView

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.filtersArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"mainFilterCell";
    
    JAMainFilterCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[JAMainFilterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    RIFilter* filter = [self.filtersArray objectAtIndex:indexPath.row];
    
    [cell setupWithFilter:filter options:[self stringWithSelectedOptionsFromFilter:filter] width:tableView.frame.size.width];
    cell.clickView.tag = indexPath.row;
    [cell.clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSString*)stringWithSelectedOptionsFromFilter:(RIFilter*)filter
{
    NSString* string = STRING_ALL;
    
    if (NOTEMPTY(filter.options)) {
        
        if ([filter.uid isEqualToString:@"price"]) {
            
            RIFilterOption* option = [filter.options firstObject];
            
            string = [NSString stringWithFormat:@"%ld - %ld", (long)option.lowerValue, (long)option.upperValue];
        }else{
        
            NSMutableArray* selectedOptionsNames = [NSMutableArray new];
            
            for (RIFilterOption* option in filter.options) {
                if (option.selected) {
                    NSString *name = option.name;
                    if ([filter.uid isEqualToString:@"rating"]) {
                        name = [NSString stringWithFormat:@"%@",option.val];
                    }
                    [selectedOptionsNames addObject:name];
                }
            }
            
            for (int i = 0; i < selectedOptionsNames.count; i++) {
                
                if (0 == i) {
                    string = [selectedOptionsNames objectAtIndex:i];
                } else {
                    
                    string = [NSString stringWithFormat:@"%@, %@", string, [selectedOptionsNames objectAtIndex:i]];
                }
            }
        }
    }
    
    return string;
}

- (void)cellWasPressed:(UIControl*)sender
{
    if (VALID_NOTEMPTY(self.lastSelectedClickView, UIControl) && sender != self.lastSelectedClickView) {
        self.lastSelectedClickView.selected = NO;
    }
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        sender.selected = YES;
        self.lastSelectedClickView = sender;
    }
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (UIView* subView in self.landscapeContentView.subviews) {
        [subView removeFromSuperview];
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:self forKey:@"delegate"];
    
    NSNotification* notification;
    JAFiltersView* filtersView;


    RIFilter* filter = [self.filtersArray objectAtIndex:indexPath.row];
    
    if ([filter.uid isEqualToString:@"price"]) {
        
        filtersView = [[[NSBundle mainBundle] loadNibNamed:@"JAPriceFiltersView" owner:self options:nil] objectAtIndex:0];
        [filtersView setFrame:self.landscapeContentView.bounds];
        [(JAPriceFiltersView*)filtersView initializeWithPriceFilterOption:[filter.options firstObject]];
        
        if(VALID_NOTEMPTY(filter.options, NSArray))
        {
            [userInfo setObject:[filter.options firstObject] forKey:@"priceFilterOption"];
        }
        notification = [NSNotification notificationWithName:kShowPriceFiltersScreenNotification object:nil userInfo:userInfo];
    } else {
        
        filtersView = [[[NSBundle mainBundle] loadNibNamed:@"JAGenericFiltersView" owner:self options:nil] objectAtIndex:0];
        [filtersView setFrame:self.landscapeContentView.bounds];
        [(JAGenericFiltersView*)filtersView initializeWithFilter:filter isLandscape:YES];
        
        
        if(VALID_NOTEMPTY(filter, RIFilter))
        {
            [userInfo setObject:filter forKey:@"filter"];
        }
        notification = [NSNotification notificationWithName:kShowGenericFiltersScreenNotification object:nil userInfo:userInfo];
    }

    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && VALID_NOTEMPTY(notification, NSNotification)) {
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    } else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && VALID_NOTEMPTY(filtersView, JAFiltersView)) {
        filtersView.filtersViewDelegate = self;
        filtersView.shouldAutosave = YES;
        [self.landscapeContentView addSubview:filtersView];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self rowHasFiltersSelected:indexPath.row]) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (BOOL)rowHasFiltersSelected:(NSInteger)row
{
    RIFilter* filter = [self.filtersArray objectAtIndex:row];
    
    if ([filter.uid isEqualToString:@"price"]) {
        
        RIFilterOption* option = [filter.options firstObject];
        
        if (option.lowerValue != option.min || option.upperValue != option.max) {
            return YES;
        }
    } else {
        
        for (RIFilterOption* option in filter.options) {
            
            if (option.selected) {
                return YES;
            }
        }
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (VALID_NOTEMPTY(self.lastSelectedClickView, UIControl) && indexPath.row == self.lastSelectedClickView.tag) {
        self.lastSelectedClickView.selected = NO;
        [self isClosing:nil];
    }
    RIFilter* filter = [self.filtersArray objectAtIndex:indexPath.row];
    
    for (RIFilterOption* option in filter.options) {
        option.selected = NO;
        option.lowerValue = option.min;
        option.upperValue = option.max;
        option.discountOnly = NO;
    }

    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if (NO == [self checkEditButtonState]) {
        [self.tableView setEditing:NO animated:YES];
    }
}

#pragma mark - JASubFiltersViewControllerDelegate

- (void)isClosing:(JASubFiltersViewController*)viewController;
{
//    self.currentOpenFilterNotification = nil;
    for (UIView* subView in self.landscapeContentView.subviews) {
        [subView removeFromSuperview];
    }
}

#pragma mark - JAFiltersViewDelegate

- (void)updatedValues;
{
    if (VALID_NOTEMPTY(self.lastSelectedClickView, UIControl)) {
        self.lastSelectedClickView.selected = NO;
    }
    [self.tableView reloadData];
    [self.tableView setEditing:NO animated:YES];
    [self checkEditButtonState];
}


@end
