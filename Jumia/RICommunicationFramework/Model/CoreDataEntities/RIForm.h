//
//  RIForm.h
//  Comunication Project
//
//  Created by Telmo Pinto on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RIFormIndex.h"

@class RIField;

@interface RIForm : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * method;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSOrderedSet *fields;
@property (nonatomic, retain) RIFormIndex *formIndex;

//Class Methods

+ (NSString*)getForm:(NSString*)formIndexID
        successBlock:(void (^)(id form))successBlock
        failureBlock:(void (^)(NSArray *errorMessage))failureBlock;

+ (void)cancelRequest:(NSString *)operationID;

+ (RIForm *)parseForm:(NSDictionary *)formJSON;
+ (void)saveForm:(RIForm *)form;

@end

@interface RIForm (CoreDataGeneratedAccessors)

- (void)insertObject:(RIField *)value inFieldsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromFieldsAtIndex:(NSUInteger)idx;
- (void)insertFields:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeFieldsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInFieldsAtIndex:(NSUInteger)idx withObject:(RIField *)value;
- (void)replaceFieldsAtIndexes:(NSIndexSet *)indexes withFields:(NSArray *)values;
- (void)addFieldsObject:(RIField *)value;
- (void)removeFieldsObject:(RIField *)value;
- (void)addFields:(NSOrderedSet *)values;
- (void)removeFields:(NSOrderedSet *)values;
@end
