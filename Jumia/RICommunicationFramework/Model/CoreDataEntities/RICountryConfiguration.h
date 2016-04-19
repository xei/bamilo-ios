//
//  RICountryConfiguration.h
//  Comunication Project
//
//  Created by Miguel Chaves on 24/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RILanguage;

@interface RICountryConfiguration : NSManagedObject

typedef enum {
    API,
    ALGOLIA
} SuggesterProvider;

@property (nonatomic, retain) NSString * csEmail;
@property (nonatomic, retain) NSString * currencyIso;
@property (nonatomic, retain) NSNumber * currencyPosition;
@property (nonatomic, retain) NSString * currencySymbol;
@property (nonatomic, retain) NSString * decimalsSep;
@property (nonatomic, retain) NSString * gaId;
@property (nonatomic, retain) NSString * gtmId;
@property (nonatomic, retain) NSNumber * noDecimals;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * thousandsSep;
@property (nonatomic, retain) NSNumber * ratingIsEnabled;
@property (nonatomic, retain) NSNumber * ratingRequiresLogin;
@property (nonatomic, retain) NSNumber * reviewIsEnabled;
@property (nonatomic, retain) NSNumber * reviewRequiresLogin;
@property (nonatomic, retain) NSOrderedSet *languages;
@property (nonatomic, retain) NSNumber *facebookAvailable;
@property (nonatomic, retain) NSNumber *richRelevanceEnabled;
@property (nonatomic, retain) NSString *suggesterProvider;
@property (nonatomic, retain) NSString *algoliaAppId;
@property (nonatomic, retain) NSString *algoliaNamespacePrefix;
@property (nonatomic, retain) NSString *algoliaApiKey;
@property (nonatomic) SuggesterProvider suggesterProviderEnum;

@property (nonatomic, retain) NSNumber *casIsActive;
@property (nonatomic, retain) NSString *casTitle;
@property (nonatomic, retain) NSString *casSubtitle;
@property (nonatomic, retain) NSArray *casImages;


/**
 *  Method to parse an RICountryConfiguration given a JSON object
 *
 *  @return the parsed RICountryConfiguration
 */
+ (RICountryConfiguration *)parseCountryConfiguration:(NSDictionary *)json;

+ (NSString*)formatPrice:(NSNumber*)price country:(RICountryConfiguration*)country;

+ (RICountryConfiguration *)getCurrentConfiguration;

@end

@interface RICountryConfiguration (CoreDataGeneratedAccessors)

- (void)insertObject:(RILanguage *)value inLanguagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromLanguagesAtIndex:(NSUInteger)idx;
- (void)insertLanguages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeLanguagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInLanguagesAtIndex:(NSUInteger)idx withObject:(RILanguage *)value;
- (void)replaceLanguagesAtIndexes:(NSIndexSet *)indexes withLanguages:(NSArray *)values;
- (void)addLanguagesObject:(RILanguage *)value;
- (void)removeLanguagesObject:(RILanguage *)value;
- (void)addLanguages:(NSOrderedSet *)values;
- (void)removeLanguages:(NSOrderedSet *)values;

@end
