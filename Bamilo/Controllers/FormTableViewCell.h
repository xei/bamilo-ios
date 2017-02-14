//
//  FormTableViewCell.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputTextFieldControl.h"
#import "BaseTableViewCell.h"

@interface FormTableViewCell : BaseTableViewCell
@property (weak, nonatomic) IBOutlet InputTextFieldControl *formItemControl;
@end
