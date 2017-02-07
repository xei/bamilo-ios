//
//  DiscountSwitcherViewDelegate.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DiscountSwitcherViewDelegate <NSObject>

-(void) discountSwitcherViewDidToggle:(BOOL)isOn;

@end
