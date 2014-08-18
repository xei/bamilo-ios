//
//  RICategory.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RICategory;

@interface RICategory : NSManagedObject

@property (nonatomic, retain) NSString * apiUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * urlKey;
@property (nonatomic, retain) NSOrderedSet *children;
@property (nonatomic, retain) RICategory *parent;

/**
 *  Method to load categories from the server into core data.
 *
 *  @param the success block containing the obtained categories
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)loadCategoriesIntoDatabaseWithSuccessBlock:(void (^)(id categories))successBlock
                                         andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock;

/**
 *  Method to load categories. It checks if they are stored in the core data, and case they aren't
 *  requests them to the server
 *
 *  @param the success block containing the obtained categories
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (void)getCategoriesWithSuccessBlock:(void (^)(id categories))successBlock
                      andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock;

/**
 *  Method to cancel the request
 *
 *  @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

/**
 *  Method to parse categories.
 *
 *  @param the json array of categories to be parsed
 *  @param a bool indicating whether or not these categories are to be saved in core data (if this
 *          is true, the old categories are replaced by the new ones)
 *
 *  @return an array of the parsed categories
 */
+ (NSArray*)parseCategories:(NSArray*)categories
                persistData:(BOOL)persistData;

@end

@interface RICategory (CoreDataGeneratedAccessors)

- (void)insertObject:(RICategory *)value inChildrenAtIndex:(NSUInteger)idx;
- (void)removeObjectFromChildrenAtIndex:(NSUInteger)idx;
- (void)insertChildren:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeChildrenAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInChildrenAtIndex:(NSUInteger)idx withObject:(RICategory *)value;
- (void)replaceChildrenAtIndexes:(NSIndexSet *)indexes withChildren:(NSArray *)values;
- (void)addChildrenObject:(RICategory *)value;
- (void)removeChildrenObject:(RICategory *)value;
- (void)addChildren:(NSOrderedSet *)values;
- (void)removeChildren:(NSOrderedSet *)values;

@end
