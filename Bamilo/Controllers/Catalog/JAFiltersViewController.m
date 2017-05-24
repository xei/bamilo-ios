//
//  JAFiltersViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 05/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAFiltersViewController.h"
#import "JAFilterCell.h"
#import "JAGenericFiltersView.h"
#import "JAPriceFiltersView.h"
#import "SubCatFilterViewController.h"
#import "Bamilo-Swift.h"

@interface JAFiltersViewController () <UITableViewDataSource, UITableViewDelegate, JAFiltersViewDelegate, SubCatFilterViewControllerDelegate>

@property (nonatomic, strong) JAFiltersView* currentFilterView;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIButton* clearAllUIButton;
@property (nonatomic, weak) IBOutlet UIButton* applyUIButton;
@property (nonatomic, weak) IBOutlet UILabel* discountOnlyUILabel;
@property (weak, nonatomic) IBOutlet UISwitch *discountOnlyUISwitch;
@property (weak, nonatomic) IBOutlet UIView *currentFilterContainerView;
@property (nonatomic, strong) NSIndexPath* selectedIndexPath;
@property (weak, nonatomic) IBOutlet UIButton *subCatButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subCatButtonHeightConstraint;
@property (nonatomic) NSUInteger totalSelected;
@property (nonatomic) BOOL filterHasBeenChanged;
@end

@implementation JAFiltersViewController

const int subCatButtonVisibleHeight = 50;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBarLayout.title = STRING_FILTERS;
    self.navBarLayout.showBackButton = YES;
    [self selectIndex:0];
    [self updateTitle];
    
    self.discountOnlyUISwitch.enabled = YES;
    CatalogPriceFilterItem *priceFilter = (CatalogPriceFilterItem *)[self.filtersArray objectAtIndex:self.priceFilterIndex];
    self.discountOnlyUISwitch.on = priceFilter.discountOnly;
    
    [self.subCatButton applyStyle:kFontRegularName fontSize:11 color:[UIColor blackColor]];
    [self.subCatButton setTitle:STRING_SUBCATEGORIES forState:UIControlStateNormal];
    if (self.subCatsFilter && ((CatalogCategoryFilterItem *)self.subCatsFilter).options.count) {
        self.subCatButtonHeightConstraint.constant = subCatButtonVisibleHeight;
    } else{
        self.subCatButtonHeightConstraint.constant = 0;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification object:nil];
}


- (void)updateTitle {
    self.totalSelected = 0;
    for (BaseCatalogFilterItem* filter in self.filtersArray) {
        if ([filter isKindOfClass:[CatalogPriceFilterItem class]]) {
            CatalogPriceFilterItem *priceFilter = (CatalogPriceFilterItem*)filter;
            if (priceFilter.lowerValue > priceFilter.minPrice || priceFilter.upperValue < priceFilter.maxPrice || YES == priceFilter.discountOnly) {
                self.totalSelected++;
            }
        } else {
            for (CatalogFilterOption* option in ((CatalogFilterItem*)filter).options) {
                if (option.selected) {
                    self.totalSelected++;
                }
            }
        }
    }
    NSString* newTitle;
    if (0 == self.totalSelected) {
        newTitle = STRING_FILTERS;
    } else {
        newTitle = [[NSString stringWithFormat:@"%@ (%ld)", STRING_FILTERS, (long)self.totalSelected] numbersToPersian];
    }
    if (![newTitle isEqualToString:self.navBarLayout.title]) {
        
        //the title changed, force a reload
        self.navBarLayout.title = newTitle;
        //[self reloadNavBar];
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

    BOOL cellIsSelected = NO;
    if (indexPath.row == self.selectedIndexPath.row) {
        cellIsSelected = YES;
    }
    
    CGFloat margin = 16.0f;
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        margin = 32.0f;
    }
    [cell setupWithFilter:[self.filtersArray objectAtIndex:indexPath.row] cellIsSelected:cellIsSelected width:tableView.frame.size.width margin:margin];
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
    BaseCatalogFilterItem* filter = [self.filtersArray objectAtIndex:index];
    
    if ([filter isKindOfClass:[CatalogPriceFilterItem class]]) {
        self.currentFilterView = [[[NSBundle mainBundle] loadNibNamed:@"JAPriceFiltersView" owner:self options:nil] objectAtIndex:0];
        [(JAPriceFiltersView*)self.currentFilterView initializeWithPriceFilterOption:(CatalogPriceFilterItem*)filter];
        
    } else {
        self.currentFilterView = [[[NSBundle mainBundle] loadNibNamed:@"JAGenericFiltersView" owner:self options:nil] objectAtIndex:0];
        [(JAGenericFiltersView*) self.currentFilterView initializeWithFilter:(CatalogFilterItem*)filter isLandscape:YES];
        
    }
    
    self.currentFilterView.frame =  CGRectMake(self.view.bounds.origin.x,
                                               self.view.bounds.origin.y,
                                               self.currentFilterContainerView.frame.size.width,
                                               self.currentFilterContainerView.frame.size.height);
    
    self.currentFilterView.filtersViewDelegate = self;
    [self.currentFilterContainerView addSubview:self.currentFilterView];
}

- (IBAction)subCatButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"pushFilterToSubCat" sender:sender];
}

#pragma mark - JAFiltersViewDelegate
- (void)updatedValues {
    UITableViewRowAnimation animation = UITableViewRowAnimationAutomatic;
    BaseCatalogFilterItem *filter = [self.filtersArray objectAtIndex:self.selectedIndexPath.row];
    if ([filter isKindOfClass:[CatalogPriceFilterItem class]]) {
        animation = UITableViewRowAnimationNone;
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:animation];
    [self updateTitle];
    
    self.filterHasBeenChanged = YES;
}

#pragma Button Logic
- (IBAction)clearAllFilters {
    for (BaseCatalogFilterItem* filter in self.filtersArray) {
        if ([filter isKindOfClass:[CatalogPriceFilterItem class]]) {
            ((CatalogPriceFilterItem*)filter).lowerValue = ((CatalogPriceFilterItem*)filter).minPrice;
            ((CatalogPriceFilterItem*)filter).upperValue = ((CatalogPriceFilterItem*)filter).maxPrice;
            ((CatalogPriceFilterItem*)filter).discountOnly = NO;
        } else {
            for (CatalogFilterOption* option in ((CatalogFilterItem *)filter).options) {
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
    [self.view endEditing:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatedFilters:)]) {
        [self.navigationController popViewControllerAnimated: self.totalSelected == 0 || !self.filterHasBeenChanged];
        [self.delegate updatedFilters:self.filtersArray];
    }
}


- (IBAction)discountOnlySwitch:(UISwitch *)sender {
    if (self.priceFilterIndex && self.filtersArray.count) {
        ((CatalogPriceFilterItem *)[self.filtersArray objectAtIndex:self.priceFilterIndex]).discountOnly = sender.on;
    }
}

#pragma Keyboard delegate notification 

- (void) keyboardWillShow:(NSNotification *)notification {
    
    if ([self.currentFilterView isKindOfClass: JAPriceFiltersView.class]) {
        CGFloat keyboardHeight = [self getKeyboardHeight:notification];
        CGFloat priceFilterCenteredContentHeight = ((JAPriceFiltersView *)self.currentFilterView).centeredContentHeightConstraint.constant;
        
        CGFloat properMaxKeyboardHeight = self.applyUIButton.frame.size.height + (self.currentFilterContainerView.frame.size.height / 2) - (priceFilterCenteredContentHeight/2);
        
        if (keyboardHeight > properMaxKeyboardHeight) {
            [UIView animateWithDuration:0.5 animations:^{
                ((JAPriceFiltersView *)self.currentFilterView).contentViewVerticalCenterContstraint.constant = keyboardHeight - properMaxKeyboardHeight;
                [self.currentFilterContainerView layoutIfNeeded];
            } completion: nil];
            
        }
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    if ([self.currentFilterView isKindOfClass: JAPriceFiltersView.class] && ((JAPriceFiltersView *)self.currentFilterView).contentViewVerticalCenterContstraint.constant != 0) {
        [UIView animateWithDuration:0.5 animations:^{
            ((JAPriceFiltersView *)self.currentFilterView).contentViewVerticalCenterContstraint.constant = 0;
            [self.currentFilterContainerView layoutIfNeeded];
        } completion: nil];
    }
}


#pragma mark - helper functions
- (CGFloat)getKeyboardHeight:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    
    if (self.view.frame.size.width == kbSize.height) {
        height = kbSize.width;
    }
    
    return height;
}

#pragma mark - prepareForSegue 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"pushFilterToSubCat"]) {
        SubCatFilterViewController *subCatViewCtrl = (SubCatFilterViewController *)segue.destinationViewController;
        subCatViewCtrl.subCatsFilter = self.subCatsFilter;
        subCatViewCtrl.delegate = self;
    }
}


#pragma mark - SubCatFilterViewControllerDelegate
- (void)submitSubCategoryFilterByUrlKey:(NSString *)urlKey {
    [self.navigationController popViewControllerAnimated:NO];
    [self.delegate subCategorySelected:urlKey];
}

@end
