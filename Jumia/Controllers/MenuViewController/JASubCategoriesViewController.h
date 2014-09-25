//
//  JASubCategoriesViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 29/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RICategory;

@interface JASubCategoriesViewController : UIViewController

@property (strong, nonatomic) RICategory *parentCategory;
@property (strong, nonatomic) NSArray *sourceCategoriesArray;

@property (nonatomic, retain) NSString* A4SViewControllerAlias;

@end
