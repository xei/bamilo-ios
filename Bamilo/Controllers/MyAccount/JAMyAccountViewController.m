//
//  JAMyAccountViewController.m
//  Jumia
//
//  Created by Jose Mota on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMyAccountViewController.h"
#import "JAProductInfoHeaderLine.h"
#import "JAProductInfoSingleLine.h"
#import "JAProductInfoSubtitleLine.h"
#import "JAProductInfoSwitchLine.h"
#import "JAProductInfoRightSubtitleLine.h"
#import "JAPicker.h"
#import "JAActivityViewController.h"
#import "JBWhatsAppActivity.h"
#import "RITarget.h"

#define kAcessoryImageWidthAndHeight 20.0f
#define kLeftAndRightMargin 16.f

@interface JAMyAccountViewController () <JAPickerDelegate>
{
    NSLock *_reloadLock;
}

@property (strong, nonatomic) UIScrollView* mainScrollView;

@property (strong, nonatomic) JAProductInfoHeaderLine *accountSettingsHeaderLine;
@property (strong, nonatomic) JAProductInfoSingleLine *profileSingleLine;
@property (strong, nonatomic) JAProductInfoSingleLine *myAddressesSingleLine;

@property (strong, nonatomic) JAProductInfoHeaderLine *notificationSettingsHeaderLine;
@property (strong, nonatomic) JAProductInfoSwitchLine *pushNotificationsSwitchLine;
@property (strong, nonatomic) JAProductInfoSingleLine *emailNotificationsSingleLine;

@property (strong, nonatomic) JAProductInfoHeaderLine *shopSettingsHeaderLine;
@property (strong, nonatomic) JAProductInfoSubtitleLine *countrySubtitleLine;
@property (strong, nonatomic) JAProductInfoSubtitleLine *languageSubtitleLine;

@property (strong, nonatomic) JAProductInfoHeaderLine *moreSettingsHeaderLine;
@property (strong, nonatomic) JAProductInfoRightSubtitleLine *appVersionSubtitleLine;
@property (strong, nonatomic) NSMutableArray *moreSettingsLines;
@property (strong, nonatomic) NSArray *moreFaqAndTermsItems;

@property (strong, nonatomic) JAProductInfoHeaderLine *appSocialHeaderLine;
@property (strong, nonatomic) JAProductInfoSingleLine *shareTheAppSingleLine;
@property (strong, nonatomic) JAProductInfoSingleLine *rateTheAppSingleLine;
@property (nonatomic, strong) UIButton* accessoryImageView;

@property (strong, nonatomic) UIPopoverController *currentPopoverController;

@property (strong, nonatomic) JAPicker *languagePicker;

@end

@implementation JAMyAccountViewController

- (UIScrollView *)mainScrollView
{
    if (!VALID(_mainScrollView, UIScrollView)) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.viewBounds];
        [self.view addSubview:_mainScrollView];
//        [_mainScrollView addSubview:self.accountSettingsHeaderLine];
        
        //ProfileSingleLine
        [_mainScrollView addSubview:self.profileSingleLine];
        self.accessoryImageView = [UIButton new];
        UIImage *image = [UIImage imageNamed:@"user-information-icons"];
        CGSize imageSize = image.size;
        [self.accessoryImageView setFrame:CGRectMake(16.0f,
                                                     10,
                                                     imageSize.width,
                                                     imageSize.height)];
        [self.accessoryImageView setBackgroundImage:image forState:UIControlStateNormal];
        self.accessoryImageView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_mainScrollView addSubview:self.accessoryImageView];
        
        //addressSingleLine
        [_mainScrollView addSubview:self.myAddressesSingleLine];
        UIButton *accessoryImageView2 = [[UIButton alloc]init];
        UIImage *image2 = [UIImage imageNamed:@"my-address-icon"];
        CGSize imageSize2 = image2.size;
        [accessoryImageView2 setFrame:CGRectMake(16.0f,
                                                     CGRectGetMaxY(self.profileSingleLine.frame) + 10,
                                                     imageSize2.width,
                                                     imageSize2.height)];
        [accessoryImageView2 setBackgroundImage:image2 forState:UIControlStateNormal];
        accessoryImageView2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_mainScrollView addSubview:accessoryImageView2];

        [_mainScrollView addSubview:self.notificationSettingsHeaderLine];
        [_mainScrollView addSubview:self.pushNotificationsSwitchLine];
        [_mainScrollView addSubview:self.emailNotificationsSingleLine];
//        [_mainScrollView addSubview:self.shopSettingsHeaderLine];
        [_mainScrollView addSubview:self.countrySubtitleLine];
        [_mainScrollView addSubview:self.languageSubtitleLine];
        [_mainScrollView addSubview:self.moreSettingsHeaderLine];
        [_mainScrollView addSubview:self.appVersionSubtitleLine];
//        [self getFaqAndTerms];
//        [_mainScrollView addSubview:self.appSocialHeaderLine];
        [_mainScrollView addSubview:self.shareTheAppSingleLine];
        
        //RateAppSingleLine
        [_mainScrollView addSubview:self.rateTheAppSingleLine];
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

- (JAProductInfoSingleLine *)profileSingleLine
{
    if (!VALID(_profileSingleLine, JAProductInfoSingleLine)) {
        _profileSingleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(30, 0,  self.mainScrollView.width, kProductInfoSingleLineHeight)];
//        [_profileSingleLine setTopSeparatorVisibility:NO];
        [_profileSingleLine setTitle:STRING_PROFILE];
        [_profileSingleLine addTarget:self action:@selector(profileSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _profileSingleLine;
}

- (JAProductInfoSingleLine *)myAddressesSingleLine
{
    if (!VALID(_myAddressesSingleLine, JAProductInfoSingleLine)) {
        _myAddressesSingleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.profileSingleLine.frame), self.mainScrollView.width, kProductInfoSingleLineHeight)];
        [_myAddressesSingleLine setTitle:STRING_MY_ADDRESSES];
        [_myAddressesSingleLine addTarget:self action:@selector(myAddressesSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _myAddressesSingleLine;
}

- (JAProductInfoHeaderLine *)notificationSettingsHeaderLine
{
    if (!VALID(_notificationSettingsHeaderLine, JAProductInfoHeaderLine)) {
        _notificationSettingsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.myAddressesSingleLine.frame), self.mainScrollView.width, 0)];
//        [_notificationSettingsHeaderLine setTitle:[STRING_NOTIFICATIONS_SETTINGS uppercaseString]];
    }
    return _notificationSettingsHeaderLine;
}

- (JAProductInfoSwitchLine *)pushNotificationsSwitchLine
{
    if (!VALID(_pushNotificationsSwitchLine, JAProductInfoSwitchLine)) {
        _pushNotificationsSwitchLine = [[JAProductInfoSwitchLine alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.notificationSettingsHeaderLine.frame), self.mainScrollView.width, kProductInfoSingleLineHeight)];
//        [_pushNotificationsSwitchLine setTopSeparatorVisibility:NO];
        [_pushNotificationsSwitchLine setTitle:STRING_NOTIFICATIONS];
        [_pushNotificationsSwitchLine.lineSwitch setAccessibilityLabel:STRING_NOTIFICATIONS];
        [_pushNotificationsSwitchLine.lineSwitch addTarget:self action:@selector(changeNotification) forControlEvents:UIControlEventValueChanged];
    }
    return _pushNotificationsSwitchLine;
}

- (JAProductInfoSingleLine *)emailNotificationsSingleLine
{
    if (!VALID(_emailNotificationsSingleLine, JAProductInfoSingleLine)) {
        _emailNotificationsSingleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.pushNotificationsSwitchLine.frame), self.mainScrollView.width, kProductInfoSingleLineHeight)];
        [_emailNotificationsSingleLine setTitle:STRING_NEWSLETTER];
        [_emailNotificationsSingleLine addTarget:self action:@selector(emailNotificationSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emailNotificationsSingleLine;
}

- (JAProductInfoHeaderLine *)shopSettingsHeaderLine
{
    if (!VALID(_shopSettingsHeaderLine, JAProductInfoHeaderLine)) {
        _shopSettingsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.emailNotificationsSingleLine.frame), self.mainScrollView.width, kProductInfoHeaderLineHeight)];
        [_shopSettingsHeaderLine setTitle:[STRING_SHOP_SETTINGS uppercaseString]];
    }
    return _shopSettingsHeaderLine;
}

- (JAProductInfoSubtitleLine *)countrySubtitleLine
{
    if (!VALID(_countrySubtitleLine, JAProductInfoSubtitleLine)) {
        _countrySubtitleLine = [[JAProductInfoSubtitleLine alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.emailNotificationsSingleLine.frame), self.mainScrollView.width, kProductInfoSubtitleLineHeight)];
//        [_countrySubtitleLine setTopSeparatorVisibility:NO];
        [_countrySubtitleLine setTitle:STRING_COUNTRY];
        [_countrySubtitleLine setSubTitle:@""];
        RICountry* uniqueCountry = [RICountry getUniqueCountry];
        if (VALID_NOTEMPTY(uniqueCountry, RICountry)) {
            [_countrySubtitleLine setEnabled:NO];
        } else {
            [_countrySubtitleLine addTarget:self action:@selector(countrySelection) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _countrySubtitleLine;
}

- (JAProductInfoSubtitleLine *)languageSubtitleLine
{
    if (!VALID(_languageSubtitleLine, JAProductInfoSubtitleLine)) {
        _languageSubtitleLine = [[JAProductInfoSubtitleLine alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.countrySubtitleLine.frame), self.mainScrollView.width, kProductInfoSubtitleLineHeight)];
        [_languageSubtitleLine setTitle:STRING_LANGUAGE];
        [_languageSubtitleLine setSubTitle:@""];
        [_languageSubtitleLine addTarget:self action:@selector(openLanguagePicker) forControlEvents:UIControlEventTouchUpInside];
        if ([RICountryConfiguration getCurrentConfiguration].languages.count <= 1) {
            [_languageSubtitleLine setEnabled:NO];
        }
    }
    return _languageSubtitleLine;
}

- (JAProductInfoHeaderLine *)moreSettingsHeaderLine
{
    if (!VALID(_moreSettingsHeaderLine, JAProductInfoHeaderLine)) {
        _moreSettingsHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.languageSubtitleLine.frame), self.mainScrollView.width, 0)];
//        [_moreSettingsHeaderLine setTitle:[STRING_MORE uppercaseString]];
    }
    return _moreSettingsHeaderLine;
}

- (JAProductInfoRightSubtitleLine *)appVersionSubtitleLine
{
    if (!VALID(_appVersionSubtitleLine, JAProductInfoRightSubtitleLine)) {
        _appVersionSubtitleLine = [[JAProductInfoRightSubtitleLine alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.moreSettingsHeaderLine.frame), self.mainScrollView.width, kProductInfoRightSubtitleLineHeight)];
//        [_appVersionSubtitleLine setTopSeparatorVisibility:NO];
        NSNumber* lastVersion = [self isLastVersion];
        if (VALID_NOTEMPTY(lastVersion, NSNumber)) {
            [_appVersionSubtitleLine setHidden:NO];
            if(YES == [lastVersion boolValue])
            {
                [_appVersionSubtitleLine setRightSubTitle:STRING_UP_TO_DATE];
            }else{
                [_appVersionSubtitleLine addTarget:self action:@selector(openAppStore) forControlEvents:UIControlEventTouchUpInside];
                [_appVersionSubtitleLine setRightSubTitle:STRING_UPDATE_NOW];
            }
        } else {
            [_appVersionSubtitleLine setHidden:YES];
            [_appVersionSubtitleLine setHeight:0.0f];
        }

//        version
        [_appVersionSubtitleLine setRightTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
//        build
//        [_appVersionSubtitleLine setRightTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        [_appVersionSubtitleLine setTitle:STRING_APP_VERSION];
        self.moreSettingsLines = [[NSMutableArray alloc] initWithObjects:_appVersionSubtitleLine, nil];
    }
    return _appVersionSubtitleLine;
}

- (JAProductInfoHeaderLine *)appSocialHeaderLine
{
    if (!VALID(_appSocialHeaderLine, JAProductInfoHeaderLine)) {
        _appSocialHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([(JAProductInfoBaseLine *)[self.moreSettingsLines lastObject] frame]), self.mainScrollView.width, kProductInfoHeaderLineHeight)];
        [_appSocialHeaderLine setTitle:[STRING_APP_SOCIAL uppercaseString]];
    }
    return _appSocialHeaderLine;
}

- (JAProductInfoSingleLine *)shareTheAppSingleLine
{
    if (!VALID(_shareTheAppSingleLine, JAProductInfoSingleLine)) {
        _shareTheAppSingleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.appSocialHeaderLine.frame), self.mainScrollView.width, kProductInfoSingleLineHeight)];
//        [_shareTheAppSingleLine setTopSeparatorVisibility:NO];
        [_shareTheAppSingleLine setTitle:STRING_SHARE_THE_APP];
        [_shareTheAppSingleLine addTarget:self action:@selector(shareTheAppSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareTheAppSingleLine;
}

- (JAProductInfoSingleLine *)rateTheAppSingleLine
{
    if (!VALID(_rateTheAppSingleLine, JAProductInfoSingleLine)) {
        _rateTheAppSingleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(self.shareTheAppSingleLine.frame), self.mainScrollView.width, kProductInfoSingleLineHeight)];
        [_rateTheAppSingleLine setTitle:STRING_RATE_THE_APP];
        [_rateTheAppSingleLine addTarget:self action:@selector(rateTheAppSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rateTheAppSingleLine;
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"CustomerAccount";
    
    self.navBarLayout.title = STRING_MY_ACCOUNT;
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    self.searchBarIsVisible = YES;
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
    if ([RICountryConfiguration getCurrentConfiguration].languages.count == 1) {
        [self.languageSubtitleLine setHidden:YES];
    }
    
    [self.countrySubtitleLine setSubTitle:[RIApi getCountryNameInUse]];
    
    [self.countrySubtitleLine setImageWithURL:[RIApi getCountryFlagInUse]];
    
    _reloadLock = [NSLock new];
    
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
    [_reloadLock lock];
    [self.mainScrollView setFrame:self.viewBounds];
    
    [self.accountSettingsHeaderLine setWidth:self.mainScrollView.width];
    [self.profileSingleLine setWidth:self.mainScrollView.width - 30.0f];
    [self.myAddressesSingleLine setWidth:self.mainScrollView.width - 30.0f];
//    [self.notificationSettingsHeaderLine setWidth:self.mainScrollView.width];
    [self.pushNotificationsSwitchLine setWidth:self.mainScrollView.width - 30.0f];
    [self.emailNotificationsSingleLine setWidth:self.mainScrollView.width - 30.0f];

    CGFloat lastYOffset = CGRectGetMaxY(self.emailNotificationsSingleLine.frame);
    
//    [self.shopSettingsHeaderLine setWidth:self.mainScrollView.width];
    
    RICountry* uniqueCountry = [RICountry getUniqueCountry];
    if (VALID_NOTEMPTY(uniqueCountry, RICountry)) {
        [self.shopSettingsHeaderLine setHidden:YES];
        [self.countrySubtitleLine setHidden:YES];
    }else{
        lastYOffset = CGRectGetMaxY(self.countrySubtitleLine.frame);
    }
    
    [self.countrySubtitleLine setWidth:self.mainScrollView.width - 30.0f];
    [self.languageSubtitleLine setWidth:self.mainScrollView.width - 30.0f];
    
    if ([RICountryConfiguration getCurrentConfiguration].languages.count == 1) {
        [self.languageSubtitleLine setHidden:YES];
    }else{
        if (self.shopSettingsHeaderLine.hidden) {
            [self.shopSettingsHeaderLine setHidden:NO];
            [self.languageSubtitleLine setY:CGRectGetMaxY(self.shopSettingsHeaderLine.frame)];
//            [self.languageSubtitleLine setTopSeparatorVisibility:NO];
        }else{
            [self.languageSubtitleLine setY:CGRectGetMaxY(self.countrySubtitleLine.frame)];
        }
        lastYOffset = CGRectGetMaxY(self.languageSubtitleLine.frame);
    }
    [self.moreSettingsHeaderLine setY:lastYOffset];
    [self.moreSettingsHeaderLine setWidth:self.mainScrollView.width];
    lastYOffset = CGRectGetMaxY(self.moreSettingsHeaderLine.frame);
    for (UIView *view in self.moreSettingsLines) {
        [view setY:lastYOffset];
        [view setWidth:self.mainScrollView.width];
        lastYOffset = CGRectGetMaxY(view.frame);
    }
    [self.appSocialHeaderLine setY:lastYOffset];
    [self.appSocialHeaderLine setWidth:self.mainScrollView.width];
//    lastYOffset = CGRectGetMaxY(self.appSocialHeaderLine.frame);
    [self.shareTheAppSingleLine setY:lastYOffset];
    [self.shareTheAppSingleLine setWidth:self.mainScrollView.width - 30.0f];
    lastYOffset = CGRectGetMaxY(self.shareTheAppSingleLine.frame);
    [self.rateTheAppSingleLine setWidth:self.mainScrollView.width - 30.0f];
    [self.rateTheAppSingleLine setY:lastYOffset];
//    CGFloat accessoryImageWidth = kAcessoryImageWidthAndHeight;
//    CGFloat accessoryImageMargin = kLeftAndRightMargin;
   
    UIButton *accessoryImageView3 = [[UIButton alloc]init];
    UIImage *image3 = [UIImage imageNamed:@"app-ver-icons"];
    CGSize imageSize3 = image3.size;
    [accessoryImageView3 setFrame:CGRectMake(16.0f,
                                             CGRectGetMaxY(self.moreSettingsHeaderLine.frame) + 20,
                                             imageSize3.width,
                                             imageSize3.height)];
    [accessoryImageView3 setBackgroundImage:image3 forState:UIControlStateNormal];
    accessoryImageView3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_mainScrollView addSubview:accessoryImageView3];
    [self.appVersionSubtitleLine setWidth:self.mainScrollView.width - 30.0f];

    
    UIButton *accessoryImageView5 = [[UIButton alloc]init];
    UIImage *image5 = [UIImage imageNamed:@"share-icons"];
    CGSize imageSize5 = image5.size;
    [accessoryImageView5 setFrame:CGRectMake(16.0f,
                                                 CGRectGetMaxY(self.appVersionSubtitleLine.frame) + 16,
                                                 imageSize5.width,
                                                 imageSize5.height)];
    [accessoryImageView5 setBackgroundImage:image5 forState:UIControlStateNormal];
    accessoryImageView5.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_mainScrollView addSubview:accessoryImageView5];

    UIButton *accessoryImageView1 = [[UIButton alloc]init];
    UIImage *image1 = [UIImage imageNamed:@"announcements-icon"];
    CGSize imageSize1 = image1.size;

    [accessoryImageView1 setFrame:CGRectMake(16.0f,
                                             CGRectGetMaxY(self.myAddressesSingleLine.frame) + 16,
                                             imageSize1.width,
                                             imageSize1.height)];
    [accessoryImageView1 setBackgroundImage:image1 forState:UIControlStateNormal];
    accessoryImageView1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_mainScrollView addSubview:accessoryImageView1];
    
    UIButton *accessoryImageView2 = [[UIButton alloc]init];
    UIImage *image2 = [UIImage imageNamed:@"newsletter-icons"];
    CGSize imageSize2 = image2.size;
    [accessoryImageView2 setFrame:CGRectMake(16.0f,
                                             CGRectGetMaxY(self.pushNotificationsSwitchLine.frame) + 16,
                                             imageSize2.width,
                                             imageSize2.height)];
    [accessoryImageView2 setBackgroundImage:image2 forState:UIControlStateNormal];
    accessoryImageView2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_mainScrollView addSubview:accessoryImageView2];
    
    UIButton *accessoryImageView4 = [[UIButton alloc]init];
    UIImage *image4 = [UIImage imageNamed:@"rate-icons"];
    CGSize imageSize4 = image4.size;
    [accessoryImageView4 setFrame:CGRectMake(16.0f,
                                             CGRectGetMaxY(self.shareTheAppSingleLine.frame) + 16,
                                             imageSize4.width,
                                             imageSize4.height)];
    [accessoryImageView4 setBackgroundImage:image4 forState:UIControlStateNormal];
    accessoryImageView4.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_mainScrollView addSubview:accessoryImageView4];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, CGRectGetMaxY(self.rateTheAppSingleLine.frame))];

    if (RI_IS_RTL)
    {
        [self.view flipAllSubviews];
    }
    [_reloadLock unlock];
}

- (void)adjustViews
{
    [self.appSocialHeaderLine setYBottomOf:[self.moreSettingsLines lastObject] at:0.f];
    [self.shareTheAppSingleLine setYBottomOf:self.appSocialHeaderLine at:0.f];
    [self.rateTheAppSingleLine setYBottomOf:self.shareTheAppSingleLine at:0.f];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, CGRectGetMaxY(self.rateTheAppSingleLine.frame))];
}

#pragma mark - Data

- (void)getFaqAndTerms
{
    [self showLoading];
    [RICountry getCountryFaqAndTermsWithSuccessBlock:^(NSArray *faqAndTerms) {
        [self hideLoading];
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        self.moreFaqAndTermsItems = [faqAndTerms copy];
        int i = 0;
        for (id object in faqAndTerms) {
            NSString *label = [object objectForKey:@"label"];
            if (VALID_NOTEMPTY([object objectForKey:@"label"], NSString)) {
                JAProductInfoSingleLine *moreItemLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY([(JAProductInfoBaseLine *)[self.moreSettingsLines lastObject] frame]), self.mainScrollView.width, kProductInfoSingleLineHeight)];
                [moreItemLine setTitle:label];
                [moreItemLine addTarget:self action:@selector(moreSelection:) forControlEvents:UIControlEventTouchUpInside];
                [moreItemLine setTag:i];
                [self.moreSettingsLines addObject:moreItemLine];
                [self.mainScrollView addSubview:moreItemLine];
            }
            i++;
        }
        [self adjustViews];
        [self reloadViews];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        [self hideLoading];
        if (apiResponse == RIApiResponseNoInternetConnection) {
            [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(getFaqAndTerms) objects:nil];
        }
    }];
}

- (NSNumber*)isLastVersion
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    if (VALID_NOTEMPTY(myNumber, NSNumber) && VALID_NOTEMPTY([RIApi getApiInformation].curVersion, NSNumber)) {
        if ([myNumber compare:[RIApi getApiInformation].curVersion] == NSOrderedAscending) {
            return [NSNumber numberWithBool:NO];
        }else{
            return [NSNumber numberWithBool:YES];
        }
    } else {
        return nil;
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
    
    //UIActivity *fbmActivity = [[AQSFacebookMessengerActivity alloc] init];
    UIActivity *whatsAppActivity = [[JBWhatsAppActivity alloc] init];
    WhatsAppMessage *whatsAppMsg;
    
    JAActivityViewController  *activityController = [[JAActivityViewController alloc] initWithActivityItems:@[] applicationActivities:appActivities];
    NSString *shareTheAppString = [[NSString alloc] initWithString:[NSString stringWithFormat:STRING_SHARE_APP, APP_NAME]];
    if(!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        
        appActivities = @[/*fbmActivity, */whatsAppActivity];
    }
    
    
    whatsAppMsg = [[WhatsAppMessage alloc] initWithMessage:[NSString stringWithFormat:@"%@ %@",shareTheAppString, kAppStoreUrlBamilo]  forABID:nil];
    
    activityController = [[JAActivityViewController alloc] initWithActivityItems:@[shareTheAppString, [NSURL URLWithString:kAppStoreUrlBamilo], whatsAppMsg] applicationActivities:appActivities];
    
    
    
    
    [activityController setValue:[NSString stringWithFormat:STRING_SHARE_APP, APP_NAME] forKey:@"subject"];
    
    
    
    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        CGRect sharePopoverRect = CGRectMake(self.shareTheAppSingleLine.frame.size.width / 2,
                                             self.shareTheAppSingleLine.frame.size.height - 6.0f,
                                             0.0f,
                                             0.0f);
        
        UIPopoverController* popoverController =
        [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popoverController presentPopoverFromRect:sharePopoverRect inView:self.shareTheAppSingleLine permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        popoverController.passthroughViews = nil;
        self.currentPopoverController = popoverController;
    } else {
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)rateTheAppSelection {
    [self openAppStore];
}

- (void)openAppStore {
    static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/apple-store/id%@";
    static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    
    NSString *appStoreId = kAppStoreIdBamilo;
    
    NSURL *appStoreLink = [NSURL URLWithString:
                           [NSString stringWithFormat:
                            ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f) ? iOS7AppStoreURLFormat : iOSAppStoreURLFormat, appStoreId]];
    
    [[UIApplication sharedApplication] openURL:appStoreLink];

}

- (void)changeNotification {
    if (self.pushNotificationsSwitchLine.lineSwitch.on) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey: kChangeNotificationsOptions];
    } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey: kChangeNotificationsOptions];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - JAPicker

-(void)removePickerView {
    if(VALID_NOTEMPTY(self.languagePicker, JAPicker)) {
        [self.languagePicker removeFromSuperview];
        self.languagePicker = nil;
    }
}

- (void)openLanguagePicker {
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
    
    [UIView animateWithDuration:0.4f animations:^{
                         [self.languagePicker setFrame:CGRectMake(0.0f, [self viewBounds].origin.y, pickerViewWidth, pickerViewHeight)];
                     }];
}

- (void)selectedRowNumber:(NSNumber *)selectedRowNumber {
    [self selectedRow:selectedRowNumber.integerValue];
}

- (void)selectedRow:(NSInteger)selectedRow {
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
                
                [self onErrorResponse:apiResponse messages:@[[errorMessages firstObject]] showAsMessage:YES selector:@selector(selectedRowNumber:) objects:@[[NSNumber numberWithInteger:selectedRow]]];
            } else {
                RICountry* uniqueCountry = [RICountry getUniqueCountry];
                if (VALID_NOTEMPTY(uniqueCountry, RICountry)) {
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
        }];
    }
}

@end
