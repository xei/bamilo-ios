//
//  JAMyAccountViewController.m
//  Jumia
//
//  Created by Jose Mota on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMyAccountViewController.h"
#import "JAProductInfoHeaderLine.h"
#import "JAProductInfoSubLine.h"
#import "JAProductInfoSubtitleLine.h"
#import "JAProductInfoSwitchLine.h"
#import "JAProductInfoRightSubtitleLine.h"
#import "JAPicker.h"
#import "JAActivityViewController.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "AQSFacebookMessengerActivity.h"
#import "JBWhatsAppActivity.h"
#import "RITarget.h"

@interface JAMyAccountViewController () <JAPickerDelegate>

@property (strong, nonatomic) UIScrollView* mainScrollView;

@property (strong, nonatomic) JAProductInfoHeaderLine *accountSettingsHeaderLine;
@property (strong, nonatomic) JAProductInfoSubLine *profileSubLine;
@property (strong, nonatomic) JAProductInfoSubLine *myAddressesSubLine;

@property (strong, nonatomic) JAProductInfoHeaderLine *notificationSettingsHeaderLine;
@property (strong, nonatomic) JAProductInfoSwitchLine *pushNotificationsSwitchLine;
@property (strong, nonatomic) JAProductInfoSubLine *emailNotificationsSubLine;

@property (strong, nonatomic) JAProductInfoHeaderLine *shopSettingsHeaderLine;
@property (strong, nonatomic) JAProductInfoSubtitleLine *countrySubtitleLine;
@property (strong, nonatomic) JAProductInfoSubtitleLine *languageSubtitleLine;

@property (strong, nonatomic) JAProductInfoHeaderLine *moreSettingsHeaderLine;
@property (strong, nonatomic) JAProductInfoRightSubtitleLine *appVersionSubLine;
@property (strong, nonatomic) NSMutableArray *moreSettingsLines;
@property (strong, nonatomic) NSArray *moreFaqAndTermsItems;

@property (strong, nonatomic) JAProductInfoHeaderLine *appSocialHeaderLine;
@property (strong, nonatomic) JAProductInfoSubLine *shareTheAppSubLine;
@property (strong, nonatomic) JAProductInfoSubLine *rateTheAppSubLine;

@property (strong, nonatomic) UIPopoverController *currentPopoverController;

@property (strong, nonatomic) JAPicker *languagePicker;

@end

@implementation JAMyAccountViewController

- (UIScrollView *)mainScrollView
{
    if (!VALID(_mainScrollView, UIScrollView)) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.viewBounds];
        [self.view addSubview:_mainScrollView];
        [_mainScrollView addSubview:self.accountSettingsHeaderLine];
        [_mainScrollView addSubview:self.profileSubLine];
        [_mainScrollView addSubview:self.myAddressesSubLine];
        [_mainScrollView addSubview:self.notificationSettingsHeaderLine];
        [_mainScrollView addSubview:self.pushNotificationsSwitchLine];
        [_mainScrollView addSubview:self.emailNotificationsSubLine];
        [_mainScrollView addSubview:self.shopSettingsHeaderLine];
        [_mainScrollView addSubview:self.countrySubtitleLine];
        [_mainScrollView addSubview:self.languageSubtitleLine];
        [_mainScrollView addSubview:self.moreSettingsHeaderLine];
        [_mainScrollView addSubview:self.appVersionSubLine];
        [self getFaqAndTerms];
        [_mainScrollView addSubview:self.appSocialHeaderLine];
        [_mainScrollView addSubview:self.shareTheAppSubLine];
        [_mainScrollView addSubview:self.rateTheAppSubLine];
    }
    return _mainScrollView;
}

- (JAProductInfoHeaderLine *)accountSettingsHeaderLine
{
    if (!VALID(_accountSettingsHeaderLine, JAProductInfoHeaderLine)) {
        _accountSettingsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.mainScrollView.width, kProductInfoHeaderLineHeight)];
        [_accountSettingsHeaderLine setTitle:[STRING_ACCOUNT_SETTINGS uppercaseString]];
    }
    return _accountSettingsHeaderLine;
}

- (JAProductInfoSubLine *)profileSubLine
{
    if (!VALID(_profileSubLine, JAProductInfoSubLine)) {
        _profileSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.accountSettingsHeaderLine.frame), self.mainScrollView.width, kProductInfoSubLineHeight)];
        [_profileSubLine setTopSeparatorVisibility:NO];
        [_profileSubLine setTitle:STRING_PROFILE];
        [_profileSubLine addTarget:self action:@selector(profileSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _profileSubLine;
}

- (JAProductInfoSubLine *)myAddressesSubLine
{
    if (!VALID(_myAddressesSubLine, JAProductInfoSubLine)) {
        _myAddressesSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.profileSubLine.frame), self.mainScrollView.width, kProductInfoSubLineHeight)];
        [_myAddressesSubLine setTitle:STRING_MY_ADDRESSES];
        [_myAddressesSubLine addTarget:self action:@selector(myAddressesSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _myAddressesSubLine;
}

- (JAProductInfoHeaderLine *)notificationSettingsHeaderLine
{
    if (!VALID(_notificationSettingsHeaderLine, JAProductInfoHeaderLine)) {
        _notificationSettingsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.myAddressesSubLine.frame), self.mainScrollView.width, kProductInfoHeaderLineHeight)];
        [_notificationSettingsHeaderLine setTitle:[STRING_NOTIFICATIONS_SETTINGS uppercaseString]];
    }
    return _notificationSettingsHeaderLine;
}

- (JAProductInfoSwitchLine *)pushNotificationsSwitchLine
{
    if (!VALID(_pushNotificationsSwitchLine, JAProductInfoSwitchLine)) {
        _pushNotificationsSwitchLine = [[JAProductInfoSwitchLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.notificationSettingsHeaderLine.frame), self.mainScrollView.width, kProductInfoSubLineHeight)];
        [_pushNotificationsSwitchLine setTopSeparatorVisibility:NO];
        [_pushNotificationsSwitchLine setTitle:STRING_PUSH_NOTIFICATIONS];
        [_pushNotificationsSwitchLine.lineSwitch setAccessibilityLabel:STRING_NOTIFICATIONS];
        [_pushNotificationsSwitchLine.lineSwitch addTarget:self action:@selector(changeNotification) forControlEvents:UIControlEventValueChanged];
    }
    return _pushNotificationsSwitchLine;
}

- (JAProductInfoSubLine *)emailNotificationsSubLine
{
    if (!VALID(_emailNotificationsSubLine, JAProductInfoSubLine)) {
        _emailNotificationsSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.pushNotificationsSwitchLine.frame), self.mainScrollView.width, kProductInfoSubLineHeight)];
        [_emailNotificationsSubLine setTitle:STRING_EMAIL_NOTIFICATIONS];
        [_emailNotificationsSubLine addTarget:self action:@selector(emailNotificationSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emailNotificationsSubLine;
}

- (JAProductInfoHeaderLine *)shopSettingsHeaderLine
{
    if (!VALID(_shopSettingsHeaderLine, JAProductInfoHeaderLine)) {
        _shopSettingsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.emailNotificationsSubLine.frame), self.mainScrollView.width, kProductInfoHeaderLineHeight)];
        [_shopSettingsHeaderLine setTitle:[STRING_SHOP_SETTINGS uppercaseString]];
    }
    return _shopSettingsHeaderLine;
}

- (JAProductInfoSubtitleLine *)countrySubtitleLine
{
    if (!VALID(_countrySubtitleLine, JAProductInfoSubtitleLine)) {
        _countrySubtitleLine = [[JAProductInfoSubtitleLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shopSettingsHeaderLine.frame), self.mainScrollView.width, kProductInfoSubtitleLineHeight)];
        [_countrySubtitleLine setTopSeparatorVisibility:NO];
        [_countrySubtitleLine setTitle:STRING_COUNTRY];
        [_countrySubtitleLine setSubTitle:@""];
        [_countrySubtitleLine addTarget:self action:@selector(countrySelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _countrySubtitleLine;
}

- (JAProductInfoSubtitleLine *)languageSubtitleLine
{
    if (!VALID(_languageSubtitleLine, JAProductInfoSubtitleLine)) {
        _languageSubtitleLine = [[JAProductInfoSubtitleLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.countrySubtitleLine.frame), self.mainScrollView.width, kProductInfoSubtitleLineHeight)];
        [_languageSubtitleLine setTitle:STRING_LANGUAGE];
        [_languageSubtitleLine setSubTitle:@""];
        [_languageSubtitleLine addTarget:self action:@selector(openLanguagePicker) forControlEvents:UIControlEventTouchUpInside];
    }
    return _languageSubtitleLine;
}

- (JAProductInfoHeaderLine *)moreSettingsHeaderLine
{
    if (!VALID(_moreSettingsHeaderLine, JAProductInfoHeaderLine)) {
        _moreSettingsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.languageSubtitleLine.frame), self.mainScrollView.width, kProductInfoHeaderLineHeight)];
        [_moreSettingsHeaderLine setTitle:[STRING_MORE uppercaseString]];
    }
    return _moreSettingsHeaderLine;
}

- (JAProductInfoRightSubtitleLine *)appVersionSubLine
{
    if (!VALID(_appVersionSubLine, JAProductInfoRightSubtitleLine)) {
        _appVersionSubLine = [[JAProductInfoRightSubtitleLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.moreSettingsHeaderLine.frame), self.mainScrollView.width, kProductInfoRightSubtitleLineHeight)];
        [_appVersionSubLine setTopSeparatorVisibility:NO];
        if([self isLastVersion])
        {
            [_appVersionSubLine setHeight:kProductInfoSubLineHeight];
        }else{
            [_appVersionSubLine setRightSubTitle:STRING_UPDATE_NOW];
            [_appVersionSubLine addTarget:self action:@selector(openAppStore) forControlEvents:UIControlEventTouchUpInside];
        }
//        version
        [_appVersionSubLine setRightTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
//        build
//        [_appVersionSubLine setRightTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        [_appVersionSubLine setTitle:STRING_APP_VERSION];
        self.moreSettingsLines = [[NSMutableArray alloc] initWithObjects:_appVersionSubLine, nil];
    }
    return _appVersionSubLine;
}

- (JAProductInfoHeaderLine *)appSocialHeaderLine
{
    if (!VALID(_appSocialHeaderLine, JAProductInfoHeaderLine)) {
        _appSocialHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([(JAProductInfoBaseLine *)[self.moreSettingsLines lastObject] frame]), self.mainScrollView.width, kProductInfoHeaderLineHeight)];
        [_appSocialHeaderLine setTitle:[STRING_APP_SOCIAL uppercaseString]];
    }
    return _appSocialHeaderLine;
}

- (JAProductInfoSubLine *)shareTheAppSubLine
{
    if (!VALID(_shareTheAppSubLine, JAProductInfoSubLine)) {
        _shareTheAppSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.appSocialHeaderLine.frame), self.mainScrollView.width, kProductInfoSubLineHeight)];
        [_shareTheAppSubLine setTopSeparatorVisibility:NO];
        [_shareTheAppSubLine setTitle:STRING_SHARE_THE_APP];
        [_shareTheAppSubLine addTarget:self action:@selector(shareTheAppSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareTheAppSubLine;
}

- (JAProductInfoSubLine *)rateTheAppSubLine
{
    if (!VALID(_rateTheAppSubLine, JAProductInfoSubLine)) {
        _rateTheAppSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.shareTheAppSubLine.frame), self.mainScrollView.width, kProductInfoSubLineHeight)];
        [_rateTheAppSubLine setTitle:STRING_RATE_THE_APP];
        [_rateTheAppSubLine addTarget:self action:@selector(rateTheAppSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rateTheAppSubLine;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"CustomerAccount";
    
    self.navBarLayout.title = STRING_MY_ACCOUNT;
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self mainScrollView];
    
    BOOL isNotiActive = [[NSUserDefaults standardUserDefaults] boolForKey: kChangeNotificationsOptions];
    self.pushNotificationsSwitchLine.lineSwitch.on = isNotiActive;
    
    NSString *locale = [[NSUserDefaults standardUserDefaults] stringForKey:kLanguageCodeKey];
    for (RILanguage* language in [RICountryConfiguration getCurrentConfiguration].languages) {
        if ([language.langCode isEqualToString:locale]) {
            //found it
            self.languageSubtitleLine.subTitle = language.langName;
        }
    }
    
    [self.countrySubtitleLine setSubTitle:[RIApi getCountryNameInUse]];
    
    [self.countrySubtitleLine setImageWithURL:[RIApi getCountryFlagInUse]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (!CGRectEqualToRect(self.mainScrollView.frame, self.viewBounds)) {
        [self reloadViews];
    }
}

- (void)appWillEnterForeground
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

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    if(VALID_NOTEMPTY(self.currentPopoverController, UIPopoverController))
    {
        [self.currentPopoverController dismissPopoverAnimated:NO];
    }
}

- (void)reloadViews
{
    [self.mainScrollView setFrame:self.viewBounds];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, CGRectGetMaxY(self.rateTheAppSubLine.frame))];
    
    [self.accountSettingsHeaderLine setWidth:self.mainScrollView.width];
    [self.profileSubLine setWidth:self.mainScrollView.width];
    [self.myAddressesSubLine setWidth:self.mainScrollView.width];
    [self.notificationSettingsHeaderLine setWidth:self.mainScrollView.width];
    [self.pushNotificationsSwitchLine setWidth:self.mainScrollView.width];
    [self.emailNotificationsSubLine setWidth:self.mainScrollView.width];
    [self.shopSettingsHeaderLine setWidth:self.mainScrollView.width];
    [self.countrySubtitleLine setWidth:self.mainScrollView.width];
    [self.languageSubtitleLine setWidth:self.mainScrollView.width];
    [self.moreSettingsHeaderLine setWidth:self.mainScrollView.width];
    for (UIView *view in self.moreSettingsLines) {
        [view setWidth:self.mainScrollView.width];
    }
    [self.appSocialHeaderLine setWidth:self.mainScrollView.width];
    [self.shareTheAppSubLine setWidth:self.mainScrollView.width];
    [self.rateTheAppSubLine setWidth:self.mainScrollView.width];
    
    if (RI_IS_RTL)
    {
        [self.view flipAllSubviews];
    }
}

- (void)adjustViews
{
    [UIView animateWithDuration:.3 animations:^{
        [self.appSocialHeaderLine setYBottomOf:[self.moreSettingsLines lastObject] at:0.f];
        [self.shareTheAppSubLine setYBottomOf:self.appSocialHeaderLine at:0.f];
        [self.rateTheAppSubLine setYBottomOf:self.shareTheAppSubLine at:0.f];
        [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, CGRectGetMaxY(self.rateTheAppSubLine.frame))];
    }];
}

#pragma mark - Data

- (void)getFaqAndTerms
{
    [self showLoading];
    [RICountry getCountryFaqAndTermsWithSuccessBlock:^(NSArray *faqAndTerms) {
        [self hideLoading];
        [self removeErrorView];
        self.moreFaqAndTermsItems = [faqAndTerms copy];
        int i = 0;
        for (id object in faqAndTerms) {
            NSString *label = [object objectForKey:@"label"];
            if (VALID_NOTEMPTY([object objectForKey:@"label"], NSString)) {
                JAProductInfoSubLine *moreItemLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([(JAProductInfoBaseLine *)[self.moreSettingsLines lastObject] frame]), self.mainScrollView.width, kProductInfoSubLineHeight)];
                [moreItemLine setTitle:label];
                [moreItemLine addTarget:self action:@selector(moreSelection:) forControlEvents:UIControlEventTouchUpInside];
                [moreItemLine setTag:i];
                [self.moreSettingsLines addObject:moreItemLine];
                [self.mainScrollView addSubview:moreItemLine];
            }
            i++;
        }
        [self adjustViews];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        [self hideLoading];
        if (apiResponse == RIApiResponseNoInternetConnection) {
            [self showErrorView:YES startingY:0 selector:@selector(getFaqAndTerms) objects:nil];
        }
    }];
}

- (BOOL)isLastVersion
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    if ([myNumber compare:[RIApi getApiInformation].curVersion] == NSOrderedAscending) {
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - Actions

- (void)moreSelection:(UIButton *)sender
{
    if (VALID_NOTEMPTY([self.moreFaqAndTermsItems objectAtIndex:sender.tag], NSDictionary)) {
        NSString *targetString = [[self.moreFaqAndTermsItems objectAtIndex:sender.tag] objectForKey:@"target"];
        NSString *label = [[self.moreFaqAndTermsItems objectAtIndex:sender.tag] objectForKey:@"label"];
        if (VALID_NOTEMPTY(targetString, NSString)) {
            
            NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
            
            [userInfo setObject:label forKey:@"title"];
            [userInfo setObject:targetString forKey:@"targetString"];
            [userInfo setObject:@YES forKey:@"show_back_button"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithShopUrlNofication
                                                                object:nil
                                                              userInfo:userInfo];
        }
    }
}

- (void)profileSelection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowUserDataScreenNotification
                                                        object:@{@"animated":[NSNumber numberWithBool:YES]}];
}
- (void)myAddressesSelection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                     object:@{@"animated":[NSNumber numberWithBool:YES]}
                                                   userInfo:@{@"from_checkout":[NSNumber numberWithBool:NO]}];
}

- (void)emailNotificationSelection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowEmailNotificationsScreenNotification
                                                        object:@{@"animated":[NSNumber numberWithBool:YES]}];
}

- (void)countrySelection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowChooseCountryScreenNotification object:@{@"show_back_button":[NSNumber numberWithBool:YES]}];
}

- (void)shareTheAppSelection
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
        CGRect sharePopoverRect = CGRectMake(self.shareTheAppSubLine.frame.size.width / 2,
                                             self.shareTheAppSubLine.frame.size.height - 6.0f,
                                             0.0f,
                                             0.0f);
        
        UIPopoverController* popoverController =
        [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popoverController presentPopoverFromRect:sharePopoverRect inView:self.shareTheAppSubLine permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        popoverController.passthroughViews = nil;
        self.currentPopoverController = popoverController;
    }
    else
    {
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)rateTheAppSelection
{
    [self openAppStore];
}

- (void)openAppStore
{
    static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/apple-store/id%@";
    static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    
    NSString *appStoreId;
    
    if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"]) {
        appStoreId = kAppStoreId;
    } else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"]) {
        appStoreId = kAppStoreIdDaraz;
    } else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"]) {
        appStoreId = kAppStoreIdShop;
    } else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"]) {
        appStoreId = kAppStoreIdBamilo;
    }
    
    NSURL *appStoreLink = [NSURL URLWithString:
                           [NSString stringWithFormat:
                            ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f) ? iOS7AppStoreURLFormat : iOSAppStoreURLFormat, appStoreId]];
    
    [[UIApplication sharedApplication] openURL:appStoreLink];

}

- (void)changeNotification
{
    if (self.pushNotificationsSwitchLine.lineSwitch.on)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kChangeNotificationsOptions];
    }
    else
    {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kChangeNotificationsOptions];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - JAPicker

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
            if ([language.langName isEqualToString:self.languageSubtitleLine.subTitle]) {
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
    if ([selectedLanguage.langName isEqualToString:self.languageSubtitleLine.subTitle]) {
        //do nothing
    } else {
        
        [self showLoading];
        [RICountry getCountriesWithSuccessBlock:^(id countries) {
            //find country
            for (RICountry* country in countries) {
                if ([country.name isEqualToString:self.countrySubtitleLine.subTitle]) {
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
            
            if (RIApiResponseNoInternetConnection == apiResponse && VALID_NOTEMPTY(errorMessages, NSArray)) {
                [self showMessage:[errorMessages firstObject] success:NO];
            } else {
                RICountry* uniqueCountry = [RICountry getUniqueCountry];
                if (VALID_NOTEMPTY(uniqueCountry, RICountry)) {
                    if ([uniqueCountry.name isEqualToString:self.languageSubtitleLine.subTitle]) {
                        //found it
                        NSArray* languages = [[RICountryConfiguration getCurrentConfiguration].languages array];
                        //find language
                        for (RILanguage* language in languages) {
                            if ([language.langCode isEqualToString:selectedLanguage.langCode]) {
                                //found it
                                uniqueCountry.selectedLanguage = language;
                                [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification object:uniqueCountry];
                                break;
                            }
                        }
                    }
                }
            }
        }];
    }
}

@end
