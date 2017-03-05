//
//  SearchFilterItemOption.h
//  Bamilo
//
//  Created by Ali saiedifar on 3/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
@protocol SearchFilterItemOption;

@interface SearchFilterItemOption : BaseModel
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, copy)   NSString *value;
@property (nonatomic, assign) NSNumber *average;
@property (nonatomic, assign) NSNumber *productsCount;

//for color filter options
@property (nonatomic, copy)   NSString *colorHexValue;
@property (nonatomic, copy)   NSString *colorImageUrl;

//current state of filter option
@property (nonatomic, assign) BOOL selected;
@end
