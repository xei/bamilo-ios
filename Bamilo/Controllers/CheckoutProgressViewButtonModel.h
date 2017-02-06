//
//  CheckoutProgressViewButtonModel.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, CheckoutProgressViewButtonState) {
    CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING = 1 << 0,
    CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE = 1 << 1,
    CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE = 1 << 2
};

@interface CheckoutProgressViewButtonModel : NSObject

@property (assign, nonatomic) int uid;
@property (assign, nonatomic) CheckoutProgressViewButtonState state;

+(instancetype) buttonWith:(int)uid state:(CheckoutProgressViewButtonState)state;

@end
