//
//  BaseSearchFilterItem.h
//  Bamilo
//
//  Created by Ali saiedifar on 3/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"



@interface BaseSearchFilterItem : BaseModel
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *filterSeparator;
@property (nonatomic) BOOL  multi;

+ (NSString *)urlWithFiltersArray:(NSArray<BaseSearchFilterItem*>*)filtersArray;
@end
