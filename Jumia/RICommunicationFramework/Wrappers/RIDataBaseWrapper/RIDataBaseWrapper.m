//
//  RIDataBaseWrapper.m
//  Comunication Project
//
//  Created by Miguel Chaves on 10/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIDataBaseWrapper.h"

@interface RIDataBaseWrapper()

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation RIDataBaseWrapper

@synthesize managedObjectContext = _managedObjectContext;
- (NSManagedObjectContext *)managedObjectContext {
    if (NOTEMPTY(_managedObjectContext)) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (NOTEMPTY(coordinator)) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
    }
    return _managedObjectContext;
}

@synthesize managedObjectModel = _managedObjectModel;
- (NSManagedObjectModel *)managedObjectModel {
    if (NOTEMPTY(_managedObjectModel)) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (NOTEMPTY(_persistentStoreCoordinator)) {
        return _persistentStoreCoordinator;
    }
    NSURL *applicationDocumentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *storeURL = [applicationDocumentsDirectory URLByAppendingPathComponent:@"Model.sqlite"];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


+(RIDataBaseWrapper *)sharedInstance {
    static dispatch_once_t pred = 0;
    static RIDataBaseWrapper *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
        
    });
    return instance;
}

-(BOOL)saveContext
{
    if(![self.managedObjectContext hasChanges]) {
        return YES;
    }
    
    BOOL saved = NO;
    NSError *error = nil;
    @try {
        saved = [self.managedObjectContext save:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"ExceptionError while saving %@",(id)[exception userInfo] ? : (id)[exception reason]);
        return NO;
    }
    if (error) {
        NSLog(@"Error while saving %@", error);
        return NO;
    }
    return YES;
}

-(void)insertManagedObject:(NSManagedObject*)object
{
    if (object.managedObjectContext) {
        return;
    }
    if (![object.managedObjectContext isEqual:self.managedObjectContext]) {
        [self.managedObjectContext insertObject:object];
    }
}

- (void) resetApplicationModel
{
    NSPersistentStore *store = [self.persistentStoreCoordinator.persistentStores lastObject];
    NSError *error;
    NSURL *storeURL = store.URL;
    NSPersistentStoreCoordinator *storeCoordinator = self.persistentStoreCoordinator;
    [storeCoordinator removePersistentStore:store error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
    //    Then, just add the persistent store back to ensure it is recreated properly.
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (NSString *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

-(NSManagedObject *)temporaryManagedObjectOfType:(NSString *)objectType
{
    NSEntityDescription* description = [NSEntityDescription entityForName:objectType inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *temporaryObject = [[NSManagedObject alloc] initWithEntity:description insertIntoManagedObjectContext:nil];
    
    return temporaryObject;
}


-(NSManagedObject *)managedObjectOfType:(NSString *)objectType
{
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:objectType inManagedObjectContext:self.managedObjectContext];
    
    return newObject;
}

-(NSArray *)allEntriesOfType:(NSString *)objectType;
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:objectType inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setIncludesPendingChanges:YES];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (NOTEMPTY(error)) {
        NSLog(@"ERROR WHILE FETCHING COREDATA REQUEST");
        return nil;
    }
    return  results;
}

-(NSArray*) getEntryOfType:(NSString *)objectType
          withPropertyName:(NSString *)propertyName
          andPropertyValue:(NSString *)propertyValue
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:objectType inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setIncludesPendingChanges:YES];
    
    // retrive the objects with a given value for a certain property
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K == %@", propertyName, propertyValue];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (NOTEMPTY(error)) {
        NSLog(@"ERROR WHILE FETCHING COREDATA REQUEST");
        return nil;
    }
    return result;
}

-(NSArray*) getEntryOfType:(NSString *)objectType
          withPropertyName:(NSString *)propertyName
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:objectType inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setIncludesPendingChanges:YES];
    
    // retrive the objects with a given value for a certain property
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K != nil", propertyName];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (NOTEMPTY(error)) {
        NSLog(@"ERROR WHILE FETCHING COREDATA REQUEST");
        return nil;
    }
    return result;
}

-(void)deleteAllEntriesOfType:(NSString *)objectType;
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:objectType inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setIncludesPendingChanges:YES];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (NOTEMPTY(error)) {
        NSLog(@"ERROR WHILE FETCHING COREDATA REQUEST");
    }
    for(NSManagedObject *obj in results) {
        [self.managedObjectContext deleteObject:obj];
    }
}

-(void)deleteAllEntriesOfType:(NSString *)objectType
             withPropertyName:(NSString *)propertyName
             andPropertyValue:(NSString *)propertyValue
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:objectType inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // retrive the objects with a given value for a certain property
    [request setPredicate:[NSPredicate predicateWithFormat: @"%K == %@", propertyName, propertyValue]];
    [request setEntity:entity];
    [request setIncludesPendingChanges:YES];
    
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (NOTEMPTY(error)) {
        NSLog(@"ERROR WHILE FETCHING COREDATA REQUEST");
    }
    for(NSManagedObject *obj in results) {
        [self.managedObjectContext deleteObject:obj];
    }
}

-(void)deleteObject:(NSManagedObject *)managedObject
{
    [self.managedObjectContext deleteObject:managedObject];
}

@end
