//
//  RIApi.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RISection;

@interface RIApi : NSManagedObject

@property (nonatomic, retain) NSString * actionName;
@property (nonatomic, retain) NSNumber * curMobVersion;
@property (nonatomic, retain) NSNumber * curVersion;
@property (nonatomic, retain) NSNumber * minMobVersion;
@property (nonatomic, retain) NSNumber * minVersion;
@property (nonatomic, retain) NSOrderedSet *sections;

/**
 *  Starts the RIApi by request his configurations and checking the md5 of the stored objects.
 *  Case the md5 of the objects change, they are loaded from the server
 *
 *  @param the success block containing the obtained api
 *  @param the failure block containing the error message
 *
 *  @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)startApiWithSuccessBlock:(void (^)(id api))successBlock
                       andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock;

/**
 *  Method to cancel the request
 *
 *  @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

/**
 *  Method to parse an RIApi given a JSON object
 *
 *  @return the parsed RIApi
 */
+ (RIApi *)parseApi:(NSDictionary *)api;

/**
 *  Save in the core data a given RIApi
 *
 *  @param the RIApi to save
 */
+ (void)saveApi:(RIApi *)api;

@end

@interface RIApi (CoreDataGeneratedAccessors)

- (void)insertObject:(RISection *)value inSectionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSectionsAtIndex:(NSUInteger)idx;
- (void)insertSections:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSectionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSectionsAtIndex:(NSUInteger)idx withObject:(RISection *)value;
- (void)replaceSectionsAtIndexes:(NSIndexSet *)indexes withSections:(NSArray *)values;
- (void)addSectionsObject:(RISection *)value;
- (void)removeSectionsObject:(RISection *)value;
- (void)addSections:(NSOrderedSet *)values;
- (void)removeSections:(NSOrderedSet *)values;

@end