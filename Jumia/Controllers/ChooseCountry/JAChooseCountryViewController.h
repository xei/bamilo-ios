//
//  JAChooseCountryViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "RICountry.h"

@protocol JAChooseCountryDelegate <NSObject>

@required

- (void)didSelectedCountry:(RICountry *)country;

@end

@interface JAChooseCountryViewController : JABaseViewController

@property (weak, nonatomic) id<JAChooseCountryDelegate>delegate;

- (void)applyButtonPressed;

@end
