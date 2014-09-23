//
//  JACatalogViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAPickerScrollView.h"
#import "RICategory.h"
#import "JAMainFiltersViewController.h"
#import "JAPDVViewController.h"
#import "JAUndefinedSearchView.h"

@interface JACatalogViewController : JABaseViewController
<
    JAPickerScrollViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    JAMainFiltersViewControllerDelegate,
    JAPDVViewControllerDelegate,
    JAUndefinedSearchViewDelegate,
    JANoConnectionViewDelegate
>

@property (nonatomic, strong)RICategory* category;
@property (nonatomic, strong)NSString* catalogUrl;
@property (nonatomic, strong) NSString *searchString;
@property (assign, nonatomic) BOOL forceShowBackButton;

@end
