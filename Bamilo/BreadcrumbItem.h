//
//  BreadcrumbItem.h
//  Bamilo
//
//  Created by Ali Saeedifar on 4/19/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"

@protocol BreadcrumbItem;

@interface BreadcrumbItem : BaseModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;

@end
