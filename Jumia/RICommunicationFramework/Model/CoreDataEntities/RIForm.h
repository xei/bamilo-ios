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

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * method;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSOrderedSet *fields;
@property (nonatomic, retain) RIFormIndex *formIndex;

//Class Methods

+ (NSString *)getFormWithUrl:(NSString *)urlString
                successBlock:(void (^)(RIForm *))successBlock
                failureBlock:(void (^)(RIApiResponse, NSArray *))failureBlock;

/**
 * Method to get a form
 *
 * @param the form to what we want
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)getForm:(NSString*)formIndexType
        successBlock:(void (^)(id form))successBlock
        failureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;

/**
 * Method to get a form
 *
 * @param the form to what we want
 * @param the extra arguments that we need to send on the request
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)getForm:(NSString*)formIndexType
        forceRequest:(BOOL)forceRequest
        successBlock:(void (^)(id form))successBlock
        failureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;

/**
 * Method to send a request to a form action
 *
 * @param the form to what we want to make the request
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)sendForm:(RIForm*)form
         successBlock:(void (^)(id object))successBlock
      andFailureBlock:(void (^)(RIApiResponse apiResponse, id errorObject))failureBlock;

/**
 * Method to send a request to a form action
 *
 * @param the form to what we want to make the request
 * @param the parameters that the form needs
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)sendForm:(RIForm*)form
           parameters:(NSDictionary*)parameters
         successBlock:(void (^)(id object))successBlock
      andFailureBlock:(void (^)(RIApiResponse apiResponse, id errorObject))failureBlock;

/**
 * Method to send a request to a form action
 *
 * @param the form to what we want to make the request
 * @param the extra arguments that we need to send on the request
 * @param the parameters that the form needs
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString*)sendForm:(RIForm*)form
       extraArguments:(NSDictionary*)extraArguments
           parameters:(NSDictionary*)parameters
         successBlock:(void (^)(id object))successBlock
      andFailureBlock:(void (^)(RIApiResponse apiResponse, id errorObject))failureBlock;

+ (void)cancelRequest:(NSString *)operationID;

+ (void)saveForm:(RIForm *)form andContext:(BOOL)save;

+ (RIForm *)parseForm:(NSDictionary *)formJSON;

/**
 * Method that returns a dictionary with all the key/values for the form fields
 *
 * @param the form that we want to know the parameters
 * @return a dictionary with the form key/value objects
 */
+ (NSDictionary *) getParametersForForm:(RIForm *)form;

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
