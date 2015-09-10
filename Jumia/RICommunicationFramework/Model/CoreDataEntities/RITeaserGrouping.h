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
@property (nonatomic, retain) NSOrderedSet *teaserComponents;
@end

@interface RITeaserGrouping (CoreDataGeneratedAccessors)

+ (NSString*)loadTeasersIntoDatabaseForCountryUrl:(NSString*)countryUrl
                        countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                 withSuccessBlock:(void (^)(NSArray* teaserGroupings))successBlock
                                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;
+ (NSString*)getTeaserGroupingsWithSuccessBlock:(void (^)(NSArray* teaserGroupings))successBlock
                                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;

- (void)addTeaserComponentsObject:(RITeaserComponent *)value;
- (void)removeTeaserComponentsObject:(RITeaserComponent *)value;
- (void)addTeaserComponents:(NSSet *)values;
- (void)removeTeaserComponents:(NSSet *)values;

@end
