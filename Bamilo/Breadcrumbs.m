//
//  BreadCrumbs.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/19/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "Breadcrumbs.h"
#import "NSArray+Extension.h"

@implementation Breadcrumbs
- (NSString *)fullPath {
    return [[[[self.items reverseObjectEnumerator] allObjects] map:^id(BreadcrumbItem *item) {
        return item.title;
    }] componentsJoinedByString:@" < "];
}

@end
