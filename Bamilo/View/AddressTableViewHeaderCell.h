//
//  AddressTableViewHeaderCell.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "PlainTableViewHeaderCell.h"

@protocol AddressTableViewHeaderCellDelegate <NSObject>
- (void)wantsToAddNewAddress:(id)addressTableViewHeader;
@end

@interface AddressTableViewHeaderCell : PlainTableViewHeaderCell
@property (nonatomic, weak) id<AddressTableViewHeaderCellDelegate> delegate;
@end
