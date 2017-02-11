//
//  DiscountSwitcherView.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "DiscountSwitcherViewDelegate.h"

@interface DiscountSwitcherView : BaseTableViewCell

@property (weak, nonatomic) id<DiscountSwitcherViewDelegate> delegate;

@end
