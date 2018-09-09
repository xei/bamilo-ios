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
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@end

@implementation SubCatFilterViewController {
@private JAGenericFiltersView *filterView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.submitButton setTitle:STRING_OK forState:UIControlStateNormal];
    
    filterView = [[[NSBundle mainBundle] loadNibNamed:@"JAGenericFiltersView" owner:self options:nil] objectAtIndex:0];
    [filterView initializeWithFilter:[self createCatalogCategoryFilterItemWithOptions:self.subCatsFilters] isLandscape:YES];
    
    filterView.frame = self.filterViewContainer.bounds;
    filterView.filtersViewDelegate = self;
    [self.filterViewContainer addSubview:filterView];
    
    [self.submitButton applyStyle:kFontRegularName fontSize:13 color: [UIColor whiteColor]];
    [self.submitButton setTitle:STRING_OK forState:UIControlStateNormal];
    [self.submitButton setBackgroundColor:[Theme color:kColorDarkGreen]];
}

- (CatalogFilterItem *)createCatalogCategoryFilterItemWithOptions:(NSArray<CatalogCategoryFilterOption*> *)options {
    CatalogFilterItem *catalogFilter = [CatalogFilterItem new];
    catalogFilter.multi = NO;
    catalogFilter.options = options;
    catalogFilter.name = STRING_SUBCATEGORIES;
    return catalogFilter;
}


#pragma mark - JAFiltersViewDelegate
- (void)updatedValues {
    self.subCatsFilters = ((CatalogFilterItem *)[filterView getFilter]).options;
}

- (IBAction)submitButtonTapped:(id)sender {
    for(CatalogFilterOption *catFilterOption in self.subCatsFilters) {
        if (catFilterOption.selected) {
            
            [TrackerManager postEventWithSelector:[EventSelectors itemTappedSelector] attributes: [EventAttributes itemTappedWithCategoryEvent:[self getScreenName] screenName:[self getScreenName] labelEvent: catFilterOption.name]];
            
            [self.navigationController popViewControllerAnimated:NO];
            [self.delegate submitSubCategoryFilterByUrlKey:catFilterOption.value];
        }
    }
}

- (NSString *)getScreenName {
    return @"SubCategoryFilterView";
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_SUBCATEGORIES;
}
@end
