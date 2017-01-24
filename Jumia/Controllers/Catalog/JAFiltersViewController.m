//
//  JAFiltersViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 05/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAFiltersViewController.h"
#import "JAFilterCell.h"
#import "RIFilter.h"
#import "JAGenericFiltersView.h"
#import "JAPriceFiltersView.h"
#import "NSString+Style.h"

@interface JAFiltersViewController () <UITableViewDataSource, UITableViewDelegate, JAFiltersViewDelegate>


@property (nonatomic, strong) JAFiltersView* currentFilterView;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIButton* clearAllUIButton;
@property (nonatomic, weak) IBOutlet UIButton* applyUIButton;
@property (nonatomic, weak) IBOutlet UILabel* discountOnlyUILabel;
@property (weak, nonatomic) IBOutlet UISwitch *discountOnlyUISwitch;
@property (weak, nonatomic) IBOutlet UIView *currentFilterContainerView;

@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@property (nonatomic) NSUInteger avaiablePriceFilterIndex;

@end

@implementation JAFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.title = STRING_FILTERS;
    self.navBarLayout.showBackButton = YES;
    [self selectIndex:0];
    [self updateTitle];
    
    // Get the index of price filter in filterArray
    [self.filtersArray enumerateObjectsUsingBlock: ^(RIFilter *filter, NSUInteger index, BOOL *stop) {
        if ([filter.uid isEqualToString:@"price"]) {
            self.avaiablePriceFilterIndex = index;
            *stop = YES;
        }
     }];
    
    if (self.avaiablePriceFilterIndex) {
        self.discountOnlyUISwitch.enabled = YES;
        RIFilter *priceFilter = [self.filtersArray objectAtIndex:self.avaiablePriceFilterIndex];
        RIFilterOption *priceFilterOption = [priceFilter.options firstObject];
        self.discountOnlyUISwitch.on = priceFilterOption.discountOnly;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateTitle {
    NSInteger totalSelected = 0;
    for (RIFilter* filter in self.filtersArray) {
        if ([filter.uid isEqualToString:@"price"]) {
            RIFilterOption* option = [filter.options firstObject];
            if (option.lowerValue > option.min || option.upperValue < option.max || YES == option.discountOnly) {
                totalSelected++;
            }
        } else {
            for (RIFilterOption* option in filter.options) {
                if (option.selected) {
                    totalSelected++;
                }
            }
        }
    }
    NSString* newTitle;
    if (0 == totalSelected) {
        newTitle = STRING_FILTERS;
    } else {
        newTitle = [[NSString stringWithFormat:@"%@ (%ld)", STRING_FILTERS, (long)totalSelected] numbersToPersian];
    }
    if (![newTitle isEqualToString:self.navBarLayout.title]) {
        //the title changed, force a reload
        self.navBarLayout.title = newTitle;
        [self reloadNavBar];
    }
}

- (void)viewWillLayoutSubviews {
    [self.currentFilterView reload];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filtersArray.count;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [JAFilterCell height];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"filterCell";
    
    JAFilterCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[JAFilterCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    RIFilter* filter = [self.filtersArray objectAtIndex:indexPath.row];
    
    BOOL cellIsSelected = NO;
    if (indexPath.row == self.selectedIndexPath.row) {
        cellIsSelected = YES;
    }
    
    CGFloat margin = 16.0f;
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        margin = 32.0f;
    }
    [cell setupWithFilter:filter cellIsSelected:cellIsSelected width:tableView.frame.size.width margin:margin];
    cell.clickView.tag = indexPath.row;
    [cell.clickView addTarget:self action:@selector(cellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)cellWasPressed:(UIControl*)sender {
    [self selectIndex:sender.tag];
}

- (void)selectIndex:(NSInteger)index {
    
    NSIndexPath* oldSelectedIndexPath = self.selectedIndexPath;
    self.selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    if (oldSelectedIndexPath && oldSelectedIndexPath.row == self.selectedIndexPath.row) {
        return; //DO NOTHING
    }
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:oldSelectedIndexPath, self.selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.currentFilterView removeFromSuperview];
    RIFilter* filter = [self.filtersArray objectAtIndex:index];
    
    if ([filter.uid isEqualToString:@"price"]) {
        
        self.currentFilterView = [[[NSBundle mainBundle] loadNibNamed:@"JAPriceFiltersView" owner:self options:nil] objectAtIndex:0];
        [(JAPriceFiltersView*)self.currentFilterView initializeWithPriceFilterOption:[filter.options firstObject]];
        
    } else {
        
        self.currentFilterView = [[[NSBundle mainBundle] loadNibNamed:@"JAGenericFiltersView" owner:self options:nil] objectAtIndex:0];
        [(JAGenericFiltersView*) self.currentFilterView initializeWithFilter:filter isLandscape:YES];
        
    }
    
    self.currentFilterView.frame =  CGRectMake(self.view.bounds.origin.x,
                                               self.view.bounds.origin.y,
                                               self.currentFilterContainerView.frame.size.width,
                                               self.currentFilterContainerView.frame.size.height);
    
    self.currentFilterView.filtersViewDelegate = self;
    [self.currentFilterContainerView addSubview:self.currentFilterView];
}


#pragma mark - JAFiltersViewDelegate

- (void)updatedValues {
    UITableViewRowAnimation animation = UITableViewRowAnimationAutomatic;
    RIFilter* filter = [self.filtersArray objectAtIndex:self.selectedIndexPath.row];
    if ([filter.uid isEqualToString:@"price"]) {
        animation = UITableViewRowAnimationNone;
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:animation];
    [self updateTitle];
}

#pragma Button Logic

- (IBAction)clearAllFilters {
    for (RIFilter* filter in self.filtersArray) {
        if ([filter.uid isEqualToString:@"price"]) {
            RIFilterOption* option = [filter.options firstObject];
            option.lowerValue = option.min;
            option.upperValue = option.max;
            option.discountOnly = NO;
        } else {
            for (RIFilterOption* option in filter.options) {
                option.selected = NO;
            }
        }
    }
    [self.tableView reloadData];
    [self updateTitle];
    NSInteger indexToReload = self.selectedIndexPath.row;
    self.selectedIndexPath = nil;
    [self selectIndex:indexToReload];
}

- (IBAction) applyButtonPressed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatedFilters:)]) {
        [self.navigationController popViewControllerAnimated:true];
        [self.delegate updatedFilters:self.filtersArray];
    }
}


- (IBAction)discountOnlySwitch:(UISwitch *)sender {
    if (self.avaiablePriceFilterIndex && self.filtersArray.count) {
        ((RIFilterOption *) ([[(RIFilter *) ([self.filtersArray objectAtIndex:self.avaiablePriceFilterIndex]) options] firstObject])).discountOnly = sender.on;
    }
}


@end
