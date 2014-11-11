//
//  JACategoryFiltersView.m
//  Jumia
//
//  Created by Telmo Pinto on 11/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACategoryFiltersView.h"
#import "RICategory.h"
#import "JAClickableView.h"

@interface JACategoryFiltersView()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign)NSInteger selectedIndex;

@property (nonatomic, strong)NSArray* categoriesArray;
@property (nonatomic, strong)RICategory* selectedCategory;

@end

@implementation JACategoryFiltersView

- (void)initializeWithCategories:(NSArray*)categories
                selectedCategory:(RICategory*)selectedCategory
{
    self.selectedCategory = selectedCategory;
    self.categoriesArray = categories;
    
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

- (void)saveOptions
{
    if (self.selectedIndex != NSIntegerMax) {
        self.selectedCategory = [self.categoriesArray objectAtIndex:self.selectedIndex];
    } else {
        self.selectedCategory = nil;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedCategory:)]) {
        [self.delegate selectedCategory:self.selectedCategory];
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
    
    //remove the clickable view
    for (UIView* view in cell.subviews) {
        if ([view isKindOfClass:[JAClickableView class]]) {
            [view removeFromSuperview];
        }
    }
    //add the new clickable view
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 44.0f)];
    clickView.tag = indexPath.row;
    [clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:clickView];
    
    return cell;
    
}

- (void)cellWasPressed:(UIControl*)sender
{
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
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
