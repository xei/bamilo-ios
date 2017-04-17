//
//  RITeaserGrouping.h
//  Jumia
//
//  Created by Telmo Pinto on 16/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RITeaserComponent;

@interface RITeaserGrouping : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSMutableOrderedSet *teaserComponents;
@end

@interface RITeaserGrouping (CoreDataGeneratedAccessors)

+ (NSString*)loadTeasersIntoDatabaseForCountryUrl:(NSString*)countryUrl countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                 withSuccessBlock:(void (^)(NSDictionary* teaserGroupings, BOOL richTeasers))successBlock
                                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

+ (RITeaserGrouping*)parseTeaserGrouping:(NSDictionary*)teaserGroupingJSON country:(RICountryConfiguration*)country;
+ (RITeaserGrouping*)parseTeaserGroupingWithoutSave:(NSDictionary*)teaserGroupingJSON country:(RICountryConfiguration*)country;

+ (NSString*)getTeaserGroupingsWithSuccessBlock:(void (^)(NSDictionary* teaserGroupings, BOOL richTeaserGrouping))successBlock
                                      failBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock
                                      rickBlock:(void (^)(RITeaserGrouping * richTeaserGrouping))richBlock;

+ (void)getTeaserRichRelevance:(NSDictionary*) richTeasers
                  successBlock:(void(^)(RITeaserGrouping * richTeaserGrouping))richBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;

- (void)addTeaserComponentsObject:(RITeaserComponent *)value;
- (void)removeTeaserComponentsObject:(RITeaserComponent *)value;
- (void)addTeaserComponents:(NSSet *)values;
- (void)removeTeaserComponents:(NSSet *)values;

@end
