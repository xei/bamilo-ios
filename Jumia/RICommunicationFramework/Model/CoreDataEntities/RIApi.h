//
//  RIApi.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RICountry.h"

#define RISectionRequestStartedNotificationName @"SECTION_REQUEST_STARTED"
#define RISectionRequestEndedNotificationName @"SECTION_REQUEST_ENDED"

//$$$ FORCE UPDATE CAN REMOVE THIS
#define kUserDefaultsHasDownloadedFacebookConfigs @"kHasDownloadedFBConfigs"

@class RISection;

@interface RIApi : NSManagedObject

@property (nonatomic, retain) NSString * countryUrl;
@property (nonatomic, retain) NSString * actionName;
@property (nonatomic, retain) NSString * countryIso;
@property (nonatomic, retain) NSString * countryName;
@property (nonatomic, retain) NSString * countryUserAgentInjection;
@property (nonatomic, retain) NSNumber * curVersion;
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
+ (NSString *)startApiWithCountry:(RICountry *)country
                        reloadAPI:(BOOL)reloadAPI
                     successBlock:(void (^)(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory))successBlock
                  andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;

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
+ (RIApi *)parseApi:(NSDictionary *)api
         countryIso:(NSString *)countryIso
        countryName:(NSString *)countryName
countryUserAgentInjection:(NSString*)countryUserAgentInjection;

/**
 *  Save in the core data a given RIApi
 *
 *  @param the RIApi to save
 */
+ (void)saveApi:(RIApi *)api andContext:(BOOL)save;

/**
 *  Check if the app was allready started
 *
 *  @return a boolean
 */
+ (BOOL)checkIfHaveCountrySelected;

/**
 *  get the current url in use
 *
 *  @return the url
 */
+ (NSString *)getCountryUrlInUse;

/**
 *  get the current country iso
 *
 *  @return the country iso
 */
+ (NSString *)getCountryIsoInUse;

/**
 *  get the current country name
 *
 *  @return the country name
 */
+ (NSString *)getCountryNameInUse;

/**
 *  get the current country user agent injection
 *
 *  @return the country user agent injection
 */
+ (NSString *)getCountryUserAgentInjection;

/**
 *  get the current country api information
 *
 *  @return the country api information
 */
+ (RIApi *)getApiInformation;

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
