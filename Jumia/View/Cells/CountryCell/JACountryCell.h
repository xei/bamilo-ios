//
//  JACountryCell.h
//  Jumia
//
//  Created by Miguel Chaves on 01/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JACountryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *countryImage;
@property (weak, nonatomic) IBOutlet UILabel *countryName;
@property (weak, nonatomic) IBOutlet UIImageView *checkImage;

@end
