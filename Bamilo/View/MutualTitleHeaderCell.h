//
//  MutualTitleHeaderCell.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlainTableViewHeaderCell.h"

@interface MutualTitleHeaderCell : PlainTableViewHeaderCell
@property (nonatomic, copy) NSString *leftTitleString;
@property (nonatomic, copy) NSAttributedString *leftTitleAtributedString;
@end
