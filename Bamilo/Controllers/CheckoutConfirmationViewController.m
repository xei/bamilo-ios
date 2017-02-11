//
//  CheckoutConfirmationViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutConfirmationViewController.h"
#import "CheckoutProgressViewButtonModel.h"
#import "PlainTableViewHeaderCell.h"
#import "AddressTableViewCell.h"
#import "DiscountSwitcherView.h"
#import "DiscountCodeView.h"
#import "BasicTableViewCell.h"
#import "ReceiptView.h"
#import "ReceiptItemView.h"
#import "CartListItemTableViewCell.h"

@interface CheckoutConfirmationViewController() <DiscountSwitcherViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CheckoutConfirmationViewController {
@private
    NSArray<ReceiptItemModel *> *receiptViewItems;
    NSMutableArray *_cellsIndexPaths;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil] forHeaderFooterViewReuseIdentifier:[PlainTableViewHeaderCell nibName]];
    
    //DiscountSwitcherView
    [self.tableView registerNib:[UINib nibWithNibName:[DiscountSwitcherView nibName] bundle:nil]  forCellReuseIdentifier:[DiscountSwitcherView nibName]];
    
    //DiscountCodeView
    [self.tableView registerNib:[UINib nibWithNibName:[DiscountCodeView nibName] bundle:nil]  forCellReuseIdentifier:[DiscountCodeView nibName]];
    
    //ReceiptView
    [self.tableView registerNib:[UINib nibWithNibName:[ReceiptView nibName] bundle:nil] forCellReuseIdentifier:[ReceiptView nibName]];
    
    //ReceiptItemView
    [self.tableView registerNib:[UINib nibWithNibName:[ReceiptItemView nibName] bundle:nil] forCellReuseIdentifier:[ReceiptItemView nibName]];
    
    //Cart List Item TableView Cell
    [self.tableView registerNib:[UINib nibWithNibName:[CartListItemTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[CartListItemTableViewCell nibName]];
    
    //Address TableView Cell
    [self.tableView registerNib:[UINib nibWithNibName:[BasicTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[BasicTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[AddressTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[AddressTableViewCell nibName]];
    
    self.tableView.separatorColor = [UIColor withRepeatingRGBA:243 alpha:1.0f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    _cellsIndexPaths = [NSMutableArray arrayWithObjects:
                            //Total Sum
                            [NSMutableArray arrayWithObjects:
                                [NSIndexPath indexPathForRow:0 inSection:0],
                                //[NSIndexPath indexPathForRow:1 inSection:0],
                                [NSIndexPath indexPathForRow:2 inSection:0],
                                [NSIndexPath indexPathForRow:3 inSection:0], nil],
                            //Cart Items
                            [NSMutableArray arrayWithObjects:
                                [NSIndexPath indexPathForRow:0 inSection:1], nil],
                            //Delivery Address
                            [NSMutableArray arrayWithObjects:
                                [NSIndexPath indexPathForRow:0 inSection:2], nil],
                        nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overrides
-(NSString *)getNextStepViewControllerSegueIdentifier {
    return @"pushReviewToPayment";
}

-(void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.title = STRING_FINAL_REVIEW;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_cellsIndexPaths count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_cellsIndexPaths objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSIndexPath *_cellIndexPath = [[_cellsIndexPaths objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    switch (_cellIndexPath.section) {
        //Total Sum Section
        case 0: {
            switch (_cellIndexPath.row) {
                //Discount Switcher Cell
                case 0: {
                    DiscountSwitcherView *discountSwitcherView = [tableView dequeueReusableCellWithIdentifier:[DiscountSwitcherView nibName]];
                    discountSwitcherView.delegate = self;
                    return discountSwitcherView;
                }
                    
                //Discount Code View Cell
                case 1: {
                    DiscountCodeView *discountCodeView = [tableView dequeueReusableCellWithIdentifier:[DiscountCodeView nibName]];
                    return discountCodeView;
                }
                    
                //Receipt View Cell
                case 2: {
                    ReceiptView *receiptView = [tableView dequeueReusableCellWithIdentifier:[ReceiptView nibName] forIndexPath:indexPath];
                    receiptViewItems = @[
                         [ReceiptItemModel with:@"جمع کل" price:@"۹۹۹،۰۰۰،۵۵۵" currency:@"ریال"],
                         [ReceiptItemModel with:@"مجموع تخفیفها" price:@"۱،۵۰۰،۰۰۰" currency:@"ریال"],
                         [ReceiptItemModel with:@"هزینه حمل" price:@"۵۰۰،۰۰۰" currency:@"ریال"]
                    ];
                    
                    [receiptView updateWithModel:receiptViewItems];
                    return receiptView;
                }
                    
                //Receipt Total View Cell
                case 3: {
                    ReceiptItemView *receiptItemView = [tableView dequeueReusableCellWithIdentifier:[ReceiptItemView nibName] forIndexPath:indexPath];
                    [receiptItemView updateWithModel:[ReceiptItemModel with:@"جمع نهایی :" price:@"۹۹۹،۰۰۰،۵۵۵" currency:@"ریال"]];
                    [receiptItemView applyColor:cGREEN_COLOR];
                    return receiptItemView;
                }
                    
                //Delivery Time Cell
                case 4: {
                    BasicTableViewCell *deliveryTimeTableViewCell = [tableView dequeueReusableCellWithIdentifier:[BasicTableViewCell nibName] forIndexPath:indexPath];
                    deliveryTimeTableViewCell.titleLabel.text = @"زمان تحویل: ۶ - ۳ روز";
                    return deliveryTimeTableViewCell;
                }
            }
        }
        break;
          
        //Purchase Summary Section
        case 1: {
            CartListItemTableViewCell *cartListItemTableViewCell = [tableView dequeueReusableCellWithIdentifier:[CartListItemTableViewCell nibName] forIndexPath:indexPath];
            return cartListItemTableViewCell;
        }
        break;
            
        //Recipient Address Section
        case 2: {
            AddressTableViewCell *customerAddressTableViewCell = [tableView dequeueReusableCellWithIdentifier:[AddressTableViewCell nibName] forIndexPath:indexPath];
            customerAddressTableViewCell.isReadOnly = YES;
            
            return customerAddressTableViewCell;
        }
        break;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlainTableViewHeaderCell *plainTableViewHeaderCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[PlainTableViewHeaderCell nibName]];
    
    switch (section) {
        case 0:
            plainTableViewHeaderCell.title = STRING_TOTAL_SUM;
        break;
            
        case 1:
            plainTableViewHeaderCell.title = STRING_PURCHASE_SUMMARY;
        break;
            
        case 2:
            plainTableViewHeaderCell.title = STRING_RECIPIENT_ADDRESS;
        break;
    }
    
    return plainTableViewHeaderCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *_cellIndexPath = [[_cellsIndexPaths objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    switch (_cellIndexPath.section) {
        case 0: {
            switch (_cellIndexPath.row) {
                case 2: return receiptViewItems.count * [ReceiptItemView cellHeight]; //Receipt Items View
                case 3: return 40.0f; //Receipt Total View
                case 4: return 50.0f; //Delivery Time Cell
            }
            break;
        }
        case 1: return [CartListItemTableViewCell cellHeight];
    }
    
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

#pragma mark - DiscountSwitcherViewDelegate
-(void)discountSwitcherViewDidToggle:(BOOL)isOn {
    NSIndexPath *discountCodeViewIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    if(isOn) {
        [[_cellsIndexPaths objectAtIndex:discountCodeViewIndexPath.section] insertObject:discountCodeViewIndexPath atIndex:discountCodeViewIndexPath.row];
    } else {
        [[_cellsIndexPaths objectAtIndex:discountCodeViewIndexPath.section] removeObjectAtIndex:discountCodeViewIndexPath.row];
    }
    
    [self.tableView beginUpdates];
    if(isOn) {
        [self.tableView insertRowsAtIndexPaths:@[discountCodeViewIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    } else {
        [self.tableView deleteRowsAtIndexPaths:@[discountCodeViewIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING]
    ];
}

@end
