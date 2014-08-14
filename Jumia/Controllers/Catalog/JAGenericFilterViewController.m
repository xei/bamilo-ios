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

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = UIColorFromRGB(0xcccccc);
    self.tableView.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
    
    //inside this screen, we use self.selectedIndexes to indicate whether or not a filter is selected
    //instead of using the filter real state. This way, we can cancel the changes by simply poping the VC
    //without saving this selection states into the real filter options, which only happens once the DONE
    // button is pressed.
    self.selectedIndexes = [NSMutableArray new];
    for (RIFilterOption* filterOption in self.filter.options) {
        [self.selectedIndexes addObject:[NSNumber numberWithBool:filterOption.selected]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *nameDic = [NSMutableDictionary dictionary];
    [nameDic addEntriesFromDictionary:@{@"name": self.filter.name}];
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kShowSpecificFilterNavNofication
                                      object:self
                                    userInfo:nameDic];
}

#pragma mark - UITableView

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
    NSNumber* newSelection = [NSNumber numberWithBool:![selected boolValue]];
    [self.selectedIndexes replaceObjectAtIndex:indexPath.row withObject:newSelection];
    
    [tableView reloadData];
}

@end
