//
//  CheckoutProgressViewDelegate.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CheckoutProgressViewDelegate <NSObject>

-(void) checkoutProgressViewButtonTapped:(id)sender;
-(NSArray *) getButtonsForCheckoutProgressView;

@end
