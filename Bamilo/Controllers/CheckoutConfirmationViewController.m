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
#import "RIShippingMethodForm.h"
#import "RIShippingMethod.h"
#import "DeliveryTimeTableViewCell.h"
#import "Bamilo-Swift.h"

@interface CheckoutConfirmationViewController() <DiscountCodeViewDelegate, DiscountSwitcherViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CheckoutConfirmationViewController {
@private
    NSMutableArray *_cellsIndexPaths;
    
    Address *_shippingAddress;
    NSArray *_products;
    NSMutableArray *_receiptViewItems;
    NSString *_deliveryTime;
    NSString *_deliveryNotice;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //Header And Footer Cells
    [self.tableView registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil]  forHeaderFooterViewReuseIdentifier:[PlainTableViewHeaderCell nibName]];
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
    
    //Delivery Time Cell
    [self.tableView registerNib:[UINib nibWithNibName:[DeliveryTimeTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[DeliveryTimeTableViewCell nibName]];
    
    //Delivery notice
    [self.tableView registerNib:[UINib nibWithNibName:[OrderCMSMessageTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[OrderCMSMessageTableViewCell nibName]];
    
    self.tableView.separatorColor = [UIColor withRepeatingRGBA:243 alpha:1.0f];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    [self setInitialCellPathState];
    
    _receiptViewItems = [NSMutableArray new];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.isCompleteFetch == NO) {
        [self getContent];
    }
}

- (void)getContent {
    [DataAggregator getMultistepConfirmation:self type:RequestExecutionTypeContainer completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            //Discount Code
            if(self.cart.cartEntity.couponCode != nil) {
                [self updateDiscountViewAppearanceForValue:YES animated:NO];
            }
            
            //Delivery Time
            [DataAggregator getMultistepShipping:self completion:^(id data, NSError *error) {
                if(error == nil) {
                    [self bind:data forRequestId:1];
                    if (_deliveryNotice.length) {
                        [_cellsIndexPaths setObject:@[[NSIndexPath indexPathForRow:0 inSection:0]] atIndexedSubscript:0];
                    }
                    [self removeDeliverySectionIfNecessary];
                    self.isCompleteFetch = YES;
                } else {
                    [self removeDeliverySectionIfNecessary];
                }
                [self.tableView reloadData];
            }];
            
            //Shipping Address
            _shippingAddress = self.cart.cartEntity.address;
            //Products
            _products = self.cart.cartEntity.cartItems;
            [_cellsIndexPaths setObject:[NSMutableArray indexPathArrayOfLength:(int)_products.count forSection:3] atIndexedSubscript:3];
            [self.tableView reloadData];
            [self publishScreenLoadTime];
        } else {
            [self errorHandler:error forRequestID:0];
        }
    }];
}

- (void)removeDeliverySectionIfNecessary {
    if (!([_deliveryTime isKindOfClass:[NSString class]] && _deliveryTime.length > 0)) {
        [_cellsIndexPaths removeObjectAtIndex:2]; //remove delivery time section
    }
}

#pragma mark - Overrides
-(NSString *)getTitleForContinueButton {
    return STRING_CONFIRM_AND_CONTINUE;
}

-(NSString *)getNextStepViewControllerSegueIdentifier:(NSString *)serviceIdentifier {
    return @"pushConfirmationToPayment";
}

-(void)performPreDepartureAction:(CheckoutActionCompletion)completion {
    completion(nil, YES);
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
        case 0: {
            switch (_cellIndexPath.row) {
                case 0: {
                    OrderCMSMessageTableViewCell *deliveryNoticeCell = [tableView dequeueReusableCellWithIdentifier:[OrderCMSMessageTableViewCell nibName]];
                    if ([_deliveryNotice isKindOfClass:[NSString class]] && [_deliveryNotice length]) {
                        [deliveryNoticeCell updateWithModel:_deliveryNotice];
                    }
                    return deliveryNoticeCell;
                    break;
                }
            }
        }
            
        //Total Sum Section
        case 1: {
            switch (_cellIndexPath.row) {
                //Discount Switcher Cell
                case 0: {
                    DiscountSwitcherView *discountSwitcherView = [tableView dequeueReusableCellWithIdentifier:[DiscountSwitcherView nibName]];
                    discountSwitcherView.delegate = self;
                    [discountSwitcherView updateWithModel:@(self.cart.cartEntity.couponCode != nil)];
                    return discountSwitcherView;
                }
                    
                //Discount Code View Cell
                case 1: {
                    DiscountCodeView *discountCodeView = [tableView dequeueReusableCellWithIdentifier:[DiscountCodeView nibName]];
                    discountCodeView.delegate = self;
                    [discountCodeView updateWithModel:self.cart.cartEntity.couponCode];
                    return discountCodeView;
                }
                    
                //Receipt View Cell
                case 2: {
                    ReceiptView *receiptView = [tableView dequeueReusableCellWithIdentifier:[ReceiptView nibName] forIndexPath:indexPath];
                    [_receiptViewItems removeAllObjects];
                    
                    //Initial Undiscounted Sum
                    [_receiptViewItems addObject:[ReceiptItemModel withName:STRING_SUM_OF_PRODUCTS value:self.cart.cartEntity.cartUnreducedValueFormatted]];
                    
                    //Sum of Discounts
                    if (self.cart.cartEntity.discountValue.intValue)
                    [_receiptViewItems addObject:[ReceiptItemModel withName:STRING_SUM_OF_DISCOUNTS value:self.cart.cartEntity.discountValueFormated]];
                    
                    //Discount Code (If user inserted)
                    if(self.cart.cartEntity.couponCode) {
                        [_receiptViewItems addObject:[ReceiptItemModel withName:STRING_COUPON value:self.cart.cartEntity.couponMoneyValueFormatted]];
                    }
                    
                    //Shipping Cost
                    if(self.cart.cartEntity.shippingValue.intValue > 0) {
                        [_receiptViewItems addObject:[ReceiptItemModel withName:STRING_SHIPPING_COST value:self.cart.cartEntity.shippingValueFormatted]];
                    } else {
                        [_receiptViewItems addObject:[ReceiptItemModel withName:STRING_SHIPPING_COST value:STRING_FREE color:[Theme color:kColorGreen]]];
                    }

                    [receiptView updateWithModel:_receiptViewItems];
                    return receiptView;
                }
                    
                //Receipt Total View Cell
                case 3: {
                    ReceiptItemView *receiptItemView = [tableView dequeueReusableCellWithIdentifier:[ReceiptItemView nibName] forIndexPath:indexPath];
                    
                    [receiptItemView updateWithModel:[ReceiptItemModel withName:STRING_SUM_OF_TOTAL value:self.cart.cartEntity.cartValueFormatted]];
                    [receiptItemView applyColor:[Theme color:kColorGreen]];
                    
                    return receiptItemView;
                }
            }
        }
        break;
          
        //Delivery Time Cell
        case 2: {
            DeliveryTimeTableViewCell *deliveryTimeTableViewCell = [tableView dequeueReusableCellWithIdentifier:[DeliveryTimeTableViewCell nibName] forIndexPath:indexPath];
            if (_deliveryTime.length) {
                [deliveryTimeTableViewCell updateTitle:[_deliveryTime numbersToPersian]];
            }
            return deliveryTimeTableViewCell;
        }
        break;
            
        //Purchase Summary Section
        case 3: {
            CartListItemTableViewCell *cartListItemTableViewCell = [tableView dequeueReusableCellWithIdentifier:[CartListItemTableViewCell nibName] forIndexPath:indexPath];
            [cartListItemTableViewCell updateWithModel:[_products objectAtIndex:indexPath.row]];
            return cartListItemTableViewCell;
        }
        break;
            
        //Recipient Address Section
        case 4: {
            AddressTableViewCell *customerAddressTableViewCell = [tableView dequeueReusableCellWithIdentifier:[AddressTableViewCell nibName] forIndexPath:indexPath];
            customerAddressTableViewCell.options = ADDRESS_CELL_NONE;
            [customerAddressTableViewCell updateWithModel:_shippingAddress];
            
            return customerAddressTableViewCell;
        }
        break;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) return 0;
    return [PlainTableViewHeaderCell cellHeight];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlainTableViewHeaderCell *plainTableViewHeaderCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[PlainTableViewHeaderCell nibName]];
    NSArray<NSIndexPath *>* arrayOfIndexPathesInSection = [_cellsIndexPaths objectAtIndex:section];
    NSUInteger sectionNum = arrayOfIndexPathesInSection.count > 0 ? arrayOfIndexPathesInSection[0].section : section;
    
    switch (sectionNum) {
        case 1:
            plainTableViewHeaderCell.titleString = STRING_TOTAL_SUM;
        break;
        case 2:
            plainTableViewHeaderCell.titleString = STRING_DELIVERY_TIME;
        break;
        case 3:
            plainTableViewHeaderCell.titleString = STRING_PURCHASE_SUMMARY;
        break;
        case 4:
            plainTableViewHeaderCell.titleString = STRING_RECIPIENT_ADDRESS;
        break;
    }
    
    return plainTableViewHeaderCell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *_cellIndexPath = [[_cellsIndexPaths objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    switch (_cellIndexPath.section) {
        case 1: {
            switch (_cellIndexPath.row) {
                case 2: return _receiptViewItems.count * [ReceiptItemView cellHeight]; //Receipt Items View
                case 3: return 40.0f; //Receipt Total View
            }
            break;
        }
        case 2: return 50.0f; //Delivery Time Cell
        case 3: return [CartListItemTableViewCell cellHeight];
    }
    
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

#pragma mark - DiscountCodeViewDelegate
-(void)discountCodeViewDidFinish:(id)sender withCode:(NSString *)discountCode {
    if(self.cart.cartEntity.couponCode == nil && discountCode && discountCode.length) {
        [DataAggregator applyVoucher:self voucher:discountCode completion:^(id data, NSError *error) {
            if(error == nil) {
                [self bind:data forRequestId:2];
                
                ((DiscountCodeView *)sender).state = DISCOUNT_CODE_VIEW_STATE_CONTAINS_CODE;
                
//                NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
//                [trackingDictionary setValue:self.cart.cartEntity.cartValue forKey:kRIEventTotalCartKey];
//                [trackingDictionary setValue:self.cart.cartEntity.cartCount forKey:kRIEventQuantityKey];
//                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart] data:[trackingDictionary copy]];
                
                [self.tableView reloadData];
            } else {
                if (![Utility handleErrorMessagesWithError:error viewController:self]) {
                    [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES
                                           isSuccess:NO];
                }
            }
        }];
    }
}

-(void)discountCodeViewRemoveCodeButtonTapped:(id)sender {
    [self requestRemovalOfVoucherCode];
}

#pragma mark - DiscountSwitcherViewDelegate
-(void)discountSwitcherViewDidToggle:(BOOL)isOn {
    [self updateDiscountViewAppearanceForValue:isOn animated:YES];
    
    if(isOn == NO && self.cart.cartEntity.couponCode) {
        [self requestRemovalOfVoucherCode];
    }
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING]
    ];
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0: {
            self.cart = (RICart *)data;
        }
        break;
            
        case 1: {
            RICart *_tmpCartWithShippingInfo = (RICart *)data;
            _deliveryTime = _tmpCartWithShippingInfo.estimatedDeliveryTime;
            _deliveryNotice = _tmpCartWithShippingInfo.deliveryNotice;
        }
        break;
        
        case 2:
        case 3: {
            self.cart = (RICart *)data[kDataContent];
        }
        break;
    }
}

- (void)retryAction:(RetryHandler)callBack forRequestId:(int)rid {
    [self getContent];
    callBack(YES);
}

- (void)errorHandler:(NSError *)error forRequestID:(int)rid {
    if (rid == 0) {
        [self handleGenericErrorCodesWithErrorControlView:(int)error.code forRequestID:rid];
    }
}

#pragma mark - Helpers
-(void) setInitialCellPathState {
    _cellsIndexPaths = [NSMutableArray arrayWithObjects:
                        //delivery notice
                        @[],
                        //Total Sum
                        [NSMutableArray arrayWithObjects:
                         [NSIndexPath indexPathForRow:0 inSection:1],
                         //[NSIndexPath indexPathForRow:1 inSection:1], //Code View is initially hidden
                         [NSIndexPath indexPathForRow:2 inSection:1],
                         [NSIndexPath indexPathForRow:3 inSection:1], nil],
                        //Delivery Time
                        @[[NSIndexPath indexPathForRow:0 inSection:2]],
                        //Cart Items
                        @[],
                        //Shipping Address
                        [NSMutableArray arrayWithObjects:
                         [NSIndexPath indexPathForRow:0 inSection:4], nil],
                        nil];
}

-(void) updateDiscountViewAppearanceForValue:(BOOL)isOn animated:(BOOL)animated {
    NSIndexPath *discountCodeViewIndexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    if(isOn) {
        [[_cellsIndexPaths objectAtIndex:discountCodeViewIndexPath.section] insertObject:discountCodeViewIndexPath atIndex:discountCodeViewIndexPath.row];
    } else {
        [[_cellsIndexPaths objectAtIndex:discountCodeViewIndexPath.section] removeObjectAtIndex:discountCodeViewIndexPath.row];
    }
    [UIView animateWithDuration:0.25
                     animations:^{
        [self.tableView beginUpdates];
        if(isOn) {
            [self.tableView insertRowsAtIndexPaths:@[discountCodeViewIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        } else {
            [self.tableView deleteRowsAtIndexPaths:@[discountCodeViewIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        }
        [self.tableView endUpdates];
    } completion:^(BOOL finished) {
        if (finished)
        [self.tableView reloadData];
    }];
}

-(void) requestRemovalOfVoucherCode {
    [DataAggregator removeVoucher:self voucher:self.cart.cartEntity.couponCode completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:3];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"CheckoutConfirmation";
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_FINAL_REVIEW;
}


@end
