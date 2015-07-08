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
    
    NSNumber* selected = [self.selectedIndexes objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([@"color_family" isEqualToString:self.filter.uid]) {
        
        if (ISEMPTY(cell)) {
            cell = [[JAColorFilterCell alloc] initWithReuseIdentifier:cellIdentifier
                                                          isLandscape:self.isLandscape
                                                                frame:CGRectMake(0.0f,
                                                                                 0.0f,
                                                                                 tableView.frame.size.width,
                                                                                 44.0f)];
            CGFloat separatorX = 50.0f;
            if (self.isLandscape) {
                separatorX += 20.0f;
            }
            UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(separatorX, 43.0f, self.tableView.frame.size.width - 50.0f, 1.0f)];
            separator.backgroundColor = UIColorFromRGB(0xcccccc);
            [cell addSubview:separator];
            if (RI_IS_RTL) {
                [cell flipAllSubviews];
            }
        }
        
        RIFilterOption* filterOption = [self.filter.options objectAtIndex:indexPath.row];
        [(JAColorFilterCell*)cell colorTitleLabel].text = filterOption.name;
        
        if (filterOption.colorHexValue) {
            [[(JAColorFilterCell*)cell colorView] setColorWithHexString:filterOption.colorHexValue];
        }
        
        [(JAColorFilterCell*)cell customAccessoryView].hidden = ![selected boolValue];
        
        //remove the clickable view
        for (UIView* view in cell.subviews) {
            if ([view isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                [view removeFromSuperview];
            } else {
                for (UIView* subview in view.subviews) {
                    if ([subview isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                        [subview removeFromSuperview];
                    }
                }
            }
        }
        //add the new clickable view
        JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 44.0f)];
        clickView.tag = indexPath.row;
        [clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:clickView];
        
    } else {
        
        if (ISEMPTY(cell)) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        //remove the clickable view
        for (UIView* view in cell.subviews) {
            if ([view isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                [view removeFromSuperview];
            } else {
                for (UIView* subview in view.subviews) {
                    if ([subview isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                        [subview removeFromSuperview];
                    }
                }
            }
        }
        //add the new clickable view
        JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tableView.frame.size.width, 44.0f)];
        clickView.tag = indexPath.row;
        [clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:clickView];
        
        CGFloat startingX = 0.0;
        if (self.isLandscape) {
            startingX = 20.0f;
        }
        CGFloat margin = 12.0f;
        
        UIView* separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                     clickView.frame.size.height - 1,
                                                                     tableView.frame.size.width,
                                                                     1.0f)];
        separator.backgroundColor = UIColorFromRGB(0xcccccc);
        [clickView addSubview:separator];
        
        UIImage* customAccessoryIcon = [UIImage imageNamed:@"selectionCheckmark"];
        UIImageView* customAccessoryView = [[UIImageView alloc] initWithImage:customAccessoryIcon];
        customAccessoryView.frame = CGRectMake(clickView.frame.size.width - margin - customAccessoryIcon.size.width,
                                               (clickView.frame.size.height - customAccessoryIcon.size.height) / 2,
                                               customAccessoryIcon.size.width,
                                               customAccessoryIcon.size.height);
        customAccessoryView.hidden = ![selected boolValue];
        [clickView addSubview:customAccessoryView];
        
        CGFloat remainingWidth = tableView.frame.size.width - customAccessoryView.frame.size.width - margin*2;
        UILabel* customTextLabel = [UILabel new];
        customTextLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
        customTextLabel.textColor = UIColorFromRGB(0x4e4e4e);
        customTextLabel.frame = CGRectMake(startingX,
                                           0.0f,
                                           remainingWidth,
                                           clickView.frame.size.height);
        [clickView addSubview:customTextLabel];
        
        RIFilterOption* filterOption = [self.filter.options objectAtIndex:indexPath.row];
        customTextLabel.text = filterOption.name;
        
        if (RI_IS_RTL) {
            [clickView flipSubviewAlignments];
            [clickView flipSubviewPositions];
        }
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
    if (YES == self.shouldAutosave) {
        [self saveOptions];
    }
}


@end
