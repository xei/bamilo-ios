//
//  PaymentTypeTableViewCell.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "RadioButtonViewControl.h"

//### PaymentTypeTableViewCellModel ###
@interface PaymentTypeTableViewCellModel : NSObject
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL isSelected;
@end

//### PaymentTypeTableViewCell 
@interface PaymentTypeTableViewCell : BaseTableViewCell <RadioButtonViewControlDelegate>

@property (weak, nonatomic) id<RadioButtonViewControlDelegate> delegate;

@end
