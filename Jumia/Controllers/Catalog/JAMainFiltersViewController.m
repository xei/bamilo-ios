//
//  JAMainFiltersViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMainFiltersViewController.h"
#import "JAPriceFilterViewController.h"
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        cell.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
        
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
        cell.detailTextLabel.textColor = UIColorFromRGB(0x4e4e4e);
    }

    RIFilter* filter = [self.filtersArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = filter.name;
    
    cell.detailTextLabel.text = @"All";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RIFilter* filter = [self.filtersArray objectAtIndex:indexPath.row];
    
    if ([filter.uid isEqualToString:@"color_family"]) {
    
    } else if ([filter.uid isEqualToString:@"price"]) {
        JAPriceFilterViewController* priceFilterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"priceFilterViewController"];
        
        priceFilterViewController.priceFilterOption = [filter.options firstObject];
        
        [self.navigationController pushViewController:priceFilterViewController
                                             animated:YES];
    }
}

@end
