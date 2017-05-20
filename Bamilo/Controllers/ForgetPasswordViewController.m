
//
//  ForgetPasswordViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "ForgetPasswordViewController.h"

@interface ForgetPasswordViewController()
@property (weak, nonatomic) IBOutlet UIView *topSeperatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topHeaderUnderButtonView;
@property (strong, nonatomic) FormViewControl *formController;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.formController = [[FormViewControl alloc] init];
    self.formController.delegate = self;
    self.formController.tableView = self.tableView;
    
    self.topSeperatorView.backgroundColor = [Theme color:kColorLightGray];
    
    FormItemModel *email = [FormItemModel emailWithFieldName:@"forgot_password[email]"];
    email.icon = [UIImage imageNamed:@"Email"];
    
    self.formController.formModelList = [NSMutableArray arrayWithArray:@[email]];
    self.formController.submitTitle = STRING_SEND;
    
    [self.formController setupTableView];
    [self.topHeaderUnderButtonView setBackgroundColor:[Theme color:kColorOrange]];
    
    [self.descLabel applyStyle:[Theme font:kFontVariationRegular size:11] color: [Theme color:kColorDarkGray]];
    
    self.descLabel.text = STRING_ENTER_YOUR_EMAIL_ADDRESS;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.formController registerForKeyboardNotifications];
    
    [self publishScreenLoadTime];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.formController unregisterForKeyboardNotifications];
}

#pragma mark - Overrides
-(void)updateNavBar {
    [super updateNavBar];
    self.navBarLayout.title = @"بازیابی کلمه عبور";
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.showCartButton = NO;
}

#pragma mark - FormControlDelegate
- (void)formSubmitButtonTapped {
    if (![self.formController isFormValid]) {
        [self.formController showAnyErrorInForm];
        return;
    }
    
    [[AuthenticationDataManager sharedInstance] forgetPassword:self withFields:[self.formController getMutableDictionaryOfForm] completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
        } else {
            if(![self showNotificationBar:error isSuccess:NO]) {
                for(NSDictionary* errorField in [error.userInfo objectForKey:kErrorMessages]) {
                    NSString *fieldName = [NSString stringWithFormat:@"forgot_password[%@]", errorField[@"field"]];
                    [self.formController showErrorMessageForField:fieldName errorMsg:errorField[kMessage]];
                }
            }
        }
    }]; 
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    [self showNotificationBarMessage:STRING_EMAIL_SENT isSuccess:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    return @"ForgetPassword";
}

@end