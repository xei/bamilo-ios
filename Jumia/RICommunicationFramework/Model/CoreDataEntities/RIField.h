//
//  RIField.h
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIFieldDataSetComponent, RIFieldOption, RIForm;

@interface RIField : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * max;
@property (nonatomic, retain) NSNumber * min;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * regex;
@property (nonatomic, retain) NSNumber * required;
@property (nonatomic, retain) NSString * requiredMessage;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSOrderedSet *dataSet;
@property (nonatomic, retain) NSString * apiCall;
@property (nonatomic, retain) RIForm *form;
@property (nonatomic, retain) NSOrderedSet *options;

+ (RIField *)parseField:(NSDictionary *)fieldJSON;
+ (void)saveField:(RIField *)field;

@end

@interface RIField (CoreDataGeneratedAccessors)

- (void)insertObject:(RIFieldDataSetComponent *)value inDataSetAtIndex:(NSUInteger)idx;
- (void)removeObjectFromDataSetAtIndex:(NSUInteger)idx;
- (void)insertDataSet:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeDataSetAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInDataSetAtIndex:(NSUInteger)idx withObject:(RIFieldDataSetComponent *)value;
- (void)replaceDataSetAtIndexes:(NSIndexSet *)indexes withDataSet:(NSArray *)values;
- (void)addDataSetObject:(RIFieldDataSetComponent *)value;
- (void)removeDataSetObject:(RIFieldDataSetComponent *)value;
- (void)addDataSet:(NSOrderedSet *)values;
- (void)removeDataSet:(NSOrderedSet *)values;
- (void)insertObject:(RIFieldOption *)value inOptionsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromOptionsAtIndex:(NSUInteger)idx;
- (void)insertOptions:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeOptionsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInOptionsAtIndex:(NSUInteger)idx withObject:(RIFieldOption *)value;
- (void)replaceOptionsAtIndexes:(NSIndexSet *)indexes withOptions:(NSArray *)values;
- (void)addOptionsObject:(RIFieldOption *)value;
- (void)removeOptionsObject:(RIFieldOption *)value;
- (void)addOptions:(NSOrderedSet *)values;
- (void)removeOptions:(NSOrderedSet *)values;
@end
