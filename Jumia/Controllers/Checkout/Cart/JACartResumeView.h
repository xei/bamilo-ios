//
//  JACartResumeView.h
//  Jumia
//
//  Created by Jose Mota on 12/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RICart.h"
#import "JATextField.h"

@interface JACartResumeView : UIView

@property (strong, nonatomic) RICart *cart;
@property (nonatomic, strong) JATextField *couponTextField;

- (void)addProceedTarget:(id)target action:(SEL)action;
- (void)addCallTarget:(id)target action:(SEL)action;
- (void)addCouponTarget:(id)target action:(SEL)action;

- (void)setCouponValid:(BOOL)valid;
- (void)removeVoucher;

@end
