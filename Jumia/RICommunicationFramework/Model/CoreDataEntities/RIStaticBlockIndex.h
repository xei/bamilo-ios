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
               failureBlock:(void (^)(NSArray *errorMessage))failureBlock;
+ (NSString*)loadStaticBlockIndexesIntoDatabaseForCountry:(NSString*)countryUrl
                                         withSuccessBlock:(void (^)(id staticBlockIndexes))successBlock
                                          andFailureBlock:(void (^)(NSArray *errorMessage))failureBlock;
+ (NSArray*)parseStaticBlockIndexes:(NSDictionary*)staticBlockIndexesJSON;
+ (RIStaticBlockIndex*)parseStaticBlockIndex:(NSDictionary*)staticBlockIndexJSON;
+ (void)saveStaticBlockIndex:(RIStaticBlockIndex*)staticBlockIndex;

@end
