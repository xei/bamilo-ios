//
//  OnlinePaymentVariationTableViewCell.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface OnlinePaymentVariationTableViewCellModel : NSObject
@property (assign, nonatomic) BOOL isSelected;
@property (copy, nonatomic) NSString *imageName;
@end

@interface OnlinePaymentVariationTableViewCell : BaseTableViewCell

@end
