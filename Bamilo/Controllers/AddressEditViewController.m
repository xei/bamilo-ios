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
    
    self.formController = [[FormViewControl alloc] init];
    self.formController.submitTitle = @"ذخیره آدرس";
    self.formController.delegate = self;
    self.formController.tableView = self.tableView;
    
    FormItemModel *name = [[FormItemModel alloc]
                                initWithTitle:nil
                                andIcon:nil
                                placeholder:@"نام"
                                type:InputTextFieldControlTypeString
                                validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
                                selectOptions:nil];
    
    FormItemModel *lastname = [[FormItemModel alloc]
                           initWithTitle:nil
                           andIcon:nil
                           placeholder:@"نام خانوادگی"
                           type:InputTextFieldControlTypeString
                           validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
                           selectOptions:nil];
    
    FormItemModel *phone = [[FormItemModel alloc]
                               initWithTitle:nil
                               andIcon:nil
                               placeholder:@"تلفن همراه"
                               type:InputTextFieldControlTypeNumerical
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[NSString mobileRegxPattern]]
                               selectOptions:nil];
    
    
    FormItemModel *address = [[FormItemModel alloc]
                               initWithTitle:nil
                               andIcon:nil
                               placeholder:@"نشانی به فارسی"
                               type:InputTextFieldControlTypeString
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:255 min:2 withRegxPatter:nil]
                               selectOptions:nil];
    
    FormItemModel *postalCode = [[FormItemModel alloc]
                              initWithTitle:nil
                              andIcon:nil
                              placeholder:@"کد پستی"
                              type:InputTextFieldControlTypeNumerical
                              validation: [[FormItemValidation alloc] initWithRequired:YES max:10 min:10 withRegxPatter:nil]
                              selectOptions:nil];
    
    FormItemModel *region = [[FormItemModel alloc]
                             initWithTitle:@"تهران"
                             andIcon:nil
                             placeholder:@"استان"
                             type:InputTextFieldControlTypeOptions
                             validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                             selectOptions:nil];
    
    FormItemModel *city = [[FormItemModel alloc]
                             initWithTitle:nil
                             andIcon:nil
                             placeholder:@"شهر"
                             type:InputTextFieldControlTypeOptions
                             validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                             selectOptions:nil];
    
    FormItemModel *vicinity = [[FormItemModel alloc]
                             initWithTitle:nil
                             andIcon:nil
                             placeholder:@"محله"
                             type:InputTextFieldControlTypeOptions
                             validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                             selectOptions:nil];
    
    self.formController.formItemListModel = [NSMutableDictionary dictionaryWithDictionary: @{
                                                                                             @"address_form[first_name]": name,
                                                                                             @"address_form[last_name]" : lastname,
                                                                                             @"address_form[phone]"     : phone,
                                                                                             @"address_form[address2]"  : postalCode,
                                                                                             @"address_form[region]"    : region,
                                                                                             @"address_form[city]"      : city,
                                                                                             @"address_form[postcode]"  : vicinity,
                                                                                             @"address_form[address1]"  : address
                                                                                             }];
    
    [self.formController setupTableView];
    
    [[DataManager sharedInstance] getRegions:self completion:^(id data, NSError *error) {
        if (!error) [self bind:data forRequestId:0];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.formController registerForKeyboardNotifications];
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
        return;
    }
    
}

- (void)viewNeedsToEndEditing {
    [self.view endEditing:YES];
}

#pragma mark - FormViewControlDelegate
- (void)fieledHasBeenUpdatedByNewValidValue:(NSString *)value inFieldName:(NSString *)fieldname {
    if([fieldname isEqualToString:@"address_form[region]"]) {
        [[DataManager sharedInstance] getCities:self forRegion:[self.formController.formItemListModel[fieldname] getValue] completion:^(id data, NSError *error) {
            if (!error) [self bind:data forRequestId:1];
        }];
    } else if ([fieldname isEqualToString:@"address_form[city]"]) {
        [[DataManager sharedInstance] getVicinity:self forCity:[self.formController.formItemListModel[fieldname] getValue] completion:^(id data, NSError *error) {
            if (!error) [self bind:data forRequestId:2];
        }];
    }
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    switch (rid) {
        case 0:
            [self updateSelectOptionModelForFieldName:@"address_form[region]" withData:data];
            break;
        case 1:
            [self updateSelectOptionModelForFieldName:@"address_form[city]" withData:data];
            break;
        case 2:
            [self updateSelectOptionModelForFieldName:@"address_form[postcode]" withData:data];
            break;
        default:
            break;
    }
}


- (void)updateSelectOptionModelForFieldName:(NSString *)fieldName withData:(id)data {
    [self.formController updateFieldName:fieldName
                               WithModel:[[FormItemModel alloc] initWithTitle:self.formController.formItemListModel[fieldName].titleString
                                                                andIcon:nil
                                                                placeholder:self.formController.formItemListModel[fieldName].placeholder
                                                                type:InputTextFieldControlTypeOptions
                                                                validation: self.formController.formItemListModel[fieldName].validation
                                                                selectOptions:data]];
}

@end
