//
//  RIField.h
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIFieldDataSetComponent, RIForm;

@interface RIField : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSNumber * max;
@property (nonatomic, retain) NSNumber * min;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * regex;
@property (nonatomic, retain) NSString * requiredMessage;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) RIForm *form;
@property (nonatomic, retain) NSOrderedSet *dataSet;

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

@end
