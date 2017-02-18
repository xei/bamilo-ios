
//
//  ForgetPasswordViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ForgetPasswordViewController.h"

@interface ForgetPasswordViewController()
@property (weak, nonatomic) IBOutlet UIView *topSeperatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) FormViewControl *formController;
@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.formController = [[FormViewControl alloc] init];
    self.formController.delegate = self;
    self.formController.tableView = self.tableView;
    
    self.topSeperatorView.backgroundColor = cLIGHT_GRAY_COLOR;
    
    FormItemValidation *emailValidation = [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[NSString emailRegxPattern]];
    FormItemModel *email = [[FormItemModel alloc] initWithTitle:nil
                                                        andIcon:[UIImage imageNamed:@"Email"]
                                                        placeholder:@"ایمیل"
                                                        type:InputTextFieldControlTypeEmail
                                                        validation:emailValidation
                                                        selectOptions:nil];
    
    self.formController.formItemListModel = [NSMutableDictionary dictionaryWithDictionary:@{@"forgot_password[email]": email}];
    self.formController.submitTitle = STRING_CONTINUE;
    self.formController.formMessage = @"آدرس ایمیل خود را وارد کنید";
    
    [self.formController setupTableView];
}

- (void)viewDidAppear:(BOOL)animated {
  [self.formController registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.formController unregisterForKeyboardNotifications];
}

#pragma mark - Overrides
-(void)updateNavBar {
    [super updateNavBar];
    self.navBarLayout.title = @"فراموشی رمز";
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.showCartButton = NO;
}

#pragma mark - FormControlDelegate
- (void)submitBtnTapped {
    if (![self.formController isFormValid]) {
        return;
    }
    [[DataManager sharedInstance] forgetPassword:self withFields:[self.formController getMutableDictionaryOfForm] completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
        } else {
            for(NSDictionary* errorField in [error.userInfo objectForKey:@"errorMessages"]) {
                NSString *fieldName = [NSString stringWithFormat:@"forgot_password[%@]", errorField[@"field"]];
                [self.formController showErrorMessgaeForField:fieldName errorMsg:errorField[@"message"]];
            }
        }
    }]; 
}
- (void)viewNeedsToEndEditing {
    [self.view endEditing:YES];
}


#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    [self showMessage:STRING_EMAIL_SENT success:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
