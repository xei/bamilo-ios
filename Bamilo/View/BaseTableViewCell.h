//
//  BaseTableViewCell.h
//  Bamilo
//
//  Created by Ali Saeedifar on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell

+(CGFloat) cellHeight;
+(NSString *) nibName;

-(void) updateWithModel:(id)model;

@end
