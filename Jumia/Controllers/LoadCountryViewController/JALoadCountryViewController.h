//
//  JALoadCountryViewController.h
//  Jumia
//
//  Created by plopes on 08/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JALoadCountryViewController : JABaseViewController

@property (nonatomic, strong) RICountry *selectedCountry;
@property (nonatomic, strong) NSDictionary *pushNotification;

@end
