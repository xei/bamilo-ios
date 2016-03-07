//
//  JAGenericFiltersView.m
//  Jumia
//
//  Created by Telmo Pinto on 11/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAGenericFiltersView.h"
#import "JAColorFilterCell.h"
#import "JARatingFilterCell.h"
#import "JATextFilterCell.h"
#import "JAClickableView.h"
#import "JAProductInfoRatingLine.h"

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
    [self.tableView registerClass:[JAColorFilterCell class] forCellReuseIdentifier:@"JAColorFilterCell"];
    [self.tableView registerClass:[JARatingFilterCell class] forCellReuseIdentifier:@"JARatingFilterCell"];
    [self.tableView registerClass:[JATextFilterCell class] forCellReuseIdentifier:@"JATextFilterCell"];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JAColorFilterCell height];
}

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
    NSString *cellIdentifier = @"JATextFilterCell";
    
    NSNumber* selected = [self.selectedIndexes objectAtIndex:indexPath.row];
    
    UITableViewCell* cell ;
    if ([@"color_family" isEqualToString:self.filter.uid]) {
        cellIdentifier = @"JAColorFilterCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        if (ISEMPTY(cell)) {
            cell = [[JAColorFilterCell alloc] initWithReuseIdentifier:cellIdentifier
                                                          isLandscape:self.isLandscape
                                                                frame:CGRectMake(0.0f,
                                                                                 0.0f,
                                                                                 tableView.frame.size.width,
                                                                                 [JAColorFilterCell height])];
        } else {
            [(JAColorFilterCell*)cell setupIsLandscape:self.isLandscape];
        }
        
        
        [(JAColorFilterCell*)cell setFilterOption:[self.filter.options objectAtIndex:indexPath.row]];
        [(JAColorFilterCell*)cell customAccessoryView].hidden = ![selected boolValue];
        
        [(JAColorFilterCell*)cell clickableView].tag = indexPath.row;
        [[(JAColorFilterCell*)cell clickableView] addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];

    } else if ([@"rating" isEqualToString:self.filter.uid]) {
        cellIdentifier = @"JARatingFilterCell";
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (ISEMPTY(cell)) {
            cell = [[JARatingFilterCell alloc] initWithReuseIdentifier:cellIdentifier
                                                           isLandscape:self.isLandscape
                                                                 frame:CGRectMake(0.0f,
                                                                                  0.0f,
                                                                                  tableView.frame.size.width,
                                                                                  [JAColorFilterCell height])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        RIFilterOption* filterOption = [self.filter.options objectAtIndex:indexPath.row];
        [(JARatingFilterCell*)cell setFilterOption:filterOption];
        [(JARatingFilterCell*)cell setupIsLandscape:self.isLandscape];
    } else {
        
        if (ISEMPTY(cell)) {
            cell = [[JATextFilterCell alloc] initWithReuseIdentifier:cellIdentifier
                                                         isLandscape:self.isLandscape
                                                               frame:CGRectMake(0.0f,
                                                                                0.0f,
                                                                                tableView.frame.size.width,
                                                                                [JAColorFilterCell height])];

            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [(JATextFilterCell*)cell clickableView].tag = indexPath.row;
        [[(JATextFilterCell*)cell clickableView] addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        [(JATextFilterCell*)cell setFilterOption:[self.filter.options objectAtIndex:indexPath.row]];
        [(JATextFilterCell*)cell setupIsLandscape:self.isLandscape];
    }
    
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
    [self saveOptions];
}

- (void)reload
{
    [self.tableView reloadData];
}


@end
