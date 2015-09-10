//
//  RINewsletterCategory.h
//  Jumia
//
//  Created by Miguel Chaves on 18/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RICustomer;

@interface RINewsletterCategory : NSManagedObject

@property (nonatomic, retain) NSNumber * idNewsletterCategory;
@property (nonatomic, retain) NSString * name;

+ (RINewsletterCategory *)parseNewsletterCategory:(NSDictionary *)json;

+ (void)saveNewsLetterCategory:(RINewsletterCategory *)newsletterCategory andContext:(BOOL)save;

+ (NSArray *)getNewsletter;

@end
