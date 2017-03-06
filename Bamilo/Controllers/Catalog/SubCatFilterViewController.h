//
//  SubCatFilterViewController.h
//  Bamilo
//
//  Created by Ali saiedifar on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SearchCategoryFilter.h"
#import "JAFiltersView.h"

@protocol SubCatFilterViewControllerDelegate
- (void)submitSubCategoryFilterByUrlKey: (NSString*)urlKey;
@end

@interface SubCatFilterViewController : BaseViewController <JAFiltersViewDelegate>
@property (nonatomic, strong) SearchCategoryFilter *subCatsFilter;
@property (nonatomic, weak) id<SubCatFilterViewControllerDelegate>delegate;
@end
