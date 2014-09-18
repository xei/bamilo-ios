//
//  RINewsletterCategory.m
//  Jumia
//
//  Created by Miguel Chaves on 18/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RINewsletterCategory.h"
#import "RICustomer.h"


@implementation RINewsletterCategory

@dynamic idNewsletterCategory;
@dynamic name;

+ (RINewsletterCategory *)parseNewsletterCategory:(NSDictionary *)json
{
    RINewsletterCategory *category = (RINewsletterCategory *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RINewsletterCategory class])];
    
    if ([json objectForKey:@"id_newsletter_category"]) {
        category.idNewsletterCategory = [NSNumber numberWithInteger:[[json objectForKey:@"id_newsletter_category"] integerValue]];
    }
    
    if ([json objectForKey:@"name"]) {
        category.name = [json objectForKey:@"name"];
    }
    
    return category;
}

+ (void)saveNewsLetterCategory:(RINewsletterCategory *)newsletterCategory
{    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:newsletterCategory];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

+ (NSArray *)getNewsletter
{
    return [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RINewsletterCategory class])];
}

@end
