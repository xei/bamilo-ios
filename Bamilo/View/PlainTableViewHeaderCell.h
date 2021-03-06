//
//  PlainTableViewHeaderCell.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface PlainTableViewHeaderCell : UITableViewHeaderFooterView

@property (copy, nonatomic) NSString *titleString;

+ (NSString *)nibName;
+ (CGFloat)cellHeight;
- (void)applyStyle: (UIFont *)font color: (UIColor *)color;

@end
