//
//  JAChooseCountryTableViewCell.h
//  Jumia
//
//  Created by Jose Mota on 24/03/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCountryCellHeight 48

@interface JAChooseCountryTableViewCell : UITableViewCell

@property (strong, nonatomic) RICountry *country;
@property (nonatomic) BOOL selectedCountry;

@end
