//
//  SignUpViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SignUpViewController.h"

//Lagacy importing
#import "RICustomer.h"
#import "JAUtils.h"

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FormItemModel *melliCode = [[FormItemModel alloc]
                                initWithTitle:nil
                                andIcon:nil
                                placeholder:@"کد ملی"
                                type:InputTextFieldControlTypeNumerical
                                validation: [[FormItemValidation alloc] initWithRequired:YES max:10 min:10 withRegxPatter:nil]];
    
    
    FormItemModel *email = [[FormItemModel alloc]
                                initWithTitle:nil
                                andIcon:nil
                                placeholder:@"ایمیل"
                                type:InputTextFieldControlTypeEmail
                                validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[NSString emailRegxPattern]]];
    
    FormItemModel *name = [[FormItemModel alloc]
                            initWithTitle:nil
                            andIcon:nil
                            placeholder:@"نام"
                            type:InputTextFieldControlTypeString
                            validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]];

    
    FormItemModel *lastname = [[FormItemModel alloc]
                              initWithTitle:nil
                              andIcon:nil
                              placeholder:@"نام خانوادگی"
                              type:InputTextFieldControlTypeString
                              validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]];

    
    FormItemModel *password = [[FormItemModel alloc]
                               initWithTitle:nil
                               andIcon:nil
                               placeholder:@"رمز عبور"
                               type:InputTextFieldControlTypePassword
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:6 withRegxPatter:nil]];
    
    FormItemModel *phone = [[FormItemModel alloc]
                               initWithTitle:nil
                               andIcon:nil
                               placeholder:@"تلفن همراه"
                               type:InputTextFieldControlTypeNumerical
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]];

    
    
    self.submitTitle = @"تایید";
    self.formMessage = @"ظاهرا مشتری جدید بامیلو هستید،خواهشمندیم اطلاعات بیشتری برای ساخت حساب کاربری خود ارایه دهید ";
    self.title = STRING_SIGNUP;
    self.formItemListModel = @{
                               @"customer[national_id]": melliCode,
                               @"customer[first_name]" : name,
                               @"customer[last_name]"  : lastname,
                               @"customer[email]"      : email,
                               @"customer[password]"   : password,
                               @"customer[phone]"      : phone
                               };
}

#pragma mark - Override
- (void)buttonTapped:(id)cell {
    [super buttonTapped:cell];
    
    if (![self isFormValid]) {
        return;
    }
    
    [[DataManager sharedInstance] signupUser:self withFieldsDictionary:self.formItemListModel completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
        } else {
            for(NSDictionary* errorField in [error.userInfo objectForKey:@"errorMessages"]) {
                NSString *fieldName = [NSString stringWithFormat:@"customer[%@]", errorField[@"field"]];
                [self showErrorMessgaeForField:fieldName errorMsg:errorField[@"message"]];
            }
        }
    }];
}

#pragma mark - Overrides
- (void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = NO;
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    RICustomer *customerObject = [(NSDictionary*)data objectForKey:@"customer"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:customerObject.customerId forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"CreateSuccess" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:customerObject.customerId forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:customerObject.firstName forKey:kRIEventUserFirstNameKey];
    [trackingDictionary setValue:customerObject.lastName forKey:kRIEventUserLastNameKey];
    [trackingDictionary setValue:customerObject.gender forKey:kRIEventGenderKey];
    [trackingDictionary setValue:customerObject.birthday forKey:kRIEventBirthDayKey];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
    if(self.fromSideMenu) {
        [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
    } else {
        [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
    }
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRegisterSuccess] data:[trackingDictionary copy]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification object:nil];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (self.fromSideMenu) {
        [userInfo setObject:@YES forKey:@"from_side_menu"];
    }
    //[[NSNotificationCenter defaultCenter] postNotificationName:kRunBlockAfterAuthenticationNotification object:self.nextStepBlock userInfo:userInfo];
}
@end
