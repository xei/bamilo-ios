//
//  BaseTableViewCell.h
//  Bamilo
//
//  Created by Ali saiedifar on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define cEXTRA_DARK_GRAY_COLOR [UIColor withRepeatingRGBA:80 alpha:1.0f]
//#define cDARK_GRAY_COLOR [UIColor withRepeatingRGBA:115 alpha:1.0f]
//#define cLIGHT_GRAY_COLOR [UIColor withRepeatingRGBA:146 alpha:1.0f]
//#define cEXTRA_LIGHT_GRAY_COLOR [UIColor withRepeatingRGBA:186 alpha:1.0f]
//#define cGREEN_COLOR [UIColor withRGBA:0 green:160 blue:0 alpha:1.0]

@interface BaseTableViewCell : UITableViewCell

+(CGFloat) cellHeight;
+(NSString *) nibName;

-(void) updateWithModel:(id)model;

@end
