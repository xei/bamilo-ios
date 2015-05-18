//
//  RIFieldDataSetComponent.h
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIField;

@interface RIFieldDataSetComponent : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * pattern;
@property (nonatomic, retain) NSString * patternMessage;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) RIField *field;

+ (RIFieldDataSetComponent *)parseDataSetComponentWithString:(NSString *)text;
+ (RIFieldDataSetComponent *)parseDataSetComponentWithDictionary:(NSDictionary *)dictionary;

+ (void)saveFieldDataSetComponent:(RIFieldDataSetComponent *)component;

@end
