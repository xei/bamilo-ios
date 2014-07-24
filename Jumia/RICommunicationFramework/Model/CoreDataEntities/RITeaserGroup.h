//
//  RITeaserGroup.h
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RITeaser, RITeaserCategory;

@interface RITeaserGroup : NSManagedObject

@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *teasers;
@property (nonatomic, retain) RITeaserCategory *teaserCategory;

/**
 *  Method to parse an RITeaserGroup given a JSON object
 *
 *  @return the parsed RITeaserGroup
 */
+ (RITeaserGroup *)parseTeaserGroup:(NSDictionary *)json;

/**
 *  Save in the core data a given RITeaserGroup
 *
 *  @param the RITeaserGroup to save
 */
+ (void)saveTeaserGroup:(RITeaserGroup *)teaserGroup;

@end

@interface RITeaserGroup (CoreDataGeneratedAccessors)

- (void)insertObject:(RITeaser *)value inTeasersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTeasersAtIndex:(NSUInteger)idx;
- (void)insertTeasers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTeasersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTeasersAtIndex:(NSUInteger)idx withObject:(RITeaser *)value;
- (void)replaceTeasersAtIndexes:(NSIndexSet *)indexes withTeasers:(NSArray *)values;
- (void)addTeasersObject:(RITeaser *)value;
- (void)removeTeasersObject:(RITeaser *)value;
- (void)addTeasers:(NSOrderedSet *)values;
- (void)removeTeasers:(NSOrderedSet *)values;

@end
