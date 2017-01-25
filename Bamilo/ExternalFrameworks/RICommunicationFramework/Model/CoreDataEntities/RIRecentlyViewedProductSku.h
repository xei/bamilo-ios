//
//  RIRecentlyViewedProductSku.h
//  Jumia
//
//  Created by telmopinto on 25/01/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIProduct;

@interface RIRecentlyViewedProductSku : NSManagedObject

@property (nullable, nonatomic, retain) NSString *productSku;
@property (nullable, nonatomic, retain) NSDate *lastViewedDate;
@property (nullable, nonatomic, retain) NSString *brand;
@property (nullable, nonatomic, retain) NSNumber *numberOfTimesSeen;

+ (void)getRecentlyViewedProductSkusWithSuccessBlock:(void (^ _Null_unspecified)( NSArray * _Null_unspecified recentlyViewedProductSkus))successBlock;

+ (void)addToRecentlyViewed:(RIProduct * _Null_unspecified)product
               successBlock:(void (^ _Null_unspecified)(void))successBlock
            andFailureBlock:(void (^ _Null_unspecified)(RIApiResponse apiResponse, NSArray * _Null_unspecified error))failureBlock;

+ (void)removeFromRecentlyViewed:(RIProduct * _Null_unspecified)product;

+ (void)removeAllRecentlyViewedProductSkus;

+ (void)resetRecentlyViewedWithProducts:(NSArray * _Null_unspecified)productsArray
                           successBlock:(void (^ _Null_unspecified)(NSArray* _Null_unspecified productsArray))successBlock
                        andFailureBlock:(void (^ _Null_unspecified)(RIApiResponse apiResponse, NSArray * _Null_unspecified error))failureBlock;

+ (void)saveRecentlyViewedProductSku:(RIRecentlyViewedProductSku * _Null_unspecified)recentlyViewedProductSku andContext:(BOOL)save;

@end

