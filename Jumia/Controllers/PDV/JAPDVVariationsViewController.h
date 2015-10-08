//
//  JAPDVVariationsViewController.h
//  Jumia
//
//  Created by josemota on 10/5/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProduct.h"

@interface JAPDVVariationsViewController : JABaseViewController

@property (retain, nonatomic) RIProduct *product;
@property (retain, nonatomic) NSArray *variations;

@end
