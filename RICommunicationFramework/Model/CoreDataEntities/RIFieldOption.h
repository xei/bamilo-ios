//
//  RIFieldOption.h
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIField, RIForm;

@interface RIFieldOption : NSManagedObject

@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSNumber * isUserSubscribed;
@property (nonatomic, retain) RIField *field;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * subtext;
@property (nonatomic, retain) NSString * linkHTML;
@property (nonatomic, retain) NSString * linkLabel;
@property (nonatomic, retain) RIForm* subForm;

+ (NSString*)getFieldOptionsForApiCall:(NSString*)apiCall
                          successBlock:(void (^)(NSArray *))successBlock
                          failureBlock:(void (^)(RIApiResponse, NSArray *))failureBlock;

+ (RIFieldOption *)parseFieldOption:(NSDictionary *)fieldOptionObject;

+ (void)saveFieldOption:(RIFieldOption *)option andContext:(BOOL)save;

@end
