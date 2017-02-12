//
//  AddressList.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "Address.h"

@protocol Address;

@interface AddressList : BaseModel

@property (strong, nonatomic) Address *billing;
@property (strong, nonatomic) Address *shipping;
@property (strong, nonatomic) NSArray<Address> *other;

@end
