//
//  CheckoutPaymentViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"
#import "CheckoutPaymentViewController.h"
#import "CheckoutProgressViewButtonModel.h"
#import "PlainTableViewHeaderCell.h"
#import "PaymentTypeTableViewCell.h"
#import "PaymentOptionWithLogoTableViewCell.h"
#import "RIPaymentMethodForm.h"
#import "CartEntitySummaryViewControl.h"
#import "RIPaymentInformation.h"
#import "JACheckoutForms.h"

typedef NS_OPTIONS(NSUInteger, PaymentMethod) {
    PAYMENT_METHOD_ONLINE = 1 << 0,
    PAYMENT_METHOD_ON_DELIVERY = 1 << 1
};

@interface CheckoutPaymentViewController () <RadioButtonViewControlDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CartEntitySummaryViewControl *cartEntitySummaryViewControl;
@end

@implementation CheckoutPaymentViewController {
@private
    NSArray *_paymentMethods;
    int _selectedPaymentMethodIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Header And Footer Cells
    [self.tableView registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil] forHeaderFooterViewReuseIdentifier:[PlainTableViewHeaderCell nibName]];
    
    //PaymentTypeTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentTypeTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentTypeTableViewCell nibName]];
    
    //PaymentOptionWithLogoTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentOptionWithLogoTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentOptionWithLogoTableViewCell nibName]];
    
    //PaymentOptionTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentOptionTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentOptionTableViewCell nibName]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //TEMP
    /*OnlinePaymentVariationTableViewCellModel *saman = [OnlinePaymentVariationTableViewCellModel new];
    saman.imageName = @"SamanBankLogo";
    saman.isSelected = YES;
    
    OnlinePaymentVariationTableViewCellModel *parsian = [OnlinePaymentVariationTableViewCellModel new];
    parsian.imageName = @"ParsianBankLogo";
    parsian.isSelected = NO;
    
    _onlinePaymentVariations = @[saman, parsian];
    
    _cellsIndexPaths = [NSMutableArray arrayWithObjects:
    //Online Payment
    [NSMutableArray arrayWithObjects:
        [NSIndexPath indexPathForRow:0 inSection:0],
        [NSIndexPath indexPathForRow:1 inSection:0], nil],
    //Online Payment Variations
    [NSMutableArray arrayWithObjects:
        [NSIndexPath indexPathForRow:0 inSection:1],
        [NSIndexPath indexPathForRow:1 inSection:1], nil],
    //Pay On Delivery
    [NSMutableArray arrayWithObjects:
        [NSIndexPath indexPathForRow:0 inSection:2],
        //[NSIndexPath indexPathForRow:1 inSection:2],
    nil],
    nil];
    */
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DataManager sharedInstance] getMultistepPayment:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            
            //NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self.cart forKey:kUpdateCartNotificationValue];
            //[[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
            
            [self.cartEntitySummaryViewControl updateWithModel:self.cart.cartEntity];
            
            _paymentMethods = [RIPaymentMethodForm getPaymentMethodsInForm:self.cart.formEntity.paymentMethodForm];
            
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Overrides
-(NSString *)getNextStepViewControllerSegueIdentifier:(NSString *)serviceIdentifier {
    return nil;
}

-(void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.title = STRING_PAYMENT_OPTION;
}

-(void)performPreDepartureAction:(CheckoutActionCompletion)completion {
    RIPaymentMethodFormOption *selectedPaymentMethod = [_paymentMethods objectAtIndex:_selectedPaymentMethodIndex];
    RIPaymentMethodFormField *field = [self.cart.formEntity.paymentMethodForm.fields firstObject];
    if (VALID_NOTEMPTY(field, RIPaymentMethodFormField)) {
        field.value = selectedPaymentMethod.value;
    }
    
    if (selectedPaymentMethod && self.cart.cartEntity.cartValue) {
         NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[RIPaymentMethodForm getParametersForForm:self.cart.formEntity.paymentMethodForm]];
        JACheckoutForms *checkoutFormForPaymentMethod = [[JACheckoutForms alloc] initWithPaymentMethodForm:self.cart.formEntity.paymentMethodForm width:0.0];
        [params addEntriesFromDictionary:[checkoutFormForPaymentMethod getValuesForPaymentMethod:selectedPaymentMethod]];
        
        [[DataManager sharedInstance] setMultistepPayment:self params:params completion:^(id data, NSError *error) {
            if(error == nil && completion != nil) {
                NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                [trackingDictionary setValue:selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentSuccess] data:[trackingDictionary copy]];
                
                MultistepEntity *multistepEntity = (MultistepEntity *)data;
                if([multistepEntity.nextStep isEqualToString:@"finish"]) {
                    [[DataManager sharedInstance] setMultistepConfirmation:self cart:self.cart completion:^(id data, NSError *error) {
                        if(error == nil) {
                            [self bind:data forRequestId:1];
                            
                            NSDictionary *userInfo = @{ @"cart" : self.cart };
                            
                            if(self.cart.paymentInformation.type == RIPaymentInformationCheckoutEnded) {
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutThanksScreenNotification object:nil userInfo:userInfo];
                            } else {
                                 [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutExternalPaymentsScreenNotification object:nil userInfo:userInfo];
                            }
                            
                            completion(multistepEntity.nextStep);
                        }
                    }];
                }
            } else {
                NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                [trackingDictionary setValue:selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                [trackingDictionary setValue:self.cart.cartEntity.cartValueEuroConverted forKey:kRIEventTotalTransactionKey];
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentFail] data:[trackingDictionary copy]];
                
                [self showNotificationBar:STRING_ERROR_SETTING_PAYMENT_METHOD isSuccess:NO];
            }
        }];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_paymentMethods count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2; //PaymentType and PaymentOption
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RIPaymentMethodFormOption *paymentMethod = [_paymentMethods objectAtIndex:indexPath.section];
 
    switch (indexPath.row) {
        case 0: {
            PaymentTypeTableViewCell *onlinePaymentTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentTypeTableViewCell nibName] forIndexPath:indexPath];
            onlinePaymentTableViewCell.tag = indexPath.section;
            onlinePaymentTableViewCell.delegate = self;
            
            PaymentTypeTableViewCellModel *model = [PaymentTypeTableViewCellModel new];
            model.title = paymentMethod.displayName;
            model.isSelected = (_selectedPaymentMethodIndex == indexPath.section);
            [onlinePaymentTableViewCell updateWithModel:model];
            
            return onlinePaymentTableViewCell;
        }
        
        case 1: {
            if([paymentMethod.displayName containsString:STRING_PAY_ON_DELIVERY]) {
                PaymentOptionTableViewCell *paymentOptionTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentOptionTableViewCell nibName] forIndexPath:indexPath];
                
                PaymentOptionTableViewCellModel *model = [PaymentOptionTableViewCellModel new];
                model.descText = paymentMethod.text;
                model.isSelected = (_selectedPaymentMethodIndex == indexPath.section);
                [paymentOptionTableViewCell updateWithModel:model];
                
                return paymentOptionTableViewCell;
            } else {
                PaymentOptionWithLogoTableViewCell *paymentOptionWithLogoTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentOptionWithLogoTableViewCell nibName] forIndexPath:indexPath];
                
                PaymentOptionWithLogoTableViewCellModel *model = [PaymentOptionWithLogoTableViewCellModel new];
                model.descText = paymentMethod.text;
                model.logoImageUrl = paymentMethod.icon.imageUrlForEnabled;
                model.isSelected = (_selectedPaymentMethodIndex == indexPath.section);
                [paymentOptionWithLogoTableViewCell updateWithModel:model];
                
                return paymentOptionWithLogoTableViewCell;
            }
        }
    }
    
    /*NSIndexPath *_cellIndexPath = [_paymentMethods objectAtIndex:indexPath.section]
                    
    switch (_cellIndexPath.section) {
        case 0 : {
            switch (_cellIndexPath.row) {
                case 0: {
                    PaymentTypeTableViewCell *onlinePaymentTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentTypeTableViewCell nibName] forIndexPath:indexPath];
                    onlinePaymentTableViewCell.tag = PAYMENT_METHOD_ONLINE;
                    onlinePaymentTableViewCell.delegate = self;
                    
                    PaymentTypeTableViewCellModel *model = [[PaymentTypeTableViewCellModel alloc] init];
                    model.title = STRING_ONLINE_PAYMENT;
                    model.isSelected = (_selectedPaymentMethod == PAYMENT_METHOD_ONLINE);
                    [onlinePaymentTableViewCell updateWithModel:model];
                    
                    return onlinePaymentTableViewCell;
                }
                    
                case 1: {
                    PaymentDescTableViewCell *onlinePaymentDescTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentDescTableViewCell nibName] forIndexPath:indexPath];
                    onlinePaymentDescTableViewCell.descLabel.text = @"پرداخت آنلاین، پردازش سفارش شما را تسریع داده و باعث می شود سفارش شما با اولویت بالاتری ارسال گردد.";
                    return onlinePaymentDescTableViewCell;
                }
            }
        }
            
        case 1: {
            OnlinePaymentVariationTableViewCell *onlinePaymentVariationCell = [tableView dequeueReusableCellWithIdentifier:[OnlinePaymentVariationTableViewCell nibName] forIndexPath:indexPath];
            onlinePaymentVariationCell.tag = indexPath.row;
            onlinePaymentVariationCell.delegate = self;
            
            OnlinePaymentVariationTableViewCellModel *model = [_onlinePaymentVariations objectAtIndex:indexPath.row];
            model.isSelected = (_indexForOnlineMethodVariation == indexPath.row);
            [onlinePaymentVariationCell updateWithModel:model];
            return onlinePaymentVariationCell;
        }
            
        case 2: {
            switch (_cellIndexPath.row) {
                case 0: {
                    PaymentTypeTableViewCell *payOnDeliveryTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentTypeTableViewCell nibName] forIndexPath:indexPath];
                    payOnDeliveryTableViewCell.tag = PAYMENT_METHOD_ON_DELIVERY;
                    payOnDeliveryTableViewCell.delegate = self;
                    
                    PaymentTypeTableViewCellModel *model = [[PaymentTypeTableViewCellModel alloc] init];
                    model.title = STRING_PAY_ON_DELIVERY;
                    model.isSelected = (_selectedPaymentMethod == PAYMENT_METHOD_ON_DELIVERY);
                    [payOnDeliveryTableViewCell updateWithModel:model];
                    
                    return payOnDeliveryTableViewCell;
                }
                    
                case 1: {
                    PaymentDescTableViewCell *payOnDeliveryTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentDescTableViewCell nibName] forIndexPath:indexPath];
                    payOnDeliveryTableViewCell.descLabel.text = @"مبلغ سفارش را به صورت نقدی و با با کارت بانکی به پیک بامیلو پرداخت نمایید.";
                    return payOnDeliveryTableViewCell;
                }
            }
        }b
    }
    */
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [PlainTableViewHeaderCell cellHeight];
    }

    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            PlainTableViewHeaderCell *plainTableViewHeaderCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[PlainTableViewHeaderCell nibName]];
            plainTableViewHeaderCell.title = STRING_PAYMENT_OPTION;
            return plainTableViewHeaderCell;
        }
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - RadioButtonViewControlDelegate
-(void)didSelectRadioButton:(id)sender {
    if([sender isKindOfClass:[PaymentTypeTableViewCell class]]) {
        PaymentTypeTableViewCell *radioButtonPaymentTypeTableViewCell = (PaymentTypeTableViewCell *)sender;
        _selectedPaymentMethodIndex = (int)radioButtonPaymentTypeTableViewCell.tag;
        
        [self.tableView reloadData];
    }
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE]
    ];
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0:
        case 1:
            self.cart = (RICart *)data;
        break;
    }
}

@end
