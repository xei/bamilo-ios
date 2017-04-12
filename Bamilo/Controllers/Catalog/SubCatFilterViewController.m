//
//  SubCatFilterViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SubCatFilterViewController.h"
#import "JAGenericFiltersView.h"
#import "OrangeButton.h"

@interface SubCatFilterViewController ()
@property (weak, nonatomic) IBOutlet UIView *filterViewContainer;
@property (weak, nonatomic) IBOutlet OrangeButton *submitButton;
@end

@implementation SubCatFilterViewController {
@private JAGenericFiltersView *filterView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.submitButton setTitle:STRING_OK forState:UIControlStateNormal];
    
    filterView = [[[NSBundle mainBundle] loadNibNamed:@"JAGenericFiltersView" owner:self options:nil] objectAtIndex:0];
    [filterView initializeWithFilter:self.subCatsFilter isLandscape:YES];
    
    filterView.frame = self.filterViewContainer.bounds;
    filterView.filtersViewDelegate = self;
    [self.filterViewContainer addSubview:filterView];
}


#pragma mark - JAFiltersViewDelegate
- (void)updatedValues {
    self.subCatsFilter = (SearchCategoryFilter *)filterView.filter;
}

#pragma override from BaseViewController
- (void)updateNavBar {
    self.navBarLayout.title = STRING_SUBCATEGORIES;
    self.navBarLayout.showBackButton = YES;
}

- (IBAction)submitButtonTapped:(id)sender {
    for(SearchFilterItemOption *catFilterOption in self.subCatsFilter.options) {
        if (catFilterOption.selected) {
            [self.navigationController popViewControllerAnimated:NO];
            [self.delegate submitSubCategoryFilterByUrlKey:catFilterOption.value];
        }
    }
}


@end
