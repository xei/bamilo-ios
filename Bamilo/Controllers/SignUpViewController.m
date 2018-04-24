//
//  SignUpViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SignUpViewController.h"
#import "EmarsysPredictManager.h"
#import "PushWooshTracker.h"
#import "AuthenticationContainerViewController.h"
//Lagacy importing
#import "RICustomer.h"
#import "JAUtils.h"
#import "DataServiceProtocol.h"
#import "Bamilo-Swift.h"

#define cSignUpMethodEmail @"email"
#define cSignUpMethodGoogle @"sso-google"


@interface SignUpViewController() <PhoneVerificationViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) FormViewControl *formController;
@property (nonatomic, strong) FormItemModel *phoneField;
@property (nonatomic) BOOL isSubmissionButtonDisabled;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formController = [[FormViewControl alloc] init];
    self.formController.delegate = self;
    
    [self.tableView setContentInset: UIEdgeInsetsMake(28, 0, 0, 0)];
    self.formController.tableView = self.tableView;
    
    FormItemModel *email = [FormItemModel emailWithFieldName:@"customer[email]"];
    self.phoneField = [FormItemModel phoneWithFieldName:@"customer[phone]"];
    FormItemModel *melliCode = [FormItemModel nationalID:@"customer[national_id]"];
    FormItemModel *password = [FormItemModel passWordWithFieldName:@"customer[password]"];
    
    self.formController.submitTitle = STRING_SIGNUP;
    self.title = STRING_SIGNUP;
    self.formController.formModelList = [NSMutableArray arrayWithArray:@[ email, self.phoneField, melliCode, password ]];
    [self.formController setupTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    self.isSubmissionButtonDisabled = NO;
    [self.formController registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.formController unregisterForKeyboardNotifications];
}

#pragma mark - formControlDelegate
- (void)formSubmitButtonTapped {
    if (![self.formController isFormValid] && !self.isSubmissionButtonDisabled) {
        [self.formController showAnyErrorInForm];
        return;
    }
    [self tryToSignupUser:self];
}

- (void)tryToSignupUser:(id<DataServiceProtocol>)target {
    [DataAggregator signupUser:target with:[self.formController getMutableDictionaryOfForm] completion:^(id data, NSError *error) {
        if(error == nil) {
            self.isSubmissionButtonDisabled = YES;
            //TODO: this is not a good approach which has been contracted with server
            // and it's better to be refactored in both platforms
            if ([data isKindOfClass:[ApiDataMessageList class]]) {
                ApiDataMessageList *messages = data;
                if (messages) {
                    if ([((ApiDataMessage *)messages.success.firstObject).reason isEqualToString:@"CUSTOMER_REGISTRATION_STEP_1_VALIDATED"]) {
                        NSLog(@"comes here");
                        [self.delegate wantsToShowTokenVerificatinWith:self phone: [self.phoneField getValue]];
                        return;
                    }
                }
            }
            //End of TODO
            [self bind:data forRequestId:0];
            //EVENT: SIGNUP / SUCCESS
            RICustomer *customer = [RICustomer getCurrentCustomer];
            [TrackerManager postEventWithSelector:[EventSelectors signupEventSelector] attributes:[EventAttributes signupWithMethod:cSignUpMethodEmail user:customer success:YES]];
            [EmarsysPredictManager setCustomer: customer];
            [PushWooshTracker setUserID:[RICustomer getCurrentCustomer].email];
            if (self.completion) {
                self.completion(AuthenticationStatusSignupFinished);
            } else if ([[MainTabBarViewController topViewController] isKindOfClass:[AuthenticationContainerViewController class]]) {
                [((UIViewController *)self.delegate).navigationController popViewControllerAnimated:YES];
            } else {
                [((UIViewController *)self.delegate).navigationController popWithStep:2 animated:YES];
            }
        } else {
            [TrackerManager postEventWithSelector:[EventSelectors signupEventSelector]
                                       attributes:[EventAttributes signupWithMethod:cSignUpMethodEmail user:nil success:NO]];
            //EVENT: SIGNUP / FAILURE
            if ([target isKindOfClass:[SignUpViewController class]]) {
                BaseViewController *baseViewController = (BaseViewController *)self.delegate;
                if(![baseViewController showNotificationBar:error isSuccess:NO]) {
                    BOOL errorHandled = NO;
                    NSArray<NSDictionary *> *errors = [error.userInfo objectForKey:kErrorMessages];
                    for(NSDictionary* errorField in errors) {
                        NSString *fieldNameParm = [errorField objectForKey:@"field"];
                        if ([fieldNameParm isKindOfClass:[NSString class]] && fieldNameParm.length > 0) {
                            NSString *fieldName = [NSString stringWithFormat:@"customer[%@]", fieldNameParm];
                            if ([self.formController showErrorMessageForField:fieldName errorMsg:errorField[kMessage]]) {
                                errorHandled = YES;
                            }
                        }
                    }
                    if (!errorHandled) {
                        [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
                    }
                }
            } else if ([target isKindOfClass:[BaseViewController class]]) {
                if (![Utility handleErrorMessagesWithError:error viewController:(BaseViewController *)target]) {
                    [(BaseViewController *)target showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
                }
            }
        }
    }];
}

#pragma mark - PhoneVerificationViewControllerDelegate
- (void)finishedVerifingPhoneWithTarget:(PhoneVerificationViewController *)target {
    //complete signup
    [self tryToSignupUser:target];
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
//    // --------------- Legacy actions --------------
}

@end
