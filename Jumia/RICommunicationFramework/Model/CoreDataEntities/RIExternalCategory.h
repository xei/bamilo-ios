//
//  RIExternalCategory.h
//  Jumia
//
//  Created by Jose Mota on 18/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RIExternalCategory : NSManagedObject

@property (nullable, nonatomic, retain) NSString *label;
@property (nullable, nonatomic, retain) NSNumber *position;
@property (nullable, nonatomic, retain) NSString *targetString;
@property (nullable, nonatomic, retain) NSString *imageUrl;
@property (nullable, nonatomic, retain) NSNumber *level;
@property (nullable, nonatomic, retain) NSString *urlKey;
@property (nullable, nonatomic, retain) NSMutableOrderedSet *children;
@property (nullable, nonatomic, retain) RIExternalCategory *parent;

+ (void)getExternalCategoryWithSuccessBlock:(void (^)(RIExternalCategory *externalCategory))successBlock
                                            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;


+ (NSString *)loadExternalCategoryIntoDatabaseForCountry:(NSString *)countryUrl
                               countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                        withSuccessBlock:(void (^)(RIExternalCategory *externalCategory))successBlock
                                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
@end

@interface RIExternalCategory (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(RIExternalCategory *)value;
- (void)removeChildrenObject:(RIExternalCategory *)value;
- (void)addChildren:(NSOrderedSet<RIExternalCategory *> *)values;
- (void)removeChildren:(NSOrderedSet<RIExternalCategory *> *)values;

@end
