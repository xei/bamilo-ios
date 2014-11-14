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
#import "JACategoryFiltersView.h"


@interface JAMainFiltersViewController ()

@property (nonatomic, strong)UITableView *tableView;
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
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.tableRectPortrait = CGRectMake(0.0f,
                                            0.0f,
                                            self.view.frame.size.height,
                                            self.view.frame.size.width);
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
                                             self.view.frame.size.height / 2,
                                             self.view.frame.size.width);
        [self.tableView setFrame:self.tableRectPortrait];
    }
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(editButtonPressed)
                               name:kDidPressEditNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(doneButtonPressed)
                               name:kDidPressDoneNotification
                             object:nil];
    
    [self updatedValues];
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0f];
}

- (void)checkEditButtonState
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
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
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.tableView reloadData];
}

#pragma mark - Button Actions

- (void)editButtonPressed
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    [self checkEditButtonState];
}

- (void)doneButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatedFiltersAndCategory:)]) {
        [self.delegate updatedFiltersAndCategory:self.selectedCategory];
    }
}

#pragma mark - UITableView

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (VALID_NOTEMPTY(self.categoriesArray, NSArray)) {
        return self.filtersArray.count + 1;
    } else {
        return self.filtersArray.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger filterIndex = indexPath.row;
    if (VALID_NOTEMPTY(self.categoriesArray, NSArray)) {
        filterIndex--;
    }
    
    NSString *cellIdentifier = @"mainFilterCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        cell.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
        
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
        cell.detailTextLabel.textColor = UIColorFromRGB(0x4e4e4e);
    }
    
    for (UIView* subview in cell.subviews) {
        if (subview.tag == -1) {
            [subview removeFromSuperview];
        }
    }
    UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, self.tableView.frame.size.width, 1.0f)];
    separator.tag = -1;
    separator.backgroundColor = UIColorFromRGB(0xcccccc);
    [cell addSubview:separator];

    if (-1 == filterIndex) {
        cell.textLabel.text = STRING_CATEGORIES;
        cell.detailTextLabel.text = [self stringWithSelectedCategory];
    } else {
        RIFilter* filter = [self.filtersArray objectAtIndex:filterIndex];
        cell.textLabel.text = filter.name;
        cell.detailTextLabel.text = [self stringWithSelectedOptionsFromFilter:filter];
    }
    
    //remove the clickable view
    for (UIView* view in cell.subviews) {
        if ([view isKindOfClass:[JAClickableView class]]) {
            [view removeFromSuperview];
        }
    }
    //add the new clickable view
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 44.0f)];
    clickView.tag = indexPath.row;
    [clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:clickView];
    
    return cell;
}

- (NSString*)stringWithSelectedCategory
{
    NSString* string = STRING_ALL;
    
    if (VALID_NOTEMPTY(self.selectedCategory, RICategory)) {
        string = self.selectedCategory.name;
    }
    
    return string;
}

- (NSString*)stringWithSelectedOptionsFromFilter:(RIFilter*)filter
{
    NSString* string = STRING_ALL;
    
    if (NOTEMPTY(filter.options)) {
        
        if ([filter.uid isEqualToString:@"price"]) {
            
            RIFilterOption* option = [filter.options firstObject];
            
            string = [NSString stringWithFormat:@"%d - %d", option.lowerValue, option.upperValue];
            
        } else {
            NSMutableArray* selectedOptionsNames = [NSMutableArray new];
            
            for (RIFilterOption* option in filter.options) {
                if (option.selected) {
                    [selectedOptionsNames addObject:option.name];
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
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger filterIndex = indexPath.row;
    if (VALID_NOTEMPTY(self.categoriesArray, NSArray)) {
        filterIndex--;
    }

    for (UIView* subView in self.landscapeContentView.subviews) {
        [subView removeFromSuperview];
    }
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:self forKey:@"delegate"];
    
    NSNotification* notification;
    JAFiltersView* filtersView;

    if (-1 == filterIndex) {
        
        filtersView = [[[NSBundle mainBundle] loadNibNamed:@"JACategoryFiltersView" owner:self options:nil] objectAtIndex:0];
        [filtersView setFrame:self.landscapeContentView.bounds];
        [(JACategoryFiltersView*)filtersView initializeWithCategories:self.categoriesArray selectedCategory:self.selectedCategory];
        
        [userInfo setObject:self forKey:@"categoryFiltersViewDelegate"];
        
        if(VALID_NOTEMPTY(self.selectedCategory, RICategory))
        {
            [userInfo setObject:self.selectedCategory forKey:@"selectedCategory"];
        }
        if(VALID_NOTEMPTY(self.categoriesArray, NSArray))
        {
            [userInfo setObject:self.categoriesArray forKey:@"categoriesArray"];
        }
       
        notification = [NSNotification notificationWithName:kShowCategoryFiltersScreenNotification object:nil userInfo:userInfo];
    } else {
        RIFilter* filter = [self.filtersArray objectAtIndex:filterIndex];
        
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
            [(JAGenericFiltersView*)filtersView initializeWithFilter:filter];

            
            if(VALID_NOTEMPTY(filter, RIFilter))
            {
                [userInfo setObject:filter forKey:@"filter"];
            }
            notification = [NSNotification notificationWithName:kShowGenericFiltersScreenNotification object:nil userInfo:userInfo];
        }
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
    if (VALID_NOTEMPTY(self.categoriesArray, NSArray)) {
        row--;
    }
    
    if (-1 == row) {
        if (VALID_NOTEMPTY(self.selectedCategory, RICategory)) {
            return YES;
        }
    } else {
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
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger filterIndex = indexPath.row;
    if (VALID_NOTEMPTY(self.categoriesArray, NSArray)) {
        filterIndex--;
    }
    
    if (-1 == filterIndex) {
        self.selectedCategory = nil;
    } else {
        RIFilter* filter = [self.filtersArray objectAtIndex:filterIndex];
        
        for (RIFilterOption* option in filter.options) {
            option.selected = NO;
            option.lowerValue = option.min;
            option.upperValue = option.max;
            option.discountOnly = NO;
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - JACategoryFiltersViewDelegate

- (void)selectedCategory:(RICategory *)category
{
    self.selectedCategory = category;
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
    [self.tableView reloadData];
    [self checkEditButtonState];
}


@end
