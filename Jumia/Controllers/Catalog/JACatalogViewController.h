//
//  JACatalogViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JACatalogTopView.h"
#import "RICategory.h"
#import "JAMainFiltersViewController.h"
#import "JAPDVViewController.h"
#import "JAUndefinedSearchView.h"
#import "JASortingView.h"

@interface JACatalogViewController : JABaseViewController
<
    JASortingViewDelegate,
    JACatalogTopViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    JAMainFiltersViewControllerDelegate,
    JAUndefinedSearchViewDelegate
>

@property (nonatomic, strong)RICategory* category;
@property (nonatomic, strong)NSString* categoryId;
@property (nonatomic, strong)NSString* categoryName;
@property (nonatomic, strong)NSString* catalogUrl;
@property (nonatomic, strong)NSString* searchString;
@property (nonatomic, strong)NSString* filterPush;
@property (nonatomic, strong)NSNumber* sortingMethodFromPush;
@property (assign, nonatomic)BOOL forceShowBackButton;

@property (nonatomic, strong) NSString* teaserTrackingInfo;

@end
