//
//  AddressEditViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//


#import "AddressEditViewController.h"
#import "Bamilo-Swift.h"
#import "LoadingManager.h"
#import "CheckoutAddressViewController.h"

@interface AddressEditViewController () <DataServiceProtocol>
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) FormViewControl *formController;
@property (nonatomic, strong) NSDictionary *regionOptionsDictionary;
@property (nonatomic, strong) NSDictionary *cityOptionsDictionary;
@property (nonatomic, strong) NSDictionary *vicinityOptionsDictionary;
@end

@implementation AddressEditViewController {
@private
    FormItemModel *region, *city, *vicinity, *gender;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBarConfigs];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = STRING_ADDRESS;
    [self setupView];
}


- (void)setNavigationBarConfigs {

    //custom back button to behave customly
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_back"] style:UIBarButtonItemStylePlain target:self action: self.comesFromEmptyList ? @selector(twoStepBackNavigation): @selector(backAction)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)twoStepBackNavigation {
    [self.navigationController popToRootViewControllerAnimated:YES]; //back to cart
}

- (void)setupView {
    self.formController = [[FormViewControl alloc] init];
    self.formController.submitTitle = @"ذخیره آدرس";
    self.formController.delegate = self;
    self.formController.tableView = self.tableView;
    
    self.formController.formModelList = [NSMutableArray new];
    
    //ADDRESS - USER ADDRESS SECTION
    FormHeaderModel *addressHeader = [[FormHeaderModel alloc] initWithHeaderTitle:STRING_ADDRESS];
    region = [[FormItemModel alloc] initWithTextValue: (self.address.uid) ? @"": @"تهران" fieldName: @"address_form[region]" andIcon: nil placeholder: @"استان" type: InputTextFieldControlTypeOptions validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil] selectOptions: nil];
    
    city = [[FormItemModel alloc] initWithTextValue:nil fieldName: @"address_form[city]" andIcon:nil placeholder: STRING_CITY type: InputTextFieldControlTypeOptions validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil] selectOptions:nil];
    
    vicinity = [[FormItemModel alloc] initWithTextValue: nil fieldName: @"address_form[postcode]" andIcon: nil placeholder: @"محله" type: InputTextFieldControlTypeOptions validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil] selectOptions: nil];
    vicinity.validation.isRequired = NO;
    
    FormItemModel *address = [FormItemModel addressWithFieldName:@"address_form[address1]"];
    FormItemModel *postalCode = [FormItemModel postalCodeWithFieldName:@"address_form[address2]"];
    postalCode.validation.isRequired = NO;
    
    [self.formController.formModelList addObjectsFromArray:@[ addressHeader, region, city, vicinity, address, postalCode ]];
    
    //ADDRESS - USER INFO SECTION
    FormHeaderModel *personalInfoHeader = [[FormHeaderModel alloc] initWithHeaderTitle:STRING_RECIPIENT_INFO];
    
    FormItemModel *firstName = [FormItemModel firstNameFieldWithFiedName:@"address_form[first_name]"];
    FormItemModel *lastName = [FormItemModel lastNameWithFieldName:@"address_form[last_name]"];
    FormItemModel *phone = [FormItemModel phoneWithFieldName:@"address_form[phone]"];
    
    if(self.address == nil) {
        [CurrentUserManager loadLocal];
        //Adding a new address. Try to pre-fill user info
        User *customer = CurrentUserManager.user;
        
        [firstName setInputTextValue:customer.firstName];
        [lastName setInputTextValue:customer.lastName];
        [phone setInputTextValue:customer.phone];
    }
    
    [self.formController.formModelList addObjectsFromArray:@[ personalInfoHeader, firstName, lastName, phone ]];
    if (![CurrentUserManager.user getGender] && self.address == nil) {
        gender = [FormItemModel genderWithFieldName:@"address_form[gender]"];
        [self.formController.formModelList addObject: gender];
    }
    [self.formController.formModelList addObject:@"submit"];
    [self.formController setupTableView];
    if (!self.address.uid) {
        // Get regions and citiies for region defualt value (if exists)
        [self getRegionsByCompletion:^(BOOL success){
            if (region.inputTextValue) {
                [self getCitiesForRegionId:[region getValue] completion: nil];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.formController registerForKeyboardNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.address.uid) {
        [self getAddressByID:self.address.uid];
    }
    //pop this view controller if user is not logged in
    if (![CurrentUserManager isUserLoggedIn]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.formController unregisterForKeyboardNotifications];
}

#pragma mark - FormViewControlDelegate
- (void)formSubmitButtonTapped {
    if (![self.formController isFormValid]) {
        [self.formController showAnyErrorInForm];
        return;
    }
    
    if (VALID_NOTEMPTY(gender, [FormItemModel class])) {
        //update local user object's gender
        if (VALID_NOTEMPTY(CurrentUserManager.user.password, [NSString class])) {
            [CurrentUserManager.user setGenderWithGender:[gender getValue]];
            [CurrentUserManager saveUserWithUser:CurrentUserManager.user plainPassword:CurrentUserManager.user.password];
        }
    }
    
    NSMutableDictionary *params = [self.formController getMutableDictionaryOfForm];
    if(self.address.uid) {
        //EDIT / UPDATE ADDRESS
        params[@"address_form[id]"] = self.address.uid;
        [DataAggregator updateAddress:self params:params addressId:self.address.uid completion:^(id data, NSError *error) {
            if (error == nil) {
                [TrackerManager postEventWithSelector:[EventSelectors editAddressSelector] attributes:[EventAttributes editAdressWithAddress:self.address]];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                if(![self showNotificationBar:error isSuccess:NO]) {
                    BOOL errorHandled = NO;
                    for(NSDictionary* errorField in [error.userInfo objectForKey: kErrorMessages]) {
                        NSString *fieldName = [NSString stringWithFormat:@"address_form[%@]", errorField[@"field"]];
                        if ([self.formController showErrorMessageForField:fieldName errorMsg: errorField[kMessage]]) {
                            errorHandled = YES;
                        }
                    }
                    if (!errorHandled){
                        [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
                    }
                }
            }
        }];
    } else {
        //ADD NEW ADDRESS
        params[@"address_form[id]"] = @"";
        params[@"address_form[is_default_shipping]"] = @YES;
        params[@"address_form[is_default_billing]"] = @YES;
        [DataAggregator addAddress:self params:params completion:^(id data, NSError *error) {
            if (error == nil) {
                [TrackerManager postEventWithSelector:[EventSelectors addAddressSelector] attributes:[EventAttributes addAddress]];
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                if(![self showNotificationBar:error isSuccess:NO]) {
                    BOOL errorHandled = NO;
                    for(NSDictionary* errorField in [error.userInfo objectForKey:kErrorMessages]) {
                        NSString *fieldNameParam = [errorField objectForKey:@"field"];
                        if ([fieldNameParam isKindOfClass:[NSString class]] && fieldNameParam.length > 0) {
                            NSString *fieldName = [NSString stringWithFormat:@"address_form[%@]", fieldNameParam];
                            if ([self.formController showErrorMessageForField:fieldName errorMsg: errorField[kMessage]]) {
                                errorHandled = YES;
                            }
                        }
                    }
                    if (!errorHandled) {
                        [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
                    }
                }
            }
        }];
    }
}

#pragma mark - FormViewControlDelegate
- (void)fieldHasBeenUpdatedByNewValidValue:(NSString *)value inFieldIndex:(NSUInteger)fieldIndex {
    FormItemModel *targetModel = self.formController.formModelList[fieldIndex];
    if([targetModel.fieldName isEqualToString:@"address_form[region]"]) {
        [self getCitiesForRegionId:[targetModel getValue] completion:nil];
    } else if ([targetModel.fieldName isEqualToString:@"address_form[city]"]) {
        [self getVicinitiesForCityId:[targetModel getValue] completion:nil];
    }
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0: //all regions have been received
            [self updateSelectOptionModelForFieldIndex:[self.formController.formModelList indexOfObject:region] withData:data];
            break;
        case 1: //all cities of `region` have been receive
            [self updateSelectOptionModelForFieldIndex:[self.formController.formModelList indexOfObject:city] withData:data];
            break;
        case 2: //all vicinities of `city` have been receive
            [self updateSelectOptionModelForFieldIndex:[self.formController.formModelList indexOfObject:vicinity] withData:data];
            break;
        case 3: //address object have been received for editing
            [self updateFormValuesWithAddress:data];
        default:
            break;
    }
}

- (void)retryAction:(RetryHandler)callBack forRequestId:(int)rid {
    if (self.address.uid && rid == 3) {
        [self getAddressByID:self.address.uid];
        callBack(YES);
    }
}

- (void)errorHandler:(NSError *)error forRequestID:(int)rid {
    if (![Utility handleErrorMessagesWithError:error viewController:self]) {
        [self handleGenericErrorCodesWithErrorControlView:(int)error.code forRequestID:rid];
    }
}

#pragma ArgsReceiverProtocol
-(void)updateWithArgs:(NSDictionary *)args {
    Address *address = [args objectForKey:kAddress];
    if(address) {
        self.address = address;
    }
}

#pragma mark - Helpers
- (void)getAddressByID: (NSString *)uid {
    [DataAggregator getAddress:self id:uid completion:^(id data, NSError *error) {
        if (error == nil) {
            [self bind:data forRequestId:3];
        } else {
            [self errorHandler:error forRequestID:3];
        }
    }];
}

- (void)updateSelectOptionModelForFieldIndex:(NSUInteger)fieldIndex withData:(id)data {
    [self.formController updateFieldIndex:fieldIndex WithUpdateModelBlock:^FormItemModel *(FormItemModel *model) {
        model.selectOption = data;
        if ([model getValue] == nil) {
            model.inputTextValue = nil;
        }
        return model;
    }];
    [self.formController refreshView];
}

- (void)updateFormValuesWithAddress:(Address *)address {
    NSDictionary <NSString*, NSString*> *addressFieldMapValues = @{
                                                                   @"address_form[first_name]"   : address.firstName ?: @"",
                                                                   @"address_form[last_name]"    : address.lastName ?: @"",
                                                                   @"address_form[phone]"        : address.phone ?: @"",
                                                                   @"address_form[address1]"     : address.address ?: @"",
                                                                   @"address_form[address2]"     : address.address1 ?: @"",
                                                                   @"address_form[region]"       : address.region ?: @"",
                                                                   @"address_form[city]"         : address.city ?: @"",
                                                                   @"address_form[postcode]"     : address.postcode ?: @""
                                                                   };
    
    [self.formController.formModelList enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[FormItemModel class]]) {
            [self.formController updateFieldIndex:idx WithUpdateModelBlock:^FormItemModel *(FormItemModel *model) {
                model.inputTextValue = addressFieldMapValues[model.fieldName];
                return model;
            }];
        }
    }];
    
    [self.formController refreshView];
    [self getRegionsByCompletion:^(BOOL success){
        if (addressFieldMapValues[@"address_form[region]"].length) {
            [self getCitiesForRegionId:[region getValue] completion:^{
                if (addressFieldMapValues[@"address_form[city]"]) {
                    [self getVicinitiesForCityId:[city getValue] completion:nil];
                }
            }];
        }
    }];
    self.address = address;
}



- (void)getRegionsByCompletion:(void (^)(BOOL))completion {
    [DataAggregator getRegions:self completion:^(id data, NSError *error) {
        if (!error) {
            [self bind:data forRequestId:0];
            if(completion) completion(YES);
        } else {
            if(completion) completion(NO);
            if (![Utility handleErrorMessagesWithError:error viewController:self]) {
                [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
            }
        }
    }];
}

- (void)getCitiesForRegionId:(NSString *)regionId completion:(void (^)(void))completion {
    [DataAggregator getCities:self regionId:regionId completion:^(id data, NSError *error) {
        if (!error) {
            [self bind:data forRequestId:1];
            if (completion) completion();
        } else {
            if(![Utility handleErrorMessagesWithError:error viewController:self]) {
                [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
            }
        }
    }];
}

- (void)getVicinitiesForCityId:(NSString *)cityId completion:(void (^)(void))completion {
    [DataAggregator getVicinity:self cityId:cityId completion:^(id data, NSError *error) {
        if (!error) {
            [self bind:data forRequestId:2];
            if (completion) completion();
        } else {
            if(![Utility handleErrorMessagesWithError:error viewController:self]) {
                [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
            }
        }
    }];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    if(self.address.uid) {
        return @"EditAddress";
    } else {
        return @"AddAddress";
    }
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_MY_ADDRESSES;
}
@end
