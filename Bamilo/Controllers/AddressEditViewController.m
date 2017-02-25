//
//  AddressEditViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//


#import "AddressEditViewController.h"
#import "DataManager.h"

@interface AddressEditViewController () <DataServiceProtocol>
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) FormViewControl *formController;
@property (nonatomic, strong) NSDictionary *regionOptionsDictionary;
@property (nonatomic, strong) NSDictionary *cityOptionsDictionary;
@property (nonatomic, strong) NSDictionary *vicinityOptionsDictionary;
@end

@implementation AddressEditViewController

const int RegionFieldIndex = 4;
const int CityFieldIndex = 5;
const int VicinityFieldIndex = 6;

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
    
    FormItemModel *name = [FormItemModel nameFieldWithFiedName:@"address_form[first_name]"];
    FormItemModel *lastname = [FormItemModel lastNameWithFieldName:@"address_form[last_name]"];
    FormItemModel *phone = [FormItemModel phoneWithFieldName:@"address_form[phone]"];
    FormItemModel *address = [FormItemModel addressWithFieldName:@"address_form[address1]"];
    FormItemModel *postalCode = [FormItemModel postalCodeWithFieldName:@"address_form[address2]"];
    postalCode.validation.isRequired = NO;
    
    FormItemModel *region = [[FormItemModel alloc] initWithTitle: nil
                                                       fieldName: @"address_form[region]"
                                                         andIcon: nil
                                                     placeholder: @"استان"
                                                            type: InputTextFieldControlTypeOptions
                                                      validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                                                   selectOptions: nil];
    
    
    FormItemModel *city = [[FormItemModel alloc] initWithTitle: nil
                                                     fieldName: @"address_form[city]"
                                                       andIcon: nil
                                                   placeholder: @"شهر"
                                                          type: InputTextFieldControlTypeOptions
                                                    validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                                                 selectOptions: nil];

    
    FormItemModel *vicinity = [[FormItemModel alloc] initWithTitle: nil
                                                         fieldName: @"address_form[postcode]"
                                                           andIcon: nil
                                                       placeholder: @"محله"
                                                              type: InputTextFieldControlTypeOptions
                                                        validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                                                     selectOptions: nil];
    
    self.formController.formListModel = [NSMutableArray arrayWithArray:@[name, lastname, phone, postalCode, address]];
    
    [self.formController.formListModel insertObject:region atIndex:RegionFieldIndex];
    [self.formController.formListModel insertObject:city atIndex:CityFieldIndex];
    [self.formController.formListModel insertObject:vicinity atIndex:VicinityFieldIndex];
    
    [self.formController setupTableView];
    
    if (!self.address.uid) {
        [self getRegionsByCompletion:nil];
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
    params[@"address_form[id]"] = self.address.uid;
    params[@"address_form[is_default_shipping]"] = @(self.address.isDefaultShipping);
    params[@"address_form[is_default_billing]"] = @(self.address.isDefaultBilling);
    
    [[DataManager sharedInstance] updateAddress:self params:params withID:self.address.uid completion:^(id data, NSError *error) {
        if (error == nil) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            if(![self showNotificationBar:error isSuccess:NO]) {
                for(NSDictionary* errorField in [error.userInfo objectForKey:@"errorMessages"]) {
                    NSString *fieldName = [NSString stringWithFormat:@"address_form[%@]", errorField[@"field"]];
                    [self.formController showErrorMessgaeForField:fieldName errorMsg:errorField[@"message"]];
                }
            }
        }
    }];
}

#pragma mark - FormViewControlDelegate
- (void)fieldHasBeenUpdatedByNewValidValue:(NSString *)value inFieldIndex:(NSUInteger)fieldIndex {
    FormItemModel *targetModel = self.formController.formListModel[fieldIndex];
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
            [self updateSelectOptionModelForFieldIndex:RegionFieldIndex withData:data];
            break;
        case 1: //all cities of `region` have been receive
            [self updateSelectOptionModelForFieldIndex:CityFieldIndex withData:data];
            break;
        case 2: //all vicinities of `city` have been receive
            [self updateSelectOptionModelForFieldIndex:VicinityFieldIndex withData:data];
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
    [[DataManager sharedInstance] getAddress:self byId:uid completion:^(id data, NSError *error) {
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
            model.titleString = nil;
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
    [self.formController.formListModel enumerateObjectsUsingBlock:^(FormItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.formController updateFieldIndex:idx WithUpdateModelBlock:^FormItemModel *(FormItemModel *model) {
            model.titleString = addressFieldMapValues[model.fieldName];
            return model;
        }];
    }];
    [self.formController refreshView];
    [self getRegionsByCompletion:^{
        if (addressFieldMapValues[@"address_form[region]"].length) {
            [self getCitiesForRegionId:[self.formController.formListModel[RegionFieldIndex] getValue]  completion:^{
                if (addressFieldMapValues[@"address_form[city]"]) {
                    [self getVicinitiesForCityId:[self.formController.formListModel[CityFieldIndex] getValue] completion:nil];
                }
            }];
        }
    }];
}



- (void)getRegionsByCompletion:(void (^)(void))completion {
    [[DataManager sharedInstance] getRegions:self completion:^(id data, NSError *error) {
        if (!error)  {
            [self bind:data forRequestId:0];
            if(completion) completion();
        }
    }];
}

- (void)getCitiesForRegionId:(NSString *)regionId completion:(void (^)(void))completion {
    [[DataManager sharedInstance] getCities:self forRegionId:regionId completion:^(id data, NSError *error) {
        if (!error) {
            [self bind:data forRequestId:1];
            if (completion) completion();
        }
    }];
}

- (void)getVicinitiesForCityId:(NSString *)cityId completion:(void (^)(void))completion {
    [[DataManager sharedInstance] getVicinity:self forCityId:cityId completion:^(id data, NSError *error) {
        if (!error) {
            [self bind:data forRequestId:2];
            if (completion) completion();
        }
    }];
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    if(self.address.uid) {
        return @"EditAddress";
    } else {
        return @"AddAddress";
    }
}

@end
