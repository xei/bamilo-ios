//
//  JAGenericFiltersView.m
//  Jumia
//
//  Created by Telmo Pinto on 11/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAGenericFiltersView.h"
#import "JAColorFilterCell.h"
#import "JAClickableView.h"

@interface JAGenericFiltersView()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSMutableArray* selectedIndexes;

@property (nonatomic, strong)RIFilter* filter;
@property (nonatomic, assign)BOOL isLandscape;

@end

@implementation JAGenericFiltersView


- (void)initializeWithFilter:(RIFilter*)filter
                 isLandscape:(BOOL)isLandscape;
{
    self.filter = filter;
    self.isLandscape = isLandscape;
    
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
}

- (void)saveOptions
{
    //save selection in filter
    
    for (int i = 0; i < self.selectedIndexes.count; i++) {
        
        NSNumber *selectionNumber = [self.selectedIndexes objectAtIndex:i];
        
        RIFilterOption* filterOption = [self.filter.options objectAtIndex:i];
        
        filterOption.selected = [selectionNumber boolValue];
    }
    
    [super saveOptions];
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
    if ([@"color_family" isEqualToString:self.filter.uid]) {
        
        if (ISEMPTY(cell)) {
            cell = [[JAColorFilterCell alloc] initWithReuseIdentifier:cellIdentifier isLandscape:self.isLandscape];
        }
        
        for (UIView* subview in cell.subviews) {
            if (subview.tag == -1) {
                [subview removeFromSuperview];
            }
        }
        CGFloat separatorX = 50.0f;
        if (self.isLandscape) {
            separatorX += 20.0f;
        }
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(separatorX, 43.0f, self.tableView.frame.size.width - 50.0f, 1.0f)];
        separator.tag = -1;
        separator.backgroundColor = UIColorFromRGB(0xcccccc);
        [cell addSubview:separator];
        
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
            cell.indentationWidth = 20.0f;
        }
        
        if (self.isLandscape) {
            cell.indentationLevel = 1;
        } else {
            cell.indentationLevel = 0;
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
        
        RIFilterOption* filterOption = [self.filter.options objectAtIndex:indexPath.row];
        cell.textLabel.text = filterOption.name;
        
    }
    
    NSNumber* selected = [self.selectedIndexes objectAtIndex:indexPath.row];
    cell.accessoryView.hidden = ![selected boolValue];
    
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
    if (YES == self.shouldAutosave) {
        [self saveOptions];
    }
}


@end
