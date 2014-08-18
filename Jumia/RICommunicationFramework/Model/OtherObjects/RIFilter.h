//
//  RIFilter.h
//  Jumia
//
//  Created by Telmo Pinto on 12/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIFilterOption : NSObject

@property (nonatomic, strong)NSString* name;
@property (nonatomic, strong)NSString* val;
@property (nonatomic, assign)NSInteger max;
@property (nonatomic, assign)NSInteger min;
@property (nonatomic, assign)NSInteger interval;
@property (nonatomic, strong)NSString* colorHexValue;
@property (nonatomic, strong)NSString* colorImageUrl;

//current state
@property (nonatomic, assign)BOOL selected;
@property (nonatomic, assign)NSInteger lowerValue;
@property (nonatomic, assign)NSInteger upperValue;
@property (nonatomic, assign)BOOL discountOnly;

/**
 *  Method to parse an RIFilterOption given a JSON object
 *
 *  @return the parsed RIFilterOption
 */
+ (RIFilterOption *)parseFilterOption:(NSDictionary *)filterOptionJSON;

@end

@interface RIFilter : NSObject

@property (nonatomic, strong)NSString* uid;
@property (nonatomic, strong)NSString* name;
@property (nonatomic, assign)BOOL multi;
@property (nonatomic, strong)NSArray* options;

/**
 *  Method that returns the url component to add to the product request based on an array of RIFilters
 *  This method calls + (NSString *)urlWithFilter:(RIFilter*)filter;
 *
 *  @return the url component
 */
+ (NSString *)urlWithFiltersArray:(NSArray*)filtersArray;

/**
 *  Method that returns the url component to add to the product request based on an RIFilter
 *
 *  @return the url component
 */
+ (NSString *)urlWithFilter:(RIFilter*)filter;

/**
 *  Method to parse an array of RIFilters given a JSON object
 *
 *  @return the array of parsed RIFilters
 */
+ (NSArray *)parseFilters:(NSArray *)filtersJSON;

/**
 *  Method to parse an RIFilter given a JSON object
 *
 *  @return the parsed RIFilter
 */
+ (RIFilter *)parseFilter:(NSDictionary *)filterJSON;

@end
