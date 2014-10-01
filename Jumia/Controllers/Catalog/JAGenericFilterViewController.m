//
//  JAGenericFilterViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 14/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAGenericFilterViewController.h"
#import "JAColorView.h"
#import "JAColorFilterCell.h"

@interface JAGenericFilterViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSMutableArray* selectedIndexes;

@end

@implementation JAGenericFilterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(VALID_NOTEMPTY(self.filter, RIFilter))
    {
        self.screenName =  [NSString stringWithFormat:@"%@Filter", self.filter.name];
    }
    
    self.navBarLayout.title = self.filter.name;
    self.navBarLayout.backButtonTitle = STRING_FILTERS;
    self.navBarLayout.showDoneButton = YES;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //inside this screen, we use self.selectedIndexes to indicate whether or not a filter is selected
    //instead of using the filter real state. This way, we can cancel the changes by simply poping the VC
    //without saving this selection states into the real filter options, which only happens once the DONE
    // button is pressed.
    self.selectedIndexes = [NSMutableArray new];
    for (RIFilterOption* filterOption in self.filter.options) {
        [self.selectedIndexes addObject:[NSNumber numberWithBool:filterOption.selected]];
    }
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneButtonPressed)
                                                 name:kDidPressDoneNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Button Actions

- (void)doneButtonPressed
{
    //save selection in filter
    
    for (int i = 0; i < self.selectedIndexes.count; i++) {
        
        NSNumber *selectionNumber = [self.selectedIndexes objectAtIndex:i];
        
        RIFilterOption* filterOption = [self.filter.options objectAtIndex:i];
        
        filterOption.selected = [selectionNumber boolValue];
    }
}

#pragma mark - UITableView

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filter.options.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"filterCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([self.filter.uid isEqualToString:@"color_family"]) {

        if (ISEMPTY(cell)) {
            cell = [[JAColorFilterCell alloc] initWithReuseIdentifier:cellIdentifier];
            
            UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(50.0f, 43.0f, 280.0f, 1.0f)];
            separator.backgroundColor = UIColorFromRGB(0xcccccc);
            [cell addSubview:separator];
        }
        
        RIFilterOption* filterOption = [self.filter.options objectAtIndex:indexPath.row];
        [(JAColorFilterCell*)cell colorTitleLabel].text = filterOption.name;
        
        if (filterOption.colorHexValue) {
            [[(JAColorFilterCell*)cell colorView] setColorWithHexString:filterOption.colorHexValue];
        }
        
    } else {
    
        if (ISEMPTY(cell)) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectionCheckmark"]];
            
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
            cell.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
            
            UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, 320.0f, 1.0f)];
            separator.backgroundColor = UIColorFromRGB(0xcccccc);
            [cell addSubview:separator];
        }
        
        RIFilterOption* filterOption = [self.filter.options objectAtIndex:indexPath.row];
        cell.textLabel.text = filterOption.name;
    
    }
    
    NSNumber* selected = [self.selectedIndexes objectAtIndex:indexPath.row];
    cell.accessoryView.hidden = ![selected boolValue];

    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber* selected = [self.selectedIndexes objectAtIndex:indexPath.row];
    if (!self.filter.multi) {
        //if this filter doesn't support multi selection, unselect all other indexes

        NSMutableArray* newSelectedIndexes = [NSMutableArray new];
        for (int i = 0; i < self.selectedIndexes.count; i++) {
            
            NSNumber* selection;
            
            if (i == indexPath.row) {
                selection = [NSNumber numberWithBool:![selected boolValue]];
            } else {
                selection = [NSNumber numberWithInt:NO];
            }
            
            [newSelectedIndexes addObject:selection];
        }
        self.selectedIndexes = newSelectedIndexes;
    } else {
        NSNumber* newSelection = [NSNumber numberWithBool:![selected boolValue]];
        [self.selectedIndexes replaceObjectAtIndex:indexPath.row withObject:newSelection];
        
    }
    
    [tableView reloadData];
}

@end
