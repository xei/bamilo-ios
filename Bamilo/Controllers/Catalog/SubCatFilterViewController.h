//
//  SubCatFilterViewController.h
//  Bamilo
//
//  Created by Ali Saeedifar on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
//#import "SearchCategoryFilter.h"
#import "Bamilo-Swift.h"
#import "JAFiltersView.h"
#import "Bamilo-Swift.h"

@protocol SubCatFilterViewControllerDelegate
- (void)submitSubCategoryFilterByUrlKey: (NSString*)urlKey;
@end

@interface SubCatFilterViewController : BaseViewController <JAFiltersViewDelegate>
@property (nonatomic, strong) NSArray *subCatsFilters;
@property (nonatomic, weak) id<SubCatFilterViewControllerDelegate>delegate;
@end
