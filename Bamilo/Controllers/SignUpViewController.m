//
//  SignUpViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SignUpViewController.h"
#import "RICustomer.h"

@interface SignUpViewController ()
@property (nonatomic, strong) NSMutableDictionary *formItemDictionary;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FormItemModel *melliCode = [[FormItemModel alloc]
                                initWithTitle:nil
                                andIcon:nil
                                placeholder:@"کد ملی"
                                type:InputTextFieldControlTypeNumerical
                                validation: [[FormItemValidation alloc] initWithRequired:YES max:10 min:10 withRegxPatter:nil]];
    self.formItemDictionary[@"melliCode"] = melliCode;
    
    
    FormItemModel *email = [[FormItemModel alloc]
                                initWithTitle:nil
                                andIcon:nil
                                placeholder:@"ایمیل"
                                type:InputTextFieldControlTypeEmail
                                validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[NSString emailRegxPattern]]];
    self.formItemDictionary[@"email"] = melliCode;
    
    FormItemModel *name = [[FormItemModel alloc]
                            initWithTitle:nil
                            andIcon:nil
                            placeholder:@"نام"
                            type:InputTextFieldControlTypeString
                            validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]];
    self.formItemDictionary[@"name"] = melliCode;
    
    FormItemModel *lastname = [[FormItemModel alloc]
                              initWithTitle:nil
                              andIcon:nil
                              placeholder:@"نام خانوادگی"
                              type:InputTextFieldControlTypeString
                              validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]];
    self.formItemDictionary[@"lastname"] = melliCode;
    
    FormItemModel *password = [[FormItemModel alloc]
                               initWithTitle:nil
                               andIcon:nil
                               placeholder:@"رمز عبور"
                               type:InputTextFieldControlTypePassword
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:6 withRegxPatter:nil]];
    self.formItemDictionary[@"password"] = melliCode;
    
    FormItemModel *phone = [[FormItemModel alloc]
                               initWithTitle:nil
                               andIcon:nil
                               placeholder:@"تلفن همراه"
                               type:InputTextFieldControlTypeNumerical
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]];
    self.formItemDictionary[@"phone"] = melliCode;
    
    
    
    self.submitTitle = @"تایید";
    self.formMessage = @"ظاهرا مشتری جدید بامیلو هستید،خواهشمندیم اطلاعات بیشتری برای ساخت حساب کاربری خود ارایه دهید ";
    self.formItemListModel = @[melliCode, name, lastname, email, password, phone];
}

- (void)buttonTapped:(id)cell {
    [super buttonTapped:cell];
    
    if (![self isFormValid]) {
        return;
    }
}

@end
