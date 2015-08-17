//
//  RIFormIndex.h
//  Comunication Project
//
//  Created by Telmo Pinto on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIForm;

@interface RIFormIndex : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) RIForm *form;

+ (NSString*)loadFormIndexesIntoDatabaseForCountry:(NSString*)countryUrl
                         countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                  deleteOldIndexes:(BOOL)deleteOldIndexes
                                  withSuccessBlock:(void (^)(id formIndexes))successBlock
                                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
+ (NSString*)getFormWithIndexId:(NSString*)formIndexID
                   successBlock:(void (^)(RIFormIndex *formIndex))successBlock
                andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
+ (NSArray*)parseFormIndexes:(NSDictionary*)formIndexesJSON;
+ (RIFormIndex*)parseFormIndex:(NSDictionary*)formIndexJSON;
+ (void)saveFormIndex:(RIFormIndex*)formIndex;
+ (void)cancelRequest:(NSString *)operationID;

@end
