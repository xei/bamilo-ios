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
                                fieldName: @"address_form[first_name]"
                                andIcon:nil
                                placeholder:@"نام"
                                type:InputTextFieldControlTypeString
                                validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
                                selectOptions:nil];
    
    FormItemModel *lastname = [[FormItemModel alloc]
                           initWithTitle:nil
                           fieldName: @"address_form[last_name]"
                           andIcon:nil
                           placeholder:@"نام خانوادگی"
                           type:InputTextFieldControlTypeString
                           validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
                           selectOptions:nil];
    
    FormItemModel *phone = [[FormItemModel alloc]
                               initWithTitle:nil
                                fieldName: @"address_form[phone]"
                               andIcon:nil
                               placeholder:@"تلفن همراه"
                               type:InputTextFieldControlTypeNumerical
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[NSString mobileRegxPattern]]
                               selectOptions:nil];
    
    
    FormItemModel *address = [[FormItemModel alloc]
                               initWithTitle:nil
                              fieldName: @"address_form[address1]"
                               andIcon:nil
                               placeholder:@"نشانی به فارسی"
                               type:InputTextFieldControlTypeString
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:255 min:2 withRegxPatter:nil]
                               selectOptions:nil];
    
    FormItemModel *postalCode = [[FormItemModel alloc]
                              initWithTitle:nil
                                 fieldName: @"address_form[address2]"
                              andIcon:nil
                              placeholder:@"کد پستی"
                              type:InputTextFieldControlTypeNumerical
                              validation: [[FormItemValidation alloc] initWithRequired:YES max:10 min:10 withRegxPatter:nil]
                              selectOptions:nil];
    
    FormItemModel *region = [[FormItemModel alloc]
                             initWithTitle:@"تهران"
                             fieldName: @"address_form[region]"
                             andIcon:nil
                             placeholder:@"استان"
                             type:InputTextFieldControlTypeOptions
                             validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                             selectOptions:nil];
    
    
    FormItemModel *city = [[FormItemModel alloc]
                             initWithTitle:nil
                           fieldName: @"address_form[city]"
                             andIcon:nil
                             placeholder:@"شهر"
                             type:InputTextFieldControlTypeOptions
                             validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                             selectOptions:nil];
    
    FormItemModel *vicinity = [[FormItemModel alloc]
                             initWithTitle:nil
                               fieldName: @"address_form[postcode]"
                             andIcon:nil
                             placeholder:@"محله"
                             type:InputTextFieldControlTypeOptions
                             validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                             selectOptions:nil];
    
    self.formController.formListModel = [NSMutableArray arrayWithArray:@[name, lastname, phone, postalCode, region, city, vicinity, address]];
    
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

- (void)fieldHasBeenUpdatedByNewValidValue:(NSString *)value inFieldIndex:(NSUInteger)fieldIndex {
    FormItemModel *targetModel = self.formController.formListModel[fieldIndex];
    if([targetModel.fieldName isEqualToString:@"address_form[region]"]) {
        [[DataManager sharedInstance] getCities:self forRegion:[targetModel getValue] completion:^(id data, NSError *error) {
            if (!error) [self bind:data forRequestId:1];
        }];
    } else if ([targetModel.fieldName isEqualToString:@"address_form[city]"]) {
        [[DataManager sharedInstance] getVicinity:self forCity:[targetModel getValue] completion:^(id data, NSError *error) {
            if (!error) [self bind:data forRequestId:2];
        }];
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


- (void)updateSelectOptionModelForFieldIndex:(NSUInteger)fieldIndex withData:(id)data {
    
    FormItemModel *previousModelForIndex = self.formController.formListModel[fieldIndex];
    
    [self.formController updateFieldIndex:fieldIndex WithModel:[[FormItemModel alloc] initWithTitle: previousModelForIndex.titleString
                                                                                        fieldName: previousModelForIndex.fieldName
                                                                                        andIcon: previousModelForIndex.icon
                                                                                        placeholder: previousModelForIndex.placeholder
                                                                                        type: InputTextFieldControlTypeOptions
                                                                                        validation: previousModelForIndex.validation
                                                                                        selectOptions:data]];
}

@end
