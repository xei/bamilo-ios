//
//  AddressEditViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//


#import "AddressEditViewController.h"

@interface AddressEditViewController ()
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) FormViewControl *formController;
@end

@implementation AddressEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.formController.submitTitle = @"ذخیره آدرس";
    self.title = STRING_ADDRESS;
    
    self.formController = [[FormViewControl alloc] init];
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
    
    FormItemModel *gender = [[FormItemModel alloc]
                                 initWithTitle:nil
                                 andIcon:nil
                                 placeholder:@"جنسیت"
                                 type:InputTextFieldControlTypeOptions
                                 validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                                 selectOptions:@{@"مرد": @"male", @"زن": @"female"}];
    
    self.formController.formItemListModel = @{
                                              @"address_form[first_name]": name,
                                              @"address_form[last_name]" : lastname,
                                              @"address_form[phone]"     : phone,
                                              @"address_form[address2]"  : postalCode,
                                              @"address_form[address1]"  : address,
                                              @"address_form[gender]"    : gender
                                              };
    
    [self.formController registerDelegationsAndDataSourceForTableview];
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
    
    self.navBarLayout.title = STRING_ADDRESS;
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

@end
