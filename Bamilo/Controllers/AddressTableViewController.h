//
//  AddressTableViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressList.h"
#import "Address.h"
#import "AddressTableViewCell.h"
#import "AddressTableViewControllerDelegate.h"

@interface AddressTableViewController : UITableViewController

@property (assign, nonatomic) AddressCellOptions options;
@property (copy, nonatomic) NSString *titleHeaderText;
@property (weak, nonatomic) id<AddressTableViewControllerDelegate> delegate;

+(NSMutableArray *) bindAddresses:(AddressList *)addressList;

- (void)updateWithModel:(NSArray *)addresses;
- (void)addInto:(UIViewController *)viewController ofView:(UIView *)containerView;
- (void)scrollToTop;

@end
