	//
//  AddressEditViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//


#import "AddressEditViewController.h"
#import "Bamilo-Swift.h"

@interface AddressEditViewController () <DataServiceProtocol>
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) FormViewControl *formController;
@property (nonatomic, strong) NSDictionary *regionOptionsDictionary;
@property (nonatomic, strong) NSDictionary *cityOptionsDictionary;
@property (nonatomic, strong) NSDictionary *vicinityOptionsDictionary;
@end

@implementation AddressEditViewController {
@private
    FormItemModel *region, *city, *vicinity;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = STRING_ADDRESS;    
    [self setupView];
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
    
    city = [[FormItemModel alloc] initWithTextValue:nil fieldName: @"address_form[city]" andIcon:nil placeholder: @"شهر" type: InputTextFieldControlTypeOptions validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil] selectOptions:nil];

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
        //Adding a new address. Try to pre-fill user info
        RICustomer *customer = [RICustomer getCurrentCustomer];
        
        [firstName setInputTextValue:customer.firstName];
        [lastName setInputTextValue:customer.lastName];
        [phone setInputTextValue:customer.phone];
    }
    
    [self.formController.formModelList addObjectsFromArray:@[ personalInfoHeader, firstName, lastName, phone ]];
    
    if (![RICustomer getCustomerGender] && self.address == nil) {
        FormItemModel *gender = [FormItemModel genderWithFieldName:@"address_form[gender]"];
        [self.formController.formModelList addObject:gender];
    }
    
    [self.formController setupTableView];
    
    if (!self.address.uid) {
        // Get regions and citiies for region defualt value (if exists)
        [self getRegionsByCompletion:^{
            if (region.inputTextValue) {
                [self getCitiesForRegionId:[region getValue] completion: nil];
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.formController registerForKeyboardNotifications];
    if(self.address.uid == nil) {
        [self publishScreenLoadTime];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.address.uid) {
        [self getAddressByID:self.address.uid];
    }
    
    
    //pop this view controller if user is not logged in
    if ([RICustomer checkIfUserIsLogged]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.formController unregisterForKeyboardNotifications];
}

#pragma mark - Overrides
- (void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.title = STRING_MY_ADDRESSES;
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
}

#pragma mark - FormViewControlDelegate
- (void)formSubmitButtonTapped {
    if (![self.formController isFormValid]) {
        [self.formController showAnyErrorInForm];
        return;
    }
    
    NSMutableDictionary *params = [self.formController getMutableDictionaryOfForm];
    if(self.address.uid) {
        //EDIT / UPDATE ADDRESS
        params[@"address_form[id]"] = self.address.uid;
        [DataAggregator updateAddress:self params:params addressId:self.address.uid completion:^(id data, NSError *error) {
            if (error == nil) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                if(![self showNotificationBar:error isSuccess:NO]) {
                    for(NSDictionary* errorField in [error.userInfo objectForKey:@"errorMessages"]) {
                        NSString *fieldName = [NSString stringWithFormat:@"address_form[%@]", errorField[@"field"]];
                        [self.formController showErrorMessageForField:fieldName errorMsg:errorField[@"message"]];
                    }
                }
            }
        }];
    } else {
        //ADD NEW ADDRESS
        params[@"address_form[id]"] = @"";
        [DataAggregator addAddress:self params:params completion:^(id data, NSError *error) {
            if (error == nil) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                if(![self showNotificationBar:error isSuccess:NO]) {
                    for(NSDictionary* errorField in [error.userInfo objectForKey:kErrorMessages]) {
                        NSString *fieldName = [NSString stringWithFormat:@"address_form[%@]", errorField[@"field"]];
                        [self.formController showErrorMessageForField:fieldName errorMsg:errorField[kMessage]];
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
            [self publishScreenLoadTime];
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
    [self getRegionsByCompletion:^{
        if (addressFieldMapValues[@"address_form[region]"].length) {
            [self getCitiesForRegionId:[region getValue]  completion:^{
                if (addressFieldMapValues[@"address_form[city]"]) {
                    [self getVicinitiesForCityId:[city getValue] completion:nil];
                }
            }];
        }
    }];
    self.address = address;
}



- (void)getRegionsByCompletion:(void (^)(void))completion {
    [DataAggregator getRegions:self completion:^(id data, NSError *error) {
        if (!error)  {
            [self bind:data forRequestId:0];
            if(completion) completion();
        }
    }];
}

- (void)getCitiesForRegionId:(NSString *)regionId completion:(void (^)(void))completion {
    [DataAggregator getCities:self regionId:regionId completion:^(id data, NSError *error) {
        if (!error) {
            [self bind:data forRequestId:1];
            if (completion) completion();
        }
    }];
}

- (void)getVicinitiesForCityId:(NSString *)cityId completion:(void (^)(void))completion {
    [DataAggregator getVicinity:self cityId:cityId completion:^(id data, NSError *error) {
        if (!error) {
            [self bind:data forRequestId:2];
            if (completion) completion();
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

@end
