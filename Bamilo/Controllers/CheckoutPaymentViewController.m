//
//  CheckoutPaymentViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutDataManager.h"
#import "CheckoutPaymentViewController.h"
#import "CheckoutProgressViewButtonModel.h"
#import "PlainTableViewHeaderCell.h"
#import "PaymentTypeTableViewCell.h"
#import "PaymentOptionWithLogoTableViewCell.h"
#import "RIPaymentMethodForm.h"
#import "CartEntitySummaryViewControl.h"
#import "RIPaymentInformation.h"
#import "JACheckoutForms.h"
#import "EventUtilities.h"
#import "SuccessPaymentViewController.h"
#import "ThreadManager.h"

typedef NS_OPTIONS(NSUInteger, PaymentMethod) {
    PAYMENT_METHOD_ONLINE = 1 << 0,
    PAYMENT_METHOD_ON_DELIVERY = 1 << 1
};

typedef void(^GetPaymentMethodsCompletion)(NSArray *paymentMethods);

@interface CheckoutPaymentViewController () <RadioButtonViewControlDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CartEntitySummaryViewControl *cartEntitySummaryViewControl;
@end

@implementation CheckoutPaymentViewController {
@private
    NSArray *_paymentMethods;
    int _selectedPaymentMethodIndex;
    MultistepEntity *_multistepEntity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Header And Footer Cells
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentTypeTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentTypeTableViewCell nibName]];
    
    //PaymentTypeTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentTypeTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentTypeTableViewCell nibName]];
    
    //PaymentOptionWithLogoTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentOptionWithLogoTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentOptionWithLogoTableViewCell nibName]];
    
    //PaymentOptionTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentOptionTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentOptionTableViewCell nibName]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _selectedPaymentMethodIndex = -1;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(_paymentMethods == nil) {
        [self getPaymentMethods:^(NSArray *paymentMethods) {
            [self publishScreenLoadTime];
            
            if(paymentMethods.count) {
                int __selectedPaymentMethodIndex = 0;
                
                if(self.cart.cartEntity.paymentMethod) {
                    for(int i=0; i<paymentMethods.count; i++) {
                        RIPaymentMethodFormOption *paymentMethod = paymentMethods[i];
                        if([paymentMethod.displayName containsString:self.cart.cartEntity.paymentMethod]) {
                            __selectedPaymentMethodIndex = i;
                            break;
                        }
                    }
                }
                
                [self setPaymentMethod:__selectedPaymentMethodIndex];
            }
        }];
    }
}

#pragma mark - Overrides
-(NSString *)getTitleForContinueButton {
    return STRING_CONFIRM_AND_PAY;
}

-(NSString *)getNextStepViewControllerSegueIdentifier:(NSString *)serviceIdentifier {
    return nil;
}

-(void)updateNavBar {
    [super updateNavBar];
    self.navBarLayout.title = STRING_PAYMENT_OPTION;
}

-(void)performPreDepartureAction:(CheckoutActionCompletion)completion {
    if([_multistepEntity.nextStep isEqualToString:@"finish"] && completion != nil) {
        [[CheckoutDataManager sharedInstance] setMultistepConfirmation:self cart:self.cart completion:^(id data, NSError *error) {
            if(error == nil) {
                [self bind:data forRequestId:1];
                
                NSDictionary *userInfo = @{ kCart : self.cart };
                
                if(self.cart.paymentInformation.type == RIPaymentInformationCheckoutEnded) {
                    [self performSegueWithIdentifier:NSStringFromClass([SuccessPaymentViewController class]) sender:nil];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutExternalPaymentsScreenNotification object:nil userInfo:userInfo];
                }
                
                completion(_multistepEntity.nextStep, YES);
            } else {
                [self showNotificationBar:error isSuccess:NO];
                
                //EVENT : PURCHASE
                [TrackerManager postEvent:[EventFactory purchase:[EventUtilities getEventCategories:self.cart] basketValue:[self.cart.cartEntity.cartValue longValue] success:NO] forName:[PurchaseEvent name]];
                
                completion(nil, NO);
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
            PlainTableViewHeaderCell *plainTableViewHeaderCell = [self.tableView dequeueReusableCellWithIdentifier:[PlainTableViewHeaderCell nibName]];
            plainTableViewHeaderCell.titleString = STRING_PAYMENT_OPTION;
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
        [self setPaymentMethod:(int)radioButtonPaymentTypeTableViewCell.tag];
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
        case 2:
            self.cart = (RICart *)data;
        break;
    }
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    return @"CheckoutPayment";
}

#pragma mark - prepareForSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: NSStringFromClass([SuccessPaymentViewController class])]) {
        ((SuccessPaymentViewController *) [segue destinationViewController]).cart = self.cart;
    }
}

#pragma mark - Helpers
-(void) getPaymentMethods:(GetPaymentMethodsCompletion)completion {
    [[CheckoutDataManager sharedInstance] getMultistepPayment:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            [self.cartEntitySummaryViewControl updateWithModel:self.cart.cartEntity];
            _paymentMethods = [RIPaymentMethodForm getPaymentMethodsInForm:self.cart.formEntity.paymentMethodForm];
            
            [ThreadManager executeOnMainThread:^{
                [self.tableView reloadData];
            }];
            
            if(completion != nil) {
                completion(_paymentMethods);
            }
        }
    }];
}

-(void) setPaymentMethod:(int)selectedPaymentMethodIndex {
    RIPaymentMethodFormOption *selectedPaymentMethod = [_paymentMethods objectAtIndex:selectedPaymentMethodIndex];
    RIPaymentMethodFormField *field = [self.cart.formEntity.paymentMethodForm.fields firstObject];
    if (VALID_NOTEMPTY(field, RIPaymentMethodFormField)) {
        field.value = selectedPaymentMethod.value;
    }
    
    if (selectedPaymentMethod && self.cart.cartEntity.cartValue) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[RIPaymentMethodForm getParametersForForm:self.cart.formEntity.paymentMethodForm]];
        JACheckoutForms *checkoutFormForPaymentMethod = [[JACheckoutForms alloc] initWithPaymentMethodForm:self.cart.formEntity.paymentMethodForm width:0.0];
        [params addEntriesFromDictionary:[checkoutFormForPaymentMethod getValuesForPaymentMethod:selectedPaymentMethod]];
        
        [[CheckoutDataManager sharedInstance] setMultistepPayment:self params:params completion:^(id data, NSError *error) {
            if(error == nil) {
                NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                [trackingDictionary setValue:selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentSuccess] data:[trackingDictionary copy]];
                
                _multistepEntity = (MultistepEntity *)data;
                
                [[CheckoutDataManager sharedInstance] getMultistepConfirmation:self type:REQUEST_EXEC_IN_FOREGROUND completion:^(id data, NSError *error) {
                    if(error == nil) {
                        [self bind:data forRequestId:2];
                        _selectedPaymentMethodIndex = selectedPaymentMethodIndex;
                        [self.cartEntitySummaryViewControl updateWithModel:self.cart.cartEntity];
                        
                        [ThreadManager executeOnMainThread:^{
                            [self.tableView reloadData];
                        }];
                    }
                }];
            } else {
                NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                [trackingDictionary setValue:selectedPaymentMethod.label forKey:kRIEventPaymentMethodKey];
                [trackingDictionary setValue:self.cart.cartEntity.cartValueEuroConverted forKey:kRIEventTotalTransactionKey];
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutPaymentFail] data:[trackingDictionary copy]];
                
                [self showNotificationBarMessage:STRING_ERROR_SETTING_PAYMENT_METHOD isSuccess:NO];
            }
        }];
    }
}

@end