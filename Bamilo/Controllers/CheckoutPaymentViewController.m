//
//  CheckoutPaymentViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

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
#import "Bamilo-Swift.h"

typedef NS_OPTIONS(NSUInteger, PaymentMethod) {
    PAYMENT_METHOD_ONLINE = 1 << 0,
    PAYMENT_METHOD_ON_DELIVERY = 1 << 1
};

typedef void(^GetPaymentMethodsCompletion)(NSArray *paymentMethods);

@interface CheckoutPaymentViewController () <RadioButtonViewControlDelegate>
@property (weak, nonatomic) IBOutlet UILabel *noPaymentLabel;
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
    [self.tableView registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil]  forHeaderFooterViewReuseIdentifier:[PlainTableViewHeaderCell nibName]];
    //PaymentTypeTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentTypeTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentTypeTableViewCell nibName]];
    //PaymentOptionWithLogoTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentOptionWithLogoTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentOptionWithLogoTableViewCell nibName]];
    //PaymentOptionTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentOptionTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentOptionTableViewCell nibName]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _selectedPaymentMethodIndex = -1;
    
    [self.noPaymentLabel applyStyle:[Theme font:kFontVariationRegular size:13] color:[Theme color:kColorGray1]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_paymentMethods == nil) {
        [self getContent:nil];
    }
}

- (void)getContent:(void(^)(BOOL))callBack {
    [self recordStartLoadTime];
    [self getPaymentMethods:^(NSArray *paymentMethods) {
        [self selectProperPaymentMethodFromMethods:paymentMethods];
        [self publishScreenLoadTimeWithName:[self getScreenName] withLabel:@""];
    }];
}

- (void)selectProperPaymentMethodFromMethods: (NSArray *)paymentMethods {
    if(paymentMethods.count) {
        self.noPaymentLabel.text = nil;
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
    } else {
        [LoadingManager hideLoading];
        RIPaymentMethodFormField *paymentField = self.cart.formEntity.paymentMethodForm.fields.firstObject;
         self.noPaymentLabel.text = paymentField.label;
        
        //set MutiStep
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[RIPaymentMethodForm getParametersForForm:self.cart.formEntity.paymentMethodForm]];
        [self setMultistepPayment:params completion:nil];
    }
}

#pragma mark - Overrides
- (NSString *)getTitleForContinueButton {
    return STRING_CONFIRM_AND_PAY;
}

- (NSString *)getNextStepViewControllerSegueIdentifier:(NSString *)serviceIdentifier {
    return nil;
}

- (void)performPreDepartureAction:(CheckoutActionCompletion)completion {
    if([_multistepEntity.nextStep isEqualToString:@"finish"] && completion != nil) {
        [DataAggregator setMultistepConfirmation:self cart:self.cart completion:^(id data, NSError *error) {
            if(error == nil) {
                [self bind:data forRequestId:1];
                NSDictionary *userInfo = @{ kCart : self.cart };
                if(self.cart.paymentInformation.type == RIPaymentInformationCheckoutEnded) {
                    [self setHidesBottomBarWhenPushed:NO];
                    [self performSegueWithIdentifier:NSStringFromClass([SuccessPaymentViewController class]) sender:nil];
                    [self setHidesBottomBarWhenPushed:YES];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutExternalPaymentsScreenNotification object:nil userInfo:userInfo];
                }
                completion(_multistepEntity.nextStep, YES);
            } else {
                if (![Utility handleErrorMessagesWithError:error viewController:self]) {
                    [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
                }
                //EVENT : PURCHASE
                [TrackerManager postEventWithSelector:[EventSelectors purchaseSelector] attributes:[EventAttributes purchaseWithCart:self.cart success:YES]];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            PlainTableViewHeaderCell *plainTableViewHeaderCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[PlainTableViewHeaderCell nibName]];
            plainTableViewHeaderCell.titleString = STRING_PAYMENT_OPTION;
            return plainTableViewHeaderCell;
        }
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - RadioButtonViewControlDelegate
- (void)didSelectRadioButton:(id)sender {
    if([sender isKindOfClass:[PaymentTypeTableViewCell class]]) {
        PaymentTypeTableViewCell *radioButtonPaymentTypeTableViewCell = (PaymentTypeTableViewCell *)sender;
        [self setPaymentMethod:(int)radioButtonPaymentTypeTableViewCell.tag];
    }
}

#pragma mark - CheckoutProgressViewDelegate
- (NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE]
    ];
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    [self removeErrorView];
    switch (rid) {
        case 0:
        case 1:
        case 2:
            self.cart = (RICart *)data;
        break;
    }
}

- (void)errorHandler:(NSError *)error forRequestID:(int)rid {
    if (rid == 0) {
        if (![Utility handleErrorMessagesWithError:error viewController:self]) {
            [self handleGenericErrorCodesWithErrorControlView:(int)error.code forRequestID:rid];
        }
    }
}

- (void)retryAction:(RetryHandler)callBack forRequestId:(int)rid {
    [self getContent:^(BOOL success) {
        callBack(success);
    }];
}

#pragma mark - DataTrackerProtocol
- (NSString *)getScreenName {
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
- (void)getPaymentMethods:(GetPaymentMethodsCompletion)completion {
    [DataAggregator getMultistepPayment:self completion:^(id data, NSError *error) {
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
        } else {
            [self errorHandler:error forRequestID:0];
        }
    }];
}

- (void)setPaymentMethod:(int)selectedPaymentMethodIndex {
    RIPaymentMethodFormOption *selectedPaymentMethod = [_paymentMethods objectAtIndex:selectedPaymentMethodIndex];
    RIPaymentMethodFormField *field = [self.cart.formEntity.paymentMethodForm.fields firstObject];
    if (VALID_NOTEMPTY(field, RIPaymentMethodFormField)) {
        field.value = selectedPaymentMethod.value;
    }
    
    if (selectedPaymentMethod && self.cart.cartEntity.cartValue) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[RIPaymentMethodForm getParametersForForm:self.cart.formEntity.paymentMethodForm]];
        JACheckoutForms *checkoutFormForPaymentMethod = [[JACheckoutForms alloc] initWithPaymentMethodForm:self.cart.formEntity.paymentMethodForm width:0.0];
        [params addEntriesFromDictionary:[checkoutFormForPaymentMethod getValuesForPaymentMethod:selectedPaymentMethod]];
        [self setMultistepPayment:params completion:^{
            _selectedPaymentMethodIndex = selectedPaymentMethodIndex;
        }];
    }
}

- (void)setMultistepPayment:(NSDictionary *)params completion:(void(^)(void))completion {
    [DataAggregator setMultistepPayment:self params:params completion:^(id data, NSError *error) {
        if(error == nil) {
            _multistepEntity = (MultistepEntity *)data;
            [DataAggregator getMultistepConfirmation:self completion:^(id data, NSError *error) {
                if(error == nil) {
                    [self bind:data forRequestId:2];
                    [self.cartEntitySummaryViewControl updateWithModel:self.cart.cartEntity];
                    [ThreadManager executeOnMainThread:^{
                        [self.tableView reloadData];
                    }];
                    if (completion) completion();
                }
            }];
        } else {
            [self showNotificationBarMessage:STRING_ERROR_SETTING_PAYMENT_METHOD isSuccess:NO];
            if (completion) completion();
        }
    }];
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_PAYMENT_OPTION;
}


@end
