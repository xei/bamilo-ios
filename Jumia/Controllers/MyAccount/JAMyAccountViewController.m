//
//  JAMyAccountViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyAccountViewController.h"
#import "JAClickableView.h"
#import "JAShareActivityProvider.h"
#import "JAActivityViewController.h"

@interface JAMyAccountViewController ()

@property (weak, nonatomic) IBOutlet UIView *accountView;
@property (weak, nonatomic) IBOutlet UILabel *accountSettingsTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *accountViewTopSeparator;
@property (weak, nonatomic) IBOutlet JAClickableView *userDataClickableView;
@property (weak, nonatomic) IBOutlet UILabel *userDataTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDataSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userDataArrow;
@property (weak, nonatomic) IBOutlet UIView *accountAndEmailSeparator;
@property (weak, nonatomic) IBOutlet JAClickableView *emailClickableView;
@property (weak, nonatomic) IBOutlet UILabel *emailTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *emailArrow;
@property (weak, nonatomic) IBOutlet UIView *emailAndAddressesSeparator;
@property (weak, nonatomic) IBOutlet JAClickableView *addressesClickableView;
@property (weak, nonatomic) IBOutlet UILabel *addressesTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressesSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *addressesArrow;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet UILabel *notificationSettingsTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *notificationViewTopSeparator;
@property (weak, nonatomic) IBOutlet UILabel *notificationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationSubtitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UIView *notificationAndSoundSeparator;
@property (weak, nonatomic) IBOutlet UILabel *soundTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *soundSubtitleLabel;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UIView *appSharingView;
@property (weak, nonatomic) IBOutlet UILabel *appSharingTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *appSharingSeparator;
@property (weak, nonatomic) IBOutlet JAClickableView *shareAppClickableView;
@property (weak, nonatomic) IBOutlet UILabel *shareAppTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareAppSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shareAppArrow;

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
    
    self.accountView.layer.cornerRadius = 5.0f;
    self.accountView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.accountSettingsTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.accountSettingsTitleLabel.text = STRING_ACCOUNT_SETTINGS;
    
    self.accountViewTopSeparator.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.accountAndEmailSeparator.backgroundColor = UIColorFromRGB(0xcccccc);
    self.emailAndAddressesSeparator.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.userDataTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.userDataTitleLabel.text = STRING_USER_DATA;
    self.userDataTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.userDataSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.userDataSubtitleLabel.text = STRING_CHANGE_PASS_MANAGE_EMAIL;
    self.userDataSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.userDataArrow.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.emailTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.emailTitleLabel.text = STRING_EMAIL_NOTIFICATIONS;
    self.emailTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.emailSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.emailSubtitleLabel.text = STRING_SUBSCRIVE_UNSUBSCRIVE;
    self.emailSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.emailArrow.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.addressesTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.addressesTitleLabel.text = STRING_MY_ADDRESSES;
    self.addressesTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.addressesSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.addressesSubtitleLabel.text = STRING_CREATE_EDIT_ADDRESS;
    self.addressesSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.addressesArrow.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.notificationView.layer.cornerRadius = 5.0f;
    self.notificationView.translatesAutoresizingMaskIntoConstraints = YES;
    self.notificationSettingsTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.notificationSettingsTitleLabel.text = STRING_NOTIFICATIONS_SETTINGS;
    self.notificationViewTopSeparator.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.notificationAndSoundSeparator.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.notificationTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.notificationTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.notificationTitleLabel.text = STRING_NOTIFICATIONS;
    self.notificationTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.notificationTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.notificationSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.notificationSubtitleLabel.text = STRING_RECEIVE_EXCLUSIVE_OFFERS;
    self.notificationSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.notificationSwitch.translatesAutoresizingMaskIntoConstraints = YES;
    [self.notificationSwitch setAccessibilityLabel:STRING_NOTIFICATIONS];
    
    self.soundTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.soundTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.soundTitleLabel.text = STRING_SOUND;
    
    self.soundSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.soundSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.soundSubtitleLabel.text = STRING_PLAY_SOUND;
    
    self.soundSwitch.translatesAutoresizingMaskIntoConstraints = YES;
    [self.soundSwitch setAccessibilityLabel:STRING_SOUND];
    
    self.appSharingView.layer.cornerRadius = 5.0f;
    self.appSharingView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.appSharingTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.appSharingTitleLabel.text = STRING_APP_SHARING;
    
    self.appSharingSeparator.backgroundColor = UIColorFromRGB(0xfaa41a);
    
    self.shareAppTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.shareAppTitleLabel.text = STRING_SHARE_THE_APP;
    self.shareAppTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.shareAppSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.shareAppSubtitleLabel.text = STRING_CAN_SHARE_APP_WITH_FRIENDS;
    self.shareAppSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.shareAppArrow.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.userDataClickableView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.userDataClickableView addTarget:self
                                   action:@selector(pushUserData:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    self.emailClickableView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.emailClickableView addTarget:self
                                action:@selector(pushEmailNotifications:)
                      forControlEvents:UIControlEventTouchUpInside];
    
    self.addressesClickableView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.addressesClickableView addTarget:self
                                    action:@selector(pushAddresses:)
                          forControlEvents:UIControlEventTouchUpInside];
    
    self.shareAppClickableView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.shareAppClickableView addTarget:self
                                   action:@selector(shareApp:)
                         forControlEvents:UIControlEventTouchUpInside];
    
    BOOL isNotiActive = [[NSUserDefaults standardUserDefaults] boolForKey: kChangeNotificationsOptions];
    BOOL isSoundActive = [[NSUserDefaults standardUserDefaults] boolForKey: kChangeSoundOptions];
    
    self.notificationSwitch.on = isNotiActive;
    self.soundSwitch.on = isSoundActive;
    
    if(!isNotiActive)
    {
        self.notificationAndSoundSeparator.hidden = YES;
        self.soundTitleLabel.hidden = YES;
        self.soundSubtitleLabel.hidden = YES;
        self.soundSwitch.hidden = YES;
        
        [self.notificationView setFrame:CGRectMake(self.notificationView.frame.origin.x,
                                                   self.notificationView.frame.origin.y,
                                                   self.notificationView.frame.size.width,
                                                   70.0f)];
        
        [self.appSharingView setFrame:CGRectMake(self.appSharingView.frame.origin.x,
                                                 CGRectGetMaxY(self.notificationView.frame) + 6.0f,
                                                 self.appSharingView.frame.size.width,
                                                 self.appSharingView.frame.size.height)];
    }
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupViews:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [self showLoading];
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    
    [self setupViews:newWidth toInterfaceOrientation:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupViews:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.accountView setFrame:CGRectMake(self.accountView.frame.origin.x,
                                          self.accountView.frame.origin.y,
                                          width - (self.accountView.frame.origin.x * 2),
                                          self.accountView.frame.size.height)];
    
    [self.userDataClickableView setFrame:CGRectMake(self.userDataClickableView.frame.origin.x,
                                                    self.userDataClickableView.frame.origin.y,
                                                    self.accountView.frame.size.width,
                                                    self.userDataClickableView.frame.size.height)];
    
    [self.emailClickableView setFrame:CGRectMake(self.emailClickableView.frame.origin.x,
                                                 self.emailClickableView.frame.origin.y,
                                                 self.accountView.frame.size.width,
                                                 self.emailClickableView.frame.size.height)];
    
    [self.addressesClickableView setFrame:CGRectMake(self.addressesClickableView.frame.origin.x,
                                                     self.addressesClickableView.frame.origin.y,
                                                     self.accountView.frame.size.width,
                                                     self.addressesClickableView.frame.size.height)];
    
    [self.notificationView setFrame:CGRectMake(self.notificationView.frame.origin.x,
                                               self.notificationView.frame.origin.y,
                                               width - (self.notificationView.frame.origin.x * 2),
                                               self.notificationView.frame.size.height)];
    
    [self.appSharingView setFrame:CGRectMake(self.appSharingView.frame.origin.x,
                                             CGRectGetMaxY(self.notificationView.frame) + 6.0f,
                                             width - (self.notificationView.frame.origin.x * 2),
                                             self.appSharingView.frame.size.height)];
    
    [self.shareAppClickableView setFrame:CGRectMake(self.shareAppClickableView.frame.origin.x,
                                                    self.shareAppClickableView.frame.origin.y,
                                                    self.appSharingView.frame.size.width,
                                                    self.shareAppClickableView.frame.size.height)];
    
    CGFloat leftMargin = 17.0f;
    CGFloat rightMargin = 17.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        leftMargin = 128.0f;
        rightMargin = 128.0f;
    }
    
    [self.userDataArrow setFrame:CGRectMake(self.accountView.frame.size.width - self.userDataArrow.frame.size.width - rightMargin,
                                            self.userDataArrow.frame.origin.y,
                                            self.userDataArrow.frame.size.width,
                                            self.userDataArrow.frame.size.height)];
    
    [self.userDataTitleLabel setFrame:CGRectMake(leftMargin,
                                                 self.userDataTitleLabel.frame.origin.y,
                                                 self.userDataTitleLabel.frame.size.width,
                                                 self.userDataTitleLabel.frame.size.height)];
    
    [self.userDataSubtitleLabel setFrame:CGRectMake(leftMargin,
                                                    self.userDataSubtitleLabel.frame.origin.y,
                                                    self.userDataSubtitleLabel.frame.size.width,
                                                    self.userDataSubtitleLabel.frame.size.height)];
    
    [self.emailArrow setFrame:CGRectMake(self.accountView.frame.size.width - self.emailArrow.frame.size.width - rightMargin,
                                         self.emailArrow.frame.origin.y,
                                         self.emailArrow.frame.size.width,
                                         self.emailArrow.frame.size.height)];
    
    [self.emailTitleLabel setFrame:CGRectMake(leftMargin,
                                              self.emailTitleLabel.frame.origin.y,
                                              self.emailTitleLabel.frame.size.width,
                                              self.emailTitleLabel.frame.size.height)];
    
    [self.emailSubtitleLabel setFrame:CGRectMake(leftMargin,
                                                 self.emailSubtitleLabel.frame.origin.y,
                                                 self.emailSubtitleLabel.frame.size.width,
                                                 self.emailSubtitleLabel.frame.size.height)];
    
    [self.addressesArrow setFrame:CGRectMake(self.accountView.frame.size.width - self.addressesArrow.frame.size.width - rightMargin,
                                             self.addressesArrow.frame.origin.y,
                                             self.addressesArrow.frame.size.width,
                                             self.addressesArrow.frame.size.height)];
    
    [self.addressesTitleLabel setFrame:CGRectMake(leftMargin,
                                                  self.addressesTitleLabel.frame.origin.y,
                                                  self.addressesTitleLabel.frame.size.width,
                                                  self.addressesTitleLabel.frame.size.height)];
    
    [self.addressesSubtitleLabel setFrame:CGRectMake(leftMargin,
                                                     self.addressesSubtitleLabel.frame.origin.y,
                                                     self.addressesSubtitleLabel.frame.size.width,
                                                     self.addressesSubtitleLabel.frame.size.height)];
    
    [self.notificationSwitch setFrame:CGRectMake(self.notificationView.frame.size.width - self.notificationSwitch.frame.size.width - rightMargin,
                                                 self.notificationSwitch.frame.origin.y,
                                                 self.notificationSwitch.frame.size.width,
                                                 self.notificationSwitch.frame.size.height)];
    
    [self.notificationTitleLabel setFrame:CGRectMake(leftMargin,
                                                     self.notificationTitleLabel.frame.origin.y,
                                                     self.notificationTitleLabel.frame.size.width,
                                                     self.notificationTitleLabel.frame.size.height)];
    
    [self.notificationSubtitleLabel setFrame:CGRectMake(leftMargin,
                                                        self.notificationSubtitleLabel.frame.origin.y,
                                                        self.notificationSubtitleLabel.frame.size.width,
                                                        self.notificationSubtitleLabel.frame.size.height)];
    
    [self.soundSwitch setFrame:CGRectMake(self.notificationView.frame.size.width - self.soundSwitch.frame.size.width - rightMargin,
                                          self.soundSwitch.frame.origin.y,
                                          self.soundSwitch.frame.size.width,
                                          self.soundSwitch.frame.size.height)];
    
    [self.soundTitleLabel setFrame:CGRectMake(leftMargin,
                                              self.soundTitleLabel.frame.origin.y,
                                              self.soundTitleLabel.frame.size.width,
                                              self.soundTitleLabel.frame.size.height)];
    
    [self.soundSubtitleLabel setFrame:CGRectMake(leftMargin,
                                                 self.soundSubtitleLabel.frame.origin.y,
                                                 self.soundSubtitleLabel.frame.size.width,
                                                 self.soundSubtitleLabel.frame.size.height)];
    
    [self.shareAppArrow setFrame:CGRectMake(self.accountView.frame.size.width - self.userDataArrow.frame.size.width - rightMargin,
                                            self.shareAppArrow.frame.origin.y,
                                            self.shareAppArrow.frame.size.width,
                                            self.shareAppArrow.frame.size.height)];
    
    [self.shareAppTitleLabel setFrame:CGRectMake(leftMargin,
                                                 self.shareAppTitleLabel.frame.origin.y,
                                                 self.shareAppTitleLabel.frame.size.width,
                                                 self.shareAppTitleLabel.frame.size.height)];
    
    [self.shareAppSubtitleLabel setFrame:CGRectMake(leftMargin,
                                                    self.shareAppSubtitleLabel.frame.origin.y,
                                                    self.shareAppSubtitleLabel.frame.size.width,
                                                    self.shareAppSubtitleLabel.frame.size.height)];
    
    [self.shareAppArrow setFrame:CGRectMake(self.appSharingView.frame.size.width - self.shareAppArrow.frame.size.width - rightMargin,
                                            self.shareAppArrow.frame.origin.y,
                                            self.shareAppArrow.frame.size.width,
                                            self.shareAppArrow.frame.size.height)];
}

#pragma mark - Actions

- (IBAction)changeNotification:(id)sender
{
    if (self.notificationSwitch.on)
    {
        self.notificationAndSoundSeparator.hidden = NO;
        self.soundTitleLabel.hidden = NO;
        self.soundSubtitleLabel.hidden = NO;
        self.soundSwitch.hidden = NO;
        
        [self changeSound:nil];
        
        [self.notificationView setFrame:CGRectMake(self.notificationView.frame.origin.x,
                                                   self.notificationView.frame.origin.y,
                                                   self.notificationView.frame.size.width,
                                                   116.0f)];
        
        [self.appSharingView setFrame:CGRectMake(self.appSharingView.frame.origin.x,
                                                 CGRectGetMaxY(self.notificationView.frame) + 6.0f,
                                                 self.appSharingView.frame.size.width,
                                                 self.appSharingView.frame.size.height)];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kChangeNotificationsOptions];
    }
    else
    {
        self.notificationAndSoundSeparator.hidden = YES;
        self.soundTitleLabel.hidden = YES;
        self.soundSubtitleLabel.hidden = YES;
        self.soundSwitch.hidden = YES;
        
        [self.notificationView setFrame:CGRectMake(self.notificationView.frame.origin.x,
                                                   self.notificationView.frame.origin.y,
                                                   self.notificationView.frame.size.width,
                                                   70.0f)];
        
        [self.appSharingView setFrame:CGRectMake(self.appSharingView.frame.origin.x,
                                                 CGRectGetMaxY(self.notificationView.frame) + 6.0f,
                                                 self.appSharingView.frame.size.width,
                                                 self.appSharingView.frame.size.height)];
        
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kChangeNotificationsOptions];
    }
}

- (IBAction)changeSound:(id)sender
{
    if (self.soundSwitch.on)
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge |
                                                                                UIRemoteNotificationTypeSound |
                                                                                UIRemoteNotificationTypeAlert )];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kChangeSoundOptions];
        
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge |
                                                                                UIRemoteNotificationTypeAlert )];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kChangeSoundOptions];
        
    }
}

- (void)pushUserData:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserDataScreenNotification
                                                        object:@{@"animated":[NSNumber numberWithBool:YES]}];
}

- (void)pushEmailNotifications:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowEmailNotificationsScreenNotification
                                                        object:@{@"animated":[NSNumber numberWithBool:YES]}];
}

- (void)pushAddresses:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                        object:@{@"animated":[NSNumber numberWithBool:YES]}
                                                      userInfo:@{@"from_checkout":[NSNumber numberWithBool:NO]}];
}

- (void)shareApp:(id)sender
{
    JAShareActivityProvider *provider = [[JAShareActivityProvider alloc] initForAppShare];
    
    NSArray *objectsToShare = @[provider];
    
    JAActivityViewController *activityController = [[JAActivityViewController alloc] initWithActivityItems:objectsToShare
                                                                                     applicationActivities:nil];
    
    [activityController setValue:STRING_SHARE_JUMIA_APP
                          forKey:@"subject"];
    
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        CGRect sharePopoverRect = CGRectMake(self.shareAppClickableView.frame.size.width / 2,
                                             self.shareAppClickableView.frame.size.height - 6.0f,
                                             0.0f,
                                             0.0f);
        activityController.popoverPresentationController.sourceView = self.shareAppClickableView;
        activityController.popoverPresentationController.sourceRect = sharePopoverRect;
        activityController.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUp;
    }
#endif
    
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
    
    [self presentViewController:activityController animated:YES completion:nil];
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
