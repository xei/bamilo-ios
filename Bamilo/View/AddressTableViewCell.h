//
//  AddressTableViewCell.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "AddressTableViewControllerDelegate.h"

typedef NS_OPTIONS(NSUInteger, AddressCellOptions) {
    ADDRESS_CELL_NONE = 1 << 0,
    ADDRESS_CELL_EDIT = 1 << 1,
    ADDRESS_CELL_DELETE = 1 << 2,
    ADDRESS_CELL_SELECT = 1 << 3
};

@interface AddressTableViewCell : BaseTableViewCell

@property (assign, nonatomic) AddressCellOptions options;
@property (weak, nonatomic) id<AddressTableViewControllerDelegate> delegate;

@end
