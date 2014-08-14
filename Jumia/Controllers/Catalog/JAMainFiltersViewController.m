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
    
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filtersArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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

    RIFilter* filter = [self.filtersArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = filter.name;
    
    cell.detailTextLabel.text = [self stringWithSelectedOptionsFromFilter:filter];
    
    return cell;
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
    RIFilter* filter = [self.filtersArray objectAtIndex:indexPath.row];
    
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

@end
