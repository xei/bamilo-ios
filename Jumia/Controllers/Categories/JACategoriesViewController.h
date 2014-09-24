//
//  JACategoriesViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 19/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RICategory.h"

@interface JACategoriesViewController : JABaseViewController
<
    UITableViewDelegate,
    UITableViewDataSource,
    JANoConnectionViewDelegate
>

@property (nonatomic, strong) RICategory* currentCategory;
@property (nonatomic, strong) NSString* backTitle;

@end
