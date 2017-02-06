//
//  PlainTableViewHeaderCell.h
//  Jumia
//
//  Created by aliunco on 1/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlainTableViewHeaderCell : UITableViewHeaderFooterView

+(NSString *) nibName;

@property (copy, nonatomic) NSString *title;

@end
