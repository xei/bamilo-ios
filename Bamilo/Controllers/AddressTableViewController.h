//
//  AddressTableViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Address.h"
#import "AddressTableViewCell.h"

typedef void(^AddressTableViewControllerDelegateActionCompletion)(Address *address);

@protocol Address;
@protocol AddressTableViewControllerDelegate <NSObject>

@optional
- (BOOL)addressSelected:(Address *)address;
- (void)addressEditButtonTapped:(id)sender completion:(AddressTableViewControllerDelegateActionCompletion)completion;
- (void)addressDeleteButtonTapped:(id)sender completion:(AddressTableViewControllerDelegateActionCompletion)completion;
- (void)addAddressTapped;

@end

@interface AddressTableViewController : UITableViewController

@property (assign, nonatomic) AddressCellOptions options;
@property (copy, nonatomic) NSString *titleHeaderText;
@property (weak, nonatomic) id<AddressTableViewControllerDelegate> delegate;

- (void)updateWithModel:(NSArray *)addresses;
- (void)addInto:(UIViewController *)viewController ofView:(UIView *)containerView;

@end
