//
//  JAMyAccountViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyAccountViewController.h"
#import "JAClickableView.h"
#import "JAActivityViewController.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "AQSFacebookMessengerActivity.h"
#import "JBWhatsAppActivity.h"
#import "RIApi.h"
#import "UIImageView+WebCache.h"
#import "JAPicker.h"
#import "RICountry.h"

@interface JAMyAccountViewController ()
<
JAPickerDelegate
>

@property (weak, nonatomic) IBOutlet UIScrollView* scrollView;
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
@property (strong, nonatomic) UIPopoverController *currentPopoverController;
@property (assign, nonatomic) BOOL stillRTL;

@property (weak, nonatomic) IBOutlet UIView *countrySettingsView;
@property (weak, nonatomic) IBOutlet UILabel *countrySettingsTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *countrySeparator;
@property (weak, nonatomic) IBOutlet JAClickableView *chooseCountryClickableView;
@property (weak, nonatomic) IBOutlet UILabel *countryTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countrySubtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *countryFlag;
@property (weak, nonatomic) IBOutlet UIView *languageSeparator;
@property (weak, nonatomic) IBOutlet JAClickableView *languageClickableView;
@property (weak, nonatomic) IBOutlet UILabel *languageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *languageArrow;


@property (nonatomic, strong) JAPicker* languagePicker;
@property (nonatomic, strong) NSIndexPath* pickerIndexPath;

@end

@implementation JAMyAccountViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.stillRTL = YES;
    
    self.screenName = @"CustomerAccount";
    
    self.navBarLayout.title = STRING_MY_ACCOUNT;
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    self.searchBarIsVisible = YES;
    
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
    
    self.accountSettingsTitleLabel.font = [UIFont fontWithName:kFontRegularName size:self.accountSettingsTitleLabel.font.pointSize];
    self.accountSettingsTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.accountSettingsTitleLabel.text = STRING_ACCOUNT_SETTINGS;
    
    self.accountViewTopSeparator.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.accountAndEmailSeparator.backgroundColor = UIColorFromRGB(0xcccccc);
    self.emailAndAddressesSeparator.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.userDataTitleLabel.font = [UIFont fontWithName:kFontLightName size:self.userDataTitleLabel.font.pointSize];
    self.userDataTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.userDataTitleLabel.text = STRING_USER_DATA;
    self.userDataTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.userDataSubtitleLabel.font = [UIFont fontWithName:kFontLightName size:self.userDataSubtitleLabel.font.pointSize];
    self.userDataSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.userDataSubtitleLabel.text = STRING_CHANGE_PASS_MANAGE_EMAIL;
    self.userDataSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.userDataArrow.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.emailTitleLabel.font = [UIFont fontWithName:kFontLightName size:self.emailTitleLabel.font.pointSize];
    self.emailTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.emailTitleLabel.text = STRING_EMAIL_NOTIFICATIONS;
    self.emailTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.emailSubtitleLabel.font = [UIFont fontWithName:kFontLightName size:self.emailSubtitleLabel.font.pointSize];
    self.emailSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.emailSubtitleLabel.text = STRING_SUBSCRIVE_UNSUBSCRIVE;
    self.emailSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.emailArrow.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.addressesTitleLabel.font = [UIFont fontWithName:kFontLightName size:self.addressesTitleLabel.font.pointSize];
    self.addressesTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.addressesTitleLabel.text = STRING_MY_ADDRESSES;
    self.addressesTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.addressesSubtitleLabel.font = [UIFont fontWithName:kFontLightName size:self.addressesSubtitleLabel.font.pointSize];
    self.addressesSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.addressesSubtitleLabel.text = STRING_CREATE_EDIT_ADDRESS;
    self.addressesSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.addressesArrow.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.notificationView.layer.cornerRadius = 5.0f;
    self.notificationView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.notificationSettingsTitleLabel.font = [UIFont fontWithName:kFontRegularName size:self.notificationSettingsTitleLabel.font.pointSize];
    self.notificationSettingsTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.notificationSettingsTitleLabel.text = STRING_NOTIFICATIONS_SETTINGS;
    self.notificationViewTopSeparator.backgroundColor = UIColorFromRGB(0xfaa41a);
    self.notificationAndSoundSeparator.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.notificationTitleLabel.font = [UIFont fontWithName:kFontLightName size:self.notificationTitleLabel.font.pointSize];
    self.notificationTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.notificationTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.notificationTitleLabel.text = STRING_NOTIFICATIONS;
    self.notificationTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.notificationTitleLabel.font = [UIFont fontWithName:kFontLightName size:self.notificationTitleLabel.font.pointSize];
    self.notificationTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.notificationSubtitleLabel.font = [UIFont fontWithName:kFontLightName size:self.notificationSubtitleLabel.font.pointSize];
    self.notificationSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.notificationSubtitleLabel.text = STRING_RECEIVE_EXCLUSIVE_OFFERS;
    self.notificationSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.notificationSwitch.translatesAutoresizingMaskIntoConstraints = YES;
    [self.notificationSwitch setAccessibilityLabel:STRING_NOTIFICATIONS];
    
    self.soundTitleLabel.font = [UIFont fontWithName:kFontLightName size:self.soundTitleLabel.font.pointSize];
    self.soundTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.soundTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.soundTitleLabel.text = STRING_SOUND;
    
    self.soundSubtitleLabel.font = [UIFont fontWithName:kFontLightName size:self.soundSubtitleLabel.font.pointSize];
    self.soundSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.soundSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.soundSubtitleLabel.text = STRING_PLAY_SOUND;
    
    self.soundSwitch.translatesAutoresizingMaskIntoConstraints = YES;
    [self.soundSwitch setAccessibilityLabel:STRING_SOUND];
    
    self.appSharingView.layer.cornerRadius = 5.0f;
    self.appSharingView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.appSharingTitleLabel.font = [UIFont fontWithName:kFontRegularName size:self.appSharingTitleLabel.font.pointSize];
    self.appSharingTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.appSharingTitleLabel.text = STRING_APP_SHARING;
    
    self.appSharingSeparator.backgroundColor = UIColorFromRGB(0xfaa41a);
    
    self.shareAppTitleLabel.font = [UIFont fontWithName:kFontLightName size:self.shareAppTitleLabel.font.pointSize];
    self.shareAppTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.shareAppTitleLabel.text = STRING_SHARE_THE_APP;
    self.shareAppTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.shareAppSubtitleLabel.font = [UIFont fontWithName:kFontLightName size:self.shareAppSubtitleLabel.font.pointSize];
    self.shareAppSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.shareAppSubtitleLabel.text = STRING_CAN_SHARE_APP_WITH_FRIENDS;
    self.shareAppSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.shareAppArrow.translatesAutoresizingMaskIntoConstraints = YES;
    
    
    self.countrySettingsView.layer.cornerRadius = 5.0f;
    self.countrySettingsView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.countrySettingsTitleLabel.font = [UIFont fontWithName:kFontRegularName size:self.countrySettingsTitleLabel.font.pointSize];
    self.countrySettingsTitleLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.countrySettingsTitleLabel.text = STRING_CHOOSE_COUNTRY;
    
    self.countrySeparator.backgroundColor = UIColorFromRGB(0xfaa41a);
    
    self.countryTitleLabel.font = [UIFont fontWithName:kFontLightName size:self.countryTitleLabel.font.pointSize];
    self.countryTitleLabel.textColor = UIColorFromRGB(0x666666);
    self.countryTitleLabel.text = STRING_COUNTRY;
    self.countryTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.countrySubtitleLabel.font = [UIFont fontWithName:kFontLightName size:self.countrySubtitleLabel.font.pointSize];
    self.countrySubtitleLabel.textColor = UIColorFromRGB(0x666666);
    self.countrySubtitleLabel.text = [RIApi getCountryNameInUse];
    self.countrySubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.countryFlag.translatesAutoresizingMaskIntoConstraints = YES;
    NSURL* flagURL = [NSURL URLWithString:[RIApi getCountryFlagInUse]];
    [self.countryFlag setImageWithURL:flagURL];
//    self.countryFlag.layer.cornerRadius = self.countryFlag.frame.size.height /2;
//    self.countryFlag.layer.masksToBounds = YES;
//    self.countryFlag.layer.borderWidth = 0;
    
    self.languageSeparator.backgroundColor = UIColorFromRGB(0xcccccc);
    
    BOOL hasMoreThanOneLanguage = [RICountryConfiguration getCurrentConfiguration].languages.count>1?YES:NO;
    
    self.languageTitleLabel.font = [UIFont fontWithName:kFontLightName size:self.languageTitleLabel.font.pointSize];
    if (hasMoreThanOneLanguage) {
        self.languageTitleLabel.textColor = UIColorFromRGB(0x666666);
    } else {
        self.languageTitleLabel.textColor = UIColorFromRGB(0xcccccc);
    }
    self.languageTitleLabel.text = STRING_LANGUAGE;
    self.languageTitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.languageSubtitleLabel.font = [UIFont fontWithName:kFontLightName size:self.languageSubtitleLabel.font.pointSize];
    if (hasMoreThanOneLanguage) {
        self.languageSubtitleLabel.textColor = UIColorFromRGB(0x666666);
    } else {
        self.languageSubtitleLabel.textColor = UIColorFromRGB(0xcccccc);
    }
    self.languageSubtitleLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    NSString *locale = [[NSUserDefaults standardUserDefaults] stringForKey:kLanguageCodeKey];
    for (RILanguage* language in [RICountryConfiguration getCurrentConfiguration].languages) {
        if ([language.langCode isEqualToString:locale]) {
            //found it
            self.languageSubtitleLabel.text = language.langName;
        }
    }

    self.languageArrow.translatesAutoresizingMaskIntoConstraints = YES;
    
    
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
    
    self.chooseCountryClickableView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.chooseCountryClickableView addTarget:self
                                        action:@selector(chooseCountry)
                              forControlEvents:UIControlEventTouchUpInside];
    
    self.languageClickableView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.languageClickableView addTarget:self
                                   action:@selector(openLanguagePicker)
                         forControlEvents:UIControlEventTouchUpInside];
    self.languageClickableView.enabled = hasMoreThanOneLanguage;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector( applicationDidEnterBackgroundNotification:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupViews:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification*)notification
{
    if(VALID_NOTEMPTY(self.currentPopoverController, UIPopoverController))
    {
        [self.currentPopoverController dismissPopoverAnimated:NO];
    }
    
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
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
    if(VALID(self.languagePicker, JAPicker))
    {
        [self.languagePicker removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.currentPopoverController, UIPopoverController))
    {
        [self.currentPopoverController dismissPopoverAnimated:NO];
    }
    
    [self showLoading];
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    
    [self setupViews:newWidth toInterfaceOrientation:toInterfaceOrientation];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupViews:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.scrollView setFrame:[self viewBounds]];
    
    CGFloat startingY = [self viewBounds].origin.y;
    if (VALID_NOTEMPTY(self.scrollView, UIScrollView)) {
        startingY = 0.0f;
    }
    
    [self.accountView setFrame:CGRectMake(self.accountView.frame.origin.x,
                                          startingY + 6.0f,
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
                                               CGRectGetMaxY(self.accountView.frame) + 6.0f,
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
    
    CGFloat scrollViewHeight = CGRectGetMaxY(self.appSharingView.frame) + 6.0f;
    if (ISEMPTY([RICountry getUniqueCountry])) {
        self.countrySettingsView.hidden = NO;
        
        [self.countrySettingsView setFrame:CGRectMake(self.countrySettingsView.frame.origin.x,
                                                      CGRectGetMaxY(self.appSharingView.frame) + 6.0f,
                                                      width - (self.notificationView.frame.origin.x * 2),
                                                      self.countrySettingsView.frame.size.height)];
        
        [self.chooseCountryClickableView setFrame:CGRectMake(self.chooseCountryClickableView.frame.origin.x,
                                                             self.chooseCountryClickableView.frame.origin.y,
                                                             self.countrySettingsView.frame.size.width,
                                                             self.chooseCountryClickableView.frame.size.height)];
        
        [self.languageClickableView setFrame:CGRectMake(self.languageClickableView.frame.origin.x,
                                                        self.languageClickableView.frame.origin.y,
                                                        self.countrySettingsView.frame.size.width,
                                                        self.languageClickableView.frame.size.height)];
        
        scrollViewHeight = CGRectGetMaxY(self.countrySettingsView.frame) + 6.0f;
    } else {
        self.countrySettingsView.hidden = YES;
    }

    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, scrollViewHeight)];
    
    CGFloat leftMargin = 17.0f;
    CGFloat rightMargin = 17.0f;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        leftMargin = 128.0f;
        rightMargin = 128.0f;
    }
    
    [self.accountViewTopSeparator setFrame:CGRectMake(self.accountViewTopSeparator.frame.origin.x,
                                                      self.accountViewTopSeparator.frame.origin.y,
                                                      self.accountView.frame.size.width,
                                                      self.accountViewTopSeparator.frame.size.height)];
    
    [self.accountAndEmailSeparator setFrame:CGRectMake(self.accountAndEmailSeparator.frame.origin.x,
                                                       self.accountAndEmailSeparator.frame.origin.y,
                                                       self.accountView.frame.size.width,
                                                       self.accountAndEmailSeparator.frame.size.height)];
    
    [self.emailAndAddressesSeparator setFrame:CGRectMake(self.emailAndAddressesSeparator.frame.origin.x,
                                                         self.emailAndAddressesSeparator.frame.origin.y,
                                                         self.accountView.frame.size.width,
                                                         self.emailAndAddressesSeparator.frame.size.height)];
    
    [self.notificationViewTopSeparator setFrame:CGRectMake(self.notificationViewTopSeparator.frame.origin.x,
                                                           self.notificationViewTopSeparator.frame.origin.y,
                                                           self.accountView.frame.size.width,
                                                           self.notificationViewTopSeparator.frame.size.height)];
    
    [self.notificationAndSoundSeparator setFrame:CGRectMake(self.notificationAndSoundSeparator.frame.origin.x,
                                                            self.notificationAndSoundSeparator.frame.origin.y,
                                                            self.accountView.frame.size.width,
                                                            self.notificationAndSoundSeparator.frame.size.height)];
    
    [self.appSharingSeparator setFrame:CGRectMake(self.appSharingSeparator.frame.origin.x,
                                                  self.appSharingSeparator.frame.origin.y,
                                                  self.accountView.frame.size.width,
                                                  self.appSharingSeparator.frame.size.height)];
    
    [self.countrySeparator setFrame:CGRectMake(self.countrySeparator.frame.origin.x,
                                               self.countrySeparator.frame.origin.y,
                                               self.countrySettingsView.frame.size.width,
                                               self.countrySeparator.frame.size.height)];

    [self.languageSeparator setFrame:CGRectMake(self.languageSeparator.frame.origin.x,
                                                self.languageSeparator.frame.origin.y,
                                                self.countrySettingsView.frame.size.width,
                                                self.languageSeparator.frame.size.height)];
    
    [self.accountSettingsTitleLabel setFrame: CGRectMake(6.0f,
                                                         self.accountSettingsTitleLabel.frame.origin.y,
                                                         self.accountSettingsTitleLabel.frame.size.width,
                                                         self.accountSettingsTitleLabel.frame.size.height)];
    
    [self.notificationSettingsTitleLabel setFrame: CGRectMake(6.0f,
                                                              self.notificationSettingsTitleLabel.frame.origin.y,
                                                              self.notificationSettingsTitleLabel.frame.size.width,
                                                              self.notificationSettingsTitleLabel.frame.size.height)];
    
    [self.appSharingTitleLabel setFrame: CGRectMake(6.0f,
                                                    self.appSharingTitleLabel.frame.origin.y,
                                                    self.appSharingTitleLabel.frame.size.width,
                                                    self.appSharingTitleLabel.frame.size.height)];
    
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
    
    [self.countryTitleLabel setFrame:CGRectMake(leftMargin,
                                                self.countryTitleLabel.frame.origin.y,
                                                self.countryTitleLabel.frame.size.width,
                                                self.countryTitleLabel.frame.size.height)];
    
    [self.countrySubtitleLabel setFrame:CGRectMake(leftMargin,
                                                   self.countrySubtitleLabel.frame.origin.y,
                                                   self.countrySubtitleLabel.frame.size.width,
                                                   self.countrySubtitleLabel.frame.size.height)];
    
    [self.countryFlag setFrame:CGRectMake(self.countrySettingsView.frame.size.width - self.countryFlag.frame.size.width - rightMargin,
                                          self.countryFlag.frame.origin.y,
                                          self.countryFlag.frame.size.width,
                                          self.countryFlag.frame.size.height)];
    
    [self.languageTitleLabel setFrame:CGRectMake(leftMargin,
                                                 self.languageTitleLabel.frame.origin.y,
                                                 self.languageTitleLabel.frame.size.width,
                                                 self.languageTitleLabel.frame.size.height)];
    
    [self.languageSubtitleLabel setFrame:CGRectMake(leftMargin,
                                                    self.languageSubtitleLabel.frame.origin.y,
                                                    self.languageSubtitleLabel.frame.size.width,
                                                    self.languageSubtitleLabel.frame.size.height)];
    
    [self.languageArrow setFrame:CGRectMake(self.countrySettingsView.frame.size.width - self.languageArrow.frame.size.width - rightMargin,
                                            self.languageArrow.frame.origin.y,
                                            self.languageArrow.frame.size.width,
                                            self.languageArrow.frame.size.height)];
    
    if(RI_IS_RTL){
        
        [self.accountView  flipSubviewPositions];
        [self.accountView flipSubviewImages];
        [self.notificationView flipSubviewPositions];
        [self.appSharingView flipSubviewPositions];
        [self.appSharingView flipSubviewImages];
        [self.countrySettingsView flipSubviewPositions];
        [self.countrySettingsView flipSubviewImages];
        
        if(self.stillRTL){
            
            [self.accountView flipSubviewAlignments];
            [self.notificationView flipSubviewAlignments];
            [self.appSharingView flipSubviewAlignments];
            [self.countrySettingsView flipSubviewAlignments];
            self.stillRTL= NO;
        }
        
        
    }
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
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    NSArray *appActivities = @[];
    
    UIActivity *fbmActivity = [[AQSFacebookMessengerActivity alloc] init];
    UIActivity *whatsAppActivity = [[JBWhatsAppActivity alloc] init];
    WhatsAppMessage *whatsAppMsg;
    
    JAActivityViewController  *activityController = [[JAActivityViewController alloc] initWithActivityItems:@[] applicationActivities:appActivities];
    NSString *shareTheAppString = [[NSString alloc] initWithString:[NSString stringWithFormat:STRING_SHARE_APP, APP_NAME]];
    if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        
        appActivities = @[fbmActivity, whatsAppActivity];
    }
    
    if ([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
    {
        whatsAppMsg = [[WhatsAppMessage alloc] initWithMessage:[NSString stringWithFormat:@"%@ %@",shareTheAppString, kAppStoreUrl] forABID:nil];
        
        activityController = [[JAActivityViewController alloc] initWithActivityItems:@[shareTheAppString, [NSURL URLWithString:kAppStoreUrl], whatsAppMsg ] applicationActivities:appActivities];
        
    }else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
    {
        whatsAppMsg = [[WhatsAppMessage alloc] initWithMessage:[NSString stringWithFormat:@"%@ %@",shareTheAppString, kAppStoreUrlDaraz] forABID:nil];
        
        activityController = [[JAActivityViewController alloc] initWithActivityItems:@[shareTheAppString, [NSURL URLWithString:kAppStoreUrlDaraz], whatsAppMsg] applicationActivities:appActivities];
        
    }else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
    {
        whatsAppMsg = [[WhatsAppMessage alloc] initWithMessage:[NSString stringWithFormat:@"%@ %@",shareTheAppString, kAppStoreUrlShop] forABID:nil];
        
        activityController = [[JAActivityViewController alloc] initWithActivityItems:@[shareTheAppString, [NSURL URLWithString:kAppStoreUrlShop], whatsAppMsg] applicationActivities:appActivities];
        
    }else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
    {
        whatsAppMsg = [[WhatsAppMessage alloc] initWithMessage:[NSString stringWithFormat:@"%@ %@",shareTheAppString, kAppStoreUrlBamilo]  forABID:nil];
        
        activityController = [[JAActivityViewController alloc] initWithActivityItems:@[shareTheAppString, [NSURL URLWithString:kAppStoreUrlBamilo], whatsAppMsg] applicationActivities:appActivities];
    }
    
    
    
    [activityController setValue:[NSString stringWithFormat:STRING_SHARE_APP, APP_NAME] forKey:@"subject"];
    
    
    
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        CGRect sharePopoverRect = CGRectMake(self.shareAppClickableView.frame.size.width / 2,
                                             self.shareAppClickableView.frame.size.height - 6.0f,
                                             0.0f,
                                             0.0f);
        
        UIPopoverController* popoverController =
        [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popoverController presentPopoverFromRect:sharePopoverRect inView:self.shareAppClickableView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        popoverController.passthroughViews = nil;
        self.currentPopoverController = popoverController;
    }
    else
    {
        [self presentViewController:activityController animated:YES completion:nil];
    }
}


-(void)showUserDataSavedMessage
{
    [self showMessage:STRING_CHANGED_PASSWORD_SUCCESS success:YES];
}

- (void)showEmailNotificationsSavedMessage
{
    [self showMessage:STRING_PREFERENCES_UPDATED success:YES];
}

- (void)chooseCountry
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowChooseCountryScreenNotification object:@{@"show_back_button":[NSNumber numberWithBool:YES]}];
}

#pragma mark - Picker

-(void)removePickerView
{
    if(VALID_NOTEMPTY(self.languagePicker, JAPicker))
    {
        [self.languagePicker removeFromSuperview];
        self.languagePicker = nil;
    }
}

- (void)openLanguagePicker
{
    [self removePickerView];
    
    self.languagePicker = [[JAPicker alloc] initWithFrame:[self viewBounds]];
    [self.languagePicker setDelegate:self];
    
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    NSString* autoSelected;
    for (RILanguage* language in [RICountryConfiguration getCurrentConfiguration].languages) {
        if (VALID_NOTEMPTY(language, RILanguage)) {
            [dataSource addObject:language.langName];
            if ([language.langName isEqualToString:self.languageSubtitleLabel.text]) {
                autoSelected = language.langName;
            }
        }
    }
    
    [self.languagePicker setDataSourceArray:[dataSource copy]
                               previousText:autoSelected
                            leftButtonTitle:nil];
    
    CGFloat pickerViewHeight = [self viewBounds].size.height;
    CGFloat pickerViewWidth = [self viewBounds].size.width;
    [self.languagePicker setFrame:CGRectMake(0.0f,
                                             pickerViewHeight,
                                             pickerViewWidth,
                                             pickerViewHeight)];
    [self.view addSubview:self.languagePicker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.languagePicker setFrame:CGRectMake(0.0f,
                                                                  [self viewBounds].origin.y,
                                                                  pickerViewWidth,
                                                                  pickerViewHeight)];
                     }];
}

- (void)selectedRow:(NSInteger)selectedRow
{
    [self removePickerView];
    RILanguage* selectedLanguage = [[RICountryConfiguration getCurrentConfiguration].languages objectAtIndex:selectedRow];
    if ([selectedLanguage.langName isEqualToString:self.languageSubtitleLabel.text]) {
        //do nothing
    } else {
        
        [self showLoading];
        [RICountry getCountriesWithSuccessBlock:^(id countries) {
            //find country
            for (RICountry* country in countries) {
                if ([country.name isEqualToString:self.countrySubtitleLabel.text]) {
                    //found it
                    //find language
                    for (RILanguage* language in country.languages) {
                        if ([language.langCode isEqualToString:selectedLanguage.langCode]) {
                            //found it
                            country.selectedLanguage = language;
                            [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification object:country];
                            break;
                        }
                    }
                    break;
                }
            }
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            [self hideLoading];
        }];
    }
}


@end
