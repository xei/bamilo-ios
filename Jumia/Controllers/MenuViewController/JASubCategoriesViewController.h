//
//  JASubCategoriesViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 29/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASubCategoriesViewController : UIViewController

@property (strong, nonatomic) NSArray *sourceCategoriesArray;
@property (strong, nonatomic) NSString *subCategoriesCartTitle;
@property (strong, nonatomic) NSString *subCategoriesCartPrice;
@property (strong, nonatomic) NSString *subCategoriesCartDetails;
@property (strong, nonatomic) NSString *subCategoriesCarCount;

@end
