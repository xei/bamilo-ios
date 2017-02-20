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
    
    FormItemModel *region = [[FormItemModel alloc] initWithTitle: @"تهران"
                                                       fieldName: @"address_form[region]"
                                                         andIcon: nil
                                                     placeholder: @"استان"
                                                            type: InputTextFieldControlTypeOptions
                                                      validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                                                   selectOptions: @{@"تهران": @"336"}];
    
    
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
    
    self.formController.formListModel = [NSMutableArray arrayWithArray:@[name, lastname, phone, postalCode, region, city, vicinity, address]];
    [self.formController setupTableView];
    
    [self getRegions];
    //Check if additional data is required
    if (region.titleString) {
        [self getCitiesForRegionName:[region getValue]];
    }
    if (city.titleString) {
        [self getVicinitiesForCityName:[city getValue]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.formController registerForKeyboardNotifications];
    
    [self publishScreenLoadTime];
}

- (void)viewDidDisappear:(BOOL)animated {
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
- (void)submitBtnTapped {
    if (![self.formController isFormValid]) {
        [self.formController showAnyErrorInForm];
        return;
    }
    
    [[DataManager sharedInstance] submitAddress:self params:[self.formController getMutableDictionaryOfForm] withID:nil completion:^(id data, NSError *error) {
        if (error == nil) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showNotificationBar:error isSuccess:NO];
            /*for(NSDictionary* errorField in [error.userInfo objectForKey:@"errorMessages"]) {
                NSString *fieldName = [NSString stringWithFormat:@"address_form[%@]", errorField[@"field"]];
                [self.formController showErrorMessgaeForField:fieldName errorMsg:errorField[@"message"]];
            }*/
        }
    }];
}

#pragma mark - FormViewControlDelegate
- (void)fieldHasBeenUpdatedByNewValidValue:(NSString *)value inFieldIndex:(NSUInteger)fieldIndex {
    FormItemModel *targetModel = self.formController.formListModel[fieldIndex];
    if([targetModel.fieldName isEqualToString:@"address_form[region]"]) {
        [self getCitiesForRegionName:[targetModel getValue]];
    } else if ([targetModel.fieldName isEqualToString:@"address_form[city]"]) {
        [self getVicinitiesForCityName:[targetModel getValue]];
    }
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0:
            [self updateSelectOptionModelForFieldIndex:4 withData:data];
            break;
        case 1:
            [self updateSelectOptionModelForFieldIndex:5 withData:data];
            break;
        case 2:
            [self updateSelectOptionModelForFieldIndex:6 withData:data];
            break;
        default:
            break;
    }
}

#pragma mark - helper function
- (void)updateSelectOptionModelForFieldIndex:(NSUInteger)fieldIndex withData:(id)data {
    FormItemModel *previousModelForIndex = self.formController.formListModel[fieldIndex];
    [self.formController updateFieldIndex:fieldIndex WithModel:[[FormItemModel alloc] initWithTitle: previousModelForIndex.titleString
                                                                                          fieldName: previousModelForIndex.fieldName
                                                                                            andIcon: previousModelForIndex.icon
                                                                                        placeholder: previousModelForIndex.placeholder
                                                                                               type: InputTextFieldControlTypeOptions
                                                                                         validation: previousModelForIndex.validation
                                                                                      selectOptions: data]];
}

- (void)getRegions {
    [[DataManager sharedInstance] getRegions:self completion:^(id data, NSError *error) {
        if (!error) [self bind:data forRequestId:0];
    }];
}

- (void)getCitiesForRegionName:(NSString *)region {
    [[DataManager sharedInstance] getCities:self forRegion:region completion:^(id data, NSError *error) {
        if (!error) [self bind:data forRequestId:1];
    }];
}

- (void)getVicinitiesForCityName:(NSString *)city {
    [[DataManager sharedInstance] getVicinity:self forCity:city completion:^(id data, NSError *error) {
        if (!error) [self bind:data forRequestId:2];
    }];
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    if(self.addressUID) {
        return @"EditAddress";
    } else {
        return @"AddAddress";
    }
}

@end
