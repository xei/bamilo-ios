//
//  RITeaser.h
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RITeaserGroup, RITeaserImage, RITeaserProduct, RITeaserText;

@interface RITeaser : NSManagedObject

@property (nonatomic, retain) RITeaserGroup *teaserGroup;
@property (nonatomic, retain) NSOrderedSet *teaserImages;
@property (nonatomic, retain) NSOrderedSet *teaserTexts;
@property (nonatomic, retain) NSOrderedSet *teaserProducts;

/**
 *  Method to parse an RITeaser given a JSON object and his type of Teaser
 *
 *  @return the parsed RITeaser
 */
+ (RITeaser *)parseTeaser:(NSDictionary *)json
                   ofType:(NSInteger)type;

/**
 *  Save in the core data a given RITeaser
 *
 *  @param the RITeaser to save
 */
+ (void)saveTeaser:(RITeaser *)teaser;

@end

@interface RITeaser (CoreDataGeneratedAccessors)

- (void)insertObject:(RITeaserImage *)value inTeaserImagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTeaserImagesAtIndex:(NSUInteger)idx;
- (void)insertTeaserImages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTeaserImagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTeaserImagesAtIndex:(NSUInteger)idx withObject:(RITeaserImage *)value;
- (void)replaceTeaserImagesAtIndexes:(NSIndexSet *)indexes withTeaserImages:(NSArray *)values;
- (void)addTeaserImagesObject:(RITeaserImage *)value;
- (void)removeTeaserImagesObject:(RITeaserImage *)value;
- (void)addTeaserImages:(NSOrderedSet *)values;
- (void)removeTeaserImages:(NSOrderedSet *)values;
- (void)insertObject:(RITeaserText *)value inTeaserTextsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTeaserTextsAtIndex:(NSUInteger)idx;
- (void)insertTeaserTexts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTeaserTextsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTeaserTextsAtIndex:(NSUInteger)idx withObject:(RITeaserText *)value;
- (void)replaceTeaserTextsAtIndexes:(NSIndexSet *)indexes withTeaserTexts:(NSArray *)values;
- (void)addTeaserTextsObject:(RITeaserText *)value;
- (void)removeTeaserTextsObject:(RITeaserText *)value;
- (void)addTeaserTexts:(NSOrderedSet *)values;
- (void)removeTeaserTexts:(NSOrderedSet *)values;
- (void)insertObject:(RITeaserProduct *)value inTeaserProductsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTeaserProductsAtIndex:(NSUInteger)idx;
- (void)insertTeaserProducts:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTeaserProductsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTeaserProductsAtIndex:(NSUInteger)idx withObject:(RITeaserProduct *)value;
- (void)replaceTeaserProductsAtIndexes:(NSIndexSet *)indexes withTeaserProducts:(NSArray *)values;
- (void)addTeaserProductsObject:(RITeaserProduct *)value;
- (void)removeTeaserProductsObject:(RITeaserProduct *)value;
- (void)addTeaserProducts:(NSOrderedSet *)values;
- (void)removeTeaserProducts:(NSOrderedSet *)values;

@end
