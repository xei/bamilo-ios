//
//  JAProductDetailsViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 08/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAProductDetailsViewController : JABaseViewController

@property (strong, nonatomic) NSString *stringBrand;
@property (strong, nonatomic) NSString *stringName;
@property (strong, nonatomic) NSString *stringNewPrice;
@property (strong, nonatomic) NSString *stringOldPrice;
@property (strong, nonatomic) NSString *featuresText;
@property (strong, nonatomic) NSString *descriptionText;

@end
