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

@property (nonatomic, strong) NSString *backTitle;
@property (strong, nonatomic) RICategory *currentCategory;
@property (strong, nonatomic) NSArray *categories;

@property (nonatomic, retain) NSString* A4SViewControllerAlias;

@end
