//
//  BaseTableViewCell.h
//  Bamilo
//
//  Created by Ali saiedifar on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

#define cEXTRA_DARK_GRAY_COLOR [UIColor withRGBA:80 green:80 blue:80 alpha:1.0f]
#define cDARK_GRAY_COLOR [UIColor withRGBA:115 green:115 blue:115 alpha:1.0f]
#define cLIGHT_GRAY_COLOR [UIColor withRGBA:146 green:146 blue:146 alpha:1.0f]

@interface BaseTableViewCell : UITableViewCell

+(NSString *) nibName;

-(void) updateWithModel:(id)model;

@end
