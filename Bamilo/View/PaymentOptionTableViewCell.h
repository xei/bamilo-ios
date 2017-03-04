//
//  PaymentOptionTableViewCell.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "RadioButtonViewProtocol.h"

@interface PaymentOptionTableViewCellModel : NSObject
@property (copy, nonatomic) NSString *descText;
@property (assign, nonatomic) BOOL isSelected;
@end

@interface PaymentOptionTableViewCell : BaseTableViewCell <RadioButtonViewProtocol>

@end
