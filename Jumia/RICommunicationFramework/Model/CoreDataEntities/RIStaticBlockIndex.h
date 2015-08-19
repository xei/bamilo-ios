//
//  RIStaticBlockIndex.h
//  Jumia
//
//  Created by Telmo Pinto on 24/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RIStaticBlockIndex : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * data;

+ (NSString*)getStaticBlock:(NSString*)staticBlockKey
               successBlock:(void (^)(id staticBlock))successBlock
               failureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
+ (NSString*)loadStaticBlockIndexesIntoDatabaseForCountry:(NSString*)countryUrl
                                countryUserAgentInjection:(NSString *)countryUserAgentInjection
                                         withSuccessBlock:(void (^)(id staticBlockIndexes))successBlock
                                          andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessage))failureBlock;
+ (NSArray*)parseStaticBlockIndexes:(NSDictionary*)staticBlockIndexesJSON;
+ (RIStaticBlockIndex*)parseStaticBlockIndex:(NSDictionary*)staticBlockIndexJSON;
+ (void)saveStaticBlockIndex:(RIStaticBlockIndex*)staticBlockIndex andContext:(BOOL)save;

@end
