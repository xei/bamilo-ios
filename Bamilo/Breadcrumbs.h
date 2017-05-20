//
//  BreadCrumbs.h
//  Bamilo
//
//  Created by Ali Saeedifar on 4/19/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "BreadcrumbItem.h"

@interface Breadcrumbs : BaseModel
@property (nonatomic, strong) NSArray<BreadcrumbItem> *items;
@property (nonatomic, readonly) NSString *fullPath;
@end
