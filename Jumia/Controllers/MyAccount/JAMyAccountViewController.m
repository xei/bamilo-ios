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
    
    self.screenName = @"CustomerAccount";
    
    self.navBarLayout.title = STRING_MY_ACCOUNT;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showUserDataSavedMessage)
                                                 name:kDidSaveUserDataNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showEmailNotificationsSavedMessage)
                                                 name:kDidSaveEmailNotificationsNotification
                                               object:nil];
    
    self.accountView.layer.cornerRadius = 4.0f;
    self.accountTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.accountTitleLabel.text = STRING_ACCOUNT_SETTINGS;
    
    self.userLineImageView.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.accountLine.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.userDataLabel.textColor = UIColorFromRGB(0x666666);
    self.userDataLabel.text = STRING_USER_DATA;
    self.userDataDetailLabel.textColor = UIColorFromRGB(0x666666);
    self.userDataDetailLabel.text = STRING_CHANGE_PASS_MANAGE_EMAIL;
    
    self.emailLabel.textColor = UIColorFromRGB(0x666666);
    self.emailLabel.text = STRING_EMAIL_NOTIFICATIONS;
    self.emailLabelDetail.textColor = UIColorFromRGB(0x666666);
    self.emailLabelDetail.text = STRING_SUBSCRIVE_UNSUBSCRIVE;
    
    self.notificationView.layer.cornerRadius = 4.0f;
    self.notificationTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.notificationTitleLabel.text = STRING_NOTIFICATIONS_SETTINGS;
    
    self.notificationTitleLine.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.lineUnderNotificationLabel.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.notificationLabel.textColor = UIColorFromRGB(0x666666);
    self.notificationLabel.text = STRING_NOTIFICATIONS;
    self.notificationDetailLabel.textColor = UIColorFromRGB(0x666666);
    self.notificationDetailLabel.text = STRING_RECEIVE_EXCLUSIVE_OFFERS;
    [self.notificationSwitch setAccessibilityLabel:STRING_NOTIFICATIONS];
    
    self.labelSound.textColor = UIColorFromRGB(0x666666);
    self.labelSound.text = STRING_SOUND;
    self.labelDetailSound.textColor = UIColorFromRGB(0x666666);
    self.labelDetailSound.text = STRING_PLAY_SOUND;
    [self.switchSound setAccessibilityLabel:STRING_SOUND];
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserDataScreenNotification
                                                        object:@{@"animated":[NSNumber numberWithBool:YES]}];
}

- (IBAction)pushEmailNotifications:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowEmailNotificationsScreenNotification
                                                        object:@{@"animated":[NSNumber numberWithBool:YES]}];
}

-(void)showUserDataSavedMessage
{
    [self showMessage:STRING_CHANGED_PASSWORD_SUCCESS success:YES];
}

- (void)showEmailNotificationsSavedMessage
{
    [self showMessage:STRING_PREFERENCES_UPDATED success:YES];
}

@end
