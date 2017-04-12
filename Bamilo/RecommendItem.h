//
//  RecommendItem.h
//  Bamilo
//
//  Created by Ali saiedifar on 4/10/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import <EmarsysPredictSDK/EmarsysPredictSDK.h>

@interface RecommendItem : BaseModel

+ (RecommendItem *)instanceWithEMRecommendationItem:(EMRecommendationItem *)item;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *brandName;
@property (nonatomic, copy) NSString *categoryPath;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, copy) NSString *sku;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *dicountedPrice;
@property (nonatomic, readonly) NSString *formattedPrice;
@property (nonatomic, readonly) NSString *formattedDiscountedPrice;

@end
