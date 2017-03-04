//
//  PlainTableViewCell.h
//  Bamilo
//
//  Created by Ali saiedifar on 1/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

@interface PlainTableViewCell : BaseTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

+(CGFloat) heightSize;

@end
