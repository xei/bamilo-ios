//
//  JAMainFiltersViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMainFiltersViewController.h"
#import "JAPriceFilterViewController.h"
#import "JAGenericFilterViewController.h"
#import "RIFilter.h"
#import "RICategory.h"

@interface JAMainFiltersViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JAMainFiltersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = UIColorFromRGB(0xcccccc);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kShowMainFiltersNavNofication
                                      object:self
                                    userInfo:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(editButtonPressed)
                               name:kDidPressEditNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(doneButtonPressed)
                               name:kDidPressDoneNotification
                             object:nil];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Button Actions

- (void)editButtonPressed
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
}

- (void)doneButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatedFiltersAndCategory:)]) {
        [self.delegate updatedFiltersAndCategory:self.selectedCategory];
    }
}

#pragma mark - UITableView

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

    if (-1 == filterIndex) {
        cell.textLabel.text = @"Categories";
        cell.detailTextLabel.text = [self stringWithSelectedCategory];
    } else {
        RIFilter* filter = [self.filtersArray objectAtIndex:filterIndex];
        cell.textLabel.text = filter.name;
        cell.detailTextLabel.text = [self stringWithSelectedOptionsFromFilter:filter];
    }
    
    return cell;
}

- (NSString*)stringWithSelectedCategory
{
    NSString* string = @"All";
    
    if (VALID_NOTEMPTY(self.selectedCategory, RICategory)) {
        string = self.selectedCategory.name;
    }
    
    return string;
}

- (NSString*)stringWithSelectedOptionsFromFilter:(RIFilter*)filter
{
    NSString* string = @"All";
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger filterIndex = indexPath.row;
    if (VALID_NOTEMPTY(self.categoriesArray, NSArray)) {
        filterIndex--;
    }
    
    if (-1 == filterIndex) {
        JACategoryFilterViewController* categoryFilterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryFilterViewController"];
        
        categoryFilterViewController.categoriesArray = self.categoriesArray;
        categoryFilterViewController.selectedCategory = self.selectedCategory;
        categoryFilterViewController.delegate = self;
        
        [self.navigationController pushViewController:categoryFilterViewController
                                             animated:YES];
    } else {
        RIFilter* filter = [self.filtersArray objectAtIndex:filterIndex];
        
        if ([filter.uid isEqualToString:@"price"]) {
            JAPriceFilterViewController* priceFilterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"priceFilterViewController"];
            
            priceFilterViewController.priceFilterOption = [filter.options firstObject];
            
            [self.navigationController pushViewController:priceFilterViewController
                                                 animated:YES];
        } else {
            JAGenericFilterViewController* genericFilterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"genericFilterViewController"];
            
            genericFilterViewController.filter = filter;
            
            [self.navigationController pushViewController:genericFilterViewController
                                                 animated:YES];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger filterIndex = indexPath.row;
    if (VALID_NOTEMPTY(self.categoriesArray, NSArray)) {
        filterIndex--;
    }
    
    if (-1 == filterIndex) {
        if (VALID_NOTEMPTY(self.selectedCategory, RICategory)) {
            return UITableViewCellEditingStyleDelete;
        }
    } else {
        RIFilter* filter = [self.filtersArray objectAtIndex:filterIndex];
        
        if ([filter.uid isEqualToString:@"price"]) {
            
            RIFilterOption* option = [filter.options firstObject];
            
            if (option.lowerValue != option.min || option.upperValue != option.max) {
                return UITableViewCellEditingStyleDelete;
            }
        } else {
            
            for (RIFilterOption* option in filter.options) {
                
                if (option.selected) {
                    return UITableViewCellEditingStyleDelete;
                }
            }
        }
    }
    
    return UITableViewCellEditingStyleNone;
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
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - JACategoryFilterViewControllerDelegate

- (void)categoriesFilterSelectedCategory:(RICategory *)category
{
    self.selectedCategory = category;
}


@end
