//
//  JACategoryFilterViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 18/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACategoryFilterViewController.h"
#import "RICategory.h"

@interface JACategoryFilterViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign)NSInteger selectedIndex;

@end

@implementation JACategoryFilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navBarLayout.title = STRING_CATEGORIES;
    self.navBarLayout.backButtonTitle = STRING_FILTERS;
    self.navBarLayout.showDoneButton = YES;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //inside this screen, we use self.selectedIndex to indicate whether or not a category is selected
    //instead of changing the real state right away. This way, we can cancel the changes by simply poping
    //the VC without saving this selection states into the real category, which only happens once the DONE
    // button is pressed.
    self.selectedIndex = NSIntegerMax;
    for (int i = 0; i < self.categoriesArray.count; i++) {
        RICategory* category = [self.categoriesArray objectAtIndex:i];
        if ([category.name isEqualToString:self.selectedCategory.name]) {
            self.selectedIndex = i;
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneButtonPressed)
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
    if (self.selectedIndex != NSIntegerMax) {
        self.selectedCategory = [self.categoriesArray objectAtIndex:self.selectedIndex];
    } else {
        self.selectedCategory = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(categoriesFilterSelectedCategory:)]) {
        [self.delegate categoriesFilterSelectedCategory:self.selectedCategory];
    }
}

#pragma mark - UITableView

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categoriesArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"categoryCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
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
    
    RICategory* category = [self.categoriesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = category.name;

    if (indexPath.row == self.selectedIndex) {
        cell.accessoryView.hidden = NO;
    } else {
        cell.accessoryView.hidden = YES;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.selectedIndex) {
        self.selectedIndex = NSIntegerMax;
    } else {
        self.selectedIndex = indexPath.row;
    }
    
    [tableView reloadData];
}

@end
