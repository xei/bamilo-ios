//
//  ButtonTableViewCell.h
//  Bamilo
//
//  Created by Ali Saeedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"
#import "ButtonTableViewCellDelegate.h"

@interface ButtonTableViewCell : BaseTableViewCell
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) id<ButtonTableViewCellDelegate> delegate;
@end
