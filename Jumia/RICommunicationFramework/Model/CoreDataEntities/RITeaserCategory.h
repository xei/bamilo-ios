//
//  RITeaserCategory.h
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RITeaserGroup;

@interface RITeaserCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * homePageId;
@property (nonatomic, retain) NSString * homePageTitle;
@property (nonatomic, retain) NSNumber * homePageDefault;
@property (nonatomic, retain) NSString * homePageLayout;
@property (nonatomic, retain) NSString * md5;
@property (nonatomic, retain) NSOrderedSet *teaserGroups;

/**
 *  Method to load teasers from the server into core data.
 *
 *  @param the success block containing the obtained teaser categories
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)loadTeaserCategoriesIntoDatabaseWithSuccessBlock:(void (^)(id teaserCategories))successBlock
                                               andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock;

/**
 *  Method to load teasers. It checks if they are stored in the core data, and case they aren't
 *  requests them to the server
 *
 *  @param the success block containing the obtained teaser categories
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getTeaserCategoriesWithSuccessBlock:(void (^)(id teaserCategories))successBlock
                                  andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock;

/**
 *  Method to cancel the request
 *
 *  @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

@end

@interface RITeaserCategory (CoreDataGeneratedAccessors)

- (void)insertObject:(RITeaserGroup *)value inTeaserGroupsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTeaserGroupsAtIndex:(NSUInteger)idx;
- (void)insertTeaserGroups:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTeaserGroupsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTeaserGroupsAtIndex:(NSUInteger)idx withObject:(RITeaserGroup *)value;
- (void)replaceTeaserGroupsAtIndexes:(NSIndexSet *)indexes withTeaserGroups:(NSArray *)values;
- (void)addTeaserGroupsObject:(RITeaserGroup *)value;
- (void)removeTeaserGroupsObject:(RITeaserGroup *)value;
- (void)addTeaserGroups:(NSOrderedSet *)values;
- (void)removeTeaserGroups:(NSOrderedSet *)values;

@end
