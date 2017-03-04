//
//  AddressTableViewControllerDelegate.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/20/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Address;

@protocol AddressTableViewControllerDelegate <NSObject>

@optional
- (BOOL)addressSelected:(Address *)address;
- (void)addressEditButtonTapped:(Address *)address;
- (void)addressDeleteButtonTapped:(Address *)address;
- (void)addAddressTapped;

@end
