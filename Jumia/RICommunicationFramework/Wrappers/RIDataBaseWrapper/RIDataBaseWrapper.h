//
//  RIDataBaseWrapper.h
//  Comunication Project
//
//  Created by Miguel Chaves on 10/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIDataBaseWrapper : NSObject

+ (RIDataBaseWrapper *)sharedInstance;
-(void)saveContext;
-(void)insertManagedObject:(NSManagedObject*)object;
-(NSManagedObject *)temporaryManagedObjectOfType:(NSString *)objectType;
-(NSManagedObject *)managedObjectOfType:(NSString *)objectType;
-(NSArray *)allEntriesOfType:(NSString *)objectType;
-(NSArray*) getEntryOfType:(NSString *)objectType
           withPropertyName:(NSString *)propertyName
           andPropertyValue:(NSString *)propertyValue;
-(void)deleteAllEntriesOfType:(NSString *)objectType;
-(void)deleteObject:(NSManagedObject *)managedObject;

@end