//
//  AuthenticationViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationContainerViewController.h"
#import "CAPSPageMenu.h"
#import "RICustomer.h"
#import "ViewControllerManager.h"
#import "Bamilo-Swift.h"
#import "DataServiceProtocol.h"

@interface AuthenticationContainerViewController() <CAPSPageMenuDelegate, DataServiceProtocol>
@property (nonatomic) CAPSPageMenu *pagemenu;
@end

@implementation AuthenticationContainerViewController {
    @private NSString *userPhone;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    //Sign In View Controller
    self.signInViewController = (SignInViewController *)[[ViewControllerManager sharedInstance] loadNib:@"SignInViewController" resetCache:YES];
    self.signInViewController.title = STRING_LOGIN;
    self.signInViewController.fromSideMenu = self.fromSideMenu;
    self.signInViewController.showContinueWithoutLogin = self.showContinueWithoutLogin;
    self.signInViewController.delegate = self;
    
    //Sign Up View Controller
    self.signUpViewController = (SignUpViewController *)[[ViewControllerManager sharedInstance] loadNib:@"SignUpViewController" resetCache:YES];
    self.signUpViewController.title = STRING_SIGNUP;
    self.signUpViewController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSDictionary *parameters = @{CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES),
                                 CAPSPageMenuOptionSelectionIndicatorHeight: @2,
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:kFontRegularName size: 14],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [Theme color:kColorOrange],
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
                                 CAPSPageMenuOptionMenuHeight: @40,
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [Theme color:kColorLightGray],
                                 CAPSPageMenuOptionAddBottomMenuHairline: @(YES),
                                 CAPSPageMenuOptionUnselectedMenuItemLabelColor: [Theme color:kColorDarkGray],
                                 CAPSPageMenuOptionSelectedMenuItemLabelColor: [Theme color:kColorExtraDarkGray],
                                 CAPSPageMenuOptionScrollAnimationDurationOnMenuItemTap: @(150)
                                 };
    
    self.pagemenu = [[CAPSPageMenu alloc] initWithViewControllers:@[ self.signUpViewController, self.signInViewController ] frame:self.viewBounds options:parameters];
    self.pagemenu.delegate = self;
    if (!self.startWithSignUpViewController){
        [self.pagemenu moveToPage:1];
    }
    [self.view addSubview:_pagemenu.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([RICustomer checkIfUserIsLogged]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark - AuthenticationDelegate
- (void)wantsToContinueWithoutLogin {
    [self performSegueWithIdentifier:@"showContinueWithoutLoginViewCtrl" sender:nil];
}

- (void)wantsToShowForgetPassword {
    [self performSegueWithIdentifier:@"showForgetPasswordViewCtrl" sender:nil];
}


- (void)wantsToShowTokenVerificatinWith:(AuthenticationBaseViewController *)viewCtrl phone:(NSString *)phone {
    userPhone = phone;
    [self requestToken:userPhone bySender:viewCtrl];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString:@"showVrificationCodeViewCtrl"] && [sender isKindOfClass:[SignUpViewController class]]) {
        ((PhoneVerificationViewController *)segue.destinationViewController).phoneNumber = userPhone;
        ((PhoneVerificationViewController *)segue.destinationViewController).delegate = sender;
    }
}

#pragma mark - CAPSPageMenuDelegate
- (void)didMoveToPage:(UIViewController *)controller index:(NSInteger)index {
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    if(self.pagemenu.currentPageIndex == 0) {
        return @"SignUp";
    } else {
        return @"SignIn";
    }
}

#pragma mark - NavigationBarProtocol
- (NSString *)navBarTitleString {
    return STRING_LOGIN_OR_SIGNUP;
}

- (BOOL)navBarhideBackButton {
    return self.isForcedToLogin;
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {}

- (void)errorHandler:(NSError *)error forRequestID:(int)rid {
    if (rid == 0 && ![Utility handleErrorMessagesWithError:error viewController:self]) {
        [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
    }
}

#pragma mark : private function
- (void)requestToken:(NSString *)phone bySender:(AuthenticationBaseViewController *)sender {
    [PhoneVerificationViewController verificationRequestWithTarget:self phone:userPhone token:nil rid:0 callBack:^(BOOL success) {
        if (success) {
            [self performSegueWithIdentifier:@"showVrificationCodeViewCtrl" sender:sender];
        }
    }];
}

@end
