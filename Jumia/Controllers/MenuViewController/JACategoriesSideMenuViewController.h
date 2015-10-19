//
//  JACategoriesSideMenuViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 15/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACategoriesSideMenuCell.h"

@interface JACategoriesSideMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, JACategoriesSideMenuCellDelegate>

@property (nonatomic, retain) NSString* A4SViewControllerAlias;
@property (nonatomic, strong) NSArray* categoriesArray;

@end
