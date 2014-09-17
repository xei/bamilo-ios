//
//  JAMyAccountViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyAccountViewController.h"
#import "RIForm.h"
#import "RICustomer.h"

@interface JAMyAccountViewController ()

@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UILabel *accountTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *accountLine;
@property (weak, nonatomic) IBOutlet UILabel *userDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDataDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userLineImageView;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabelDetail;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UILabel *notificationTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *notificationTitleLine;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationDetailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *lineUnderNotificationLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelSound;
@property (weak, nonatomic) IBOutlet UILabel *labelDetailSound;
@property (weak, nonatomic) IBOutlet UISwitch *switchSound;

@end

@implementation JAMyAccountViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.title = STRING_MY_ACCOUNT;
    
    self.accountView.layer.cornerRadius = 4.0f;
    self.accountTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.accountTitleLabel.text = @"Account Settings";
    
    self.userLineImageView.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.accountLine.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.userDataLabel.textColor = UIColorFromRGB(0x666666);
    self.userDataLabel.text = @"User Data";
    self.userDataDetailLabel.textColor = UIColorFromRGB(0x666666);
    self.userDataDetailLabel.text = @"Change password, manage email";
    
    self.emailLabel.textColor = UIColorFromRGB(0x666666);
    self.emailLabel.text = @"Email Notifications";
    self.emailLabelDetail.textColor = UIColorFromRGB(0x666666);
    self.emailLabelDetail.text = @"Subscribe or unsubscribe";
    
    self.notificationView.layer.cornerRadius = 4.0f;
    self.notificationTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.notificationTitleLabel.text = @"Notification Settings";
    
    self.notificationTitleLine.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.lineUnderNotificationLabel.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.notificationLabel.textColor = UIColorFromRGB(0x666666);
    self.notificationLabel.text = @"Notifications";
    self.notificationDetailLabel.textColor = UIColorFromRGB(0x666666);
    self.notificationDetailLabel.text = @"Receive exclusive offers and personal updates";
    
    self.labelSound.textColor = UIColorFromRGB(0x666666);
    self.labelSound.text = @"Sound";
    self.labelDetailSound.textColor = UIColorFromRGB(0x666666);
    self.labelDetailSound.text = @"Play sound on incoming notifications";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)changeNotification:(id)sender
{
    if (self.notificationSwitch.on)
    {
        self.switchSound.on = YES;
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge |
                                                                                UIRemoteNotificationTypeSound |
                                                                                UIRemoteNotificationTypeAlert )];
    }
    else
    {
        self.switchSound.on = NO;
        
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

- (IBAction)changeSound:(id)sender
{
    if (self.switchSound.on)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge |
                                                                                UIRemoteNotificationTypeSound |
                                                                                UIRemoteNotificationTypeAlert )];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge |
                                                                                UIRemoteNotificationTypeAlert )];
    }
}

- (IBAction)pushUserData:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(50),
                                                                 @"name": STRING_USER_DATA }];
}

- (IBAction)pushEmailNotifications:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(50),
                                                                 @"name": STRING_USER_EMAIL_NOTIFICATIONS }];
}

@end
