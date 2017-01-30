//
//  JAMyAccountViewController.m
//  Jumia
//
//  Created by Jose Mota on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMyAccountViewController.h"
//#import "JAProductInfoHeaderLine.h"
//#import "JAProductInfoSingleLine.h"
//#import "JAProductInfoSubtitleLine.h"
//#import "JAProductInfoSwitchLine.h"
//#import "JAProductInfoRightSubtitleLine.h"
#import "JAActivityViewController.h"
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import "JBWhatsAppActivity.h"
#import "RITarget.h"

#import "IconTableViewCell.h"
#import "NotificationTableViewCell.h"
#import "VersionTableViewCell.h"

@interface JAMyAccountViewController ()


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIPopoverController *currentPopoverController;
@property (nonatomic, strong) NSArray* tableViewListItems;


@end

@implementation JAMyAccountViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"CustomerAccount";
    
    self.navBarLayout.title = STRING_MY_ACCOUNT;
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    self.searchBarIsVisible = YES;
    self.tabBarIsVisible = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
#pragma mark - nib registration 
    
    [self.tableView registerNib:[UINib nibWithNibName:[IconTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [IconTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[NotificationTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [NotificationTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[VersionTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [VersionTableViewCell nibName]];
    
    self.tableViewListItems = @[
                                @{
                                    @"title": STRING_PROFILE,
                                    @"icon": @"user-information-icons",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"notification" : kShowUserDataScreenNotification,
                                    @"animated" : @YES
                                    },
                                @{
                                    @"title": STRING_MY_ADDRESSES,
                                    @"icon": @"my-address-icon",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"notification": kShowCheckoutAddressesScreenNotification,
                                    @"animated" : @NO
                                    },
                                @{
                                    @"title": STRING_NOTIFICATIONS,
                                    @"icon": @"announcements-icon",
                                    @"cellType": NotificationTableViewCell.nibName
                                    },
                                @{
                                    @"title": STRING_NEWSLETTER,
                                    @"icon": @"newsletter-icons",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"notification": kShowEmailNotificationsScreenNotification,
                                    @"animated": @YES
                                    },
                                @{
                                    @"title": STRING_APP_VERSION,
                                    @"icon": @"app-ver-icons",
                                    @"cellType": VersionTableViewCell.nibName,
                                    @"selectorName": @"openAppStore"
                                    },
                                @{
                                    @"title": STRING_APP_SOCIAL,
                                    @"icon": @"share-icons",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"selectorName": @"shareTheAppSelection"
                                    
                                    },
                                @{
                                    @"title": STRING_RATE_THE_APP,
                                    @"icon": @"rate-icons",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"selectorName": @"openAppStore",
                                    
                                    }
                                ];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //Must be refactored later
    self.tableView.frame = self.viewBounds;
}

- (void)appWillEnterForeground {
    if(VALID_NOTEMPTY(self.currentPopoverController, UIPopoverController)) {
        [self.currentPopoverController dismissPopoverAnimated:NO];
    }
    
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


- (void)onOrientationChanged {
    [super onOrientationChanged];
    if(self.currentPopoverController) {
        [self.currentPopoverController dismissPopoverAnimated:NO];
    }
}

- (void)shareTheAppSelection {
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
        CGRect sharePopoverRect = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height - 6.0f, 0.0f, 0.0f);
        
        UIPopoverController* popoverController =
        [[UIPopoverController alloc] initWithContentViewController:activityController];
        [popoverController presentPopoverFromRect:sharePopoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        popoverController.passthroughViews = nil;
        self.currentPopoverController = popoverController;
    } else {
        [self presentViewController:activityController animated:YES completion:nil];
    }
}

- (void)openAppStore {
    static NSString *const iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/apple-store/id%@";
    static NSString *const iOSAppStoreURLFormat = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    
    NSString *appStoreId = kAppStoreIdBamilo;
    
    NSURL *appStoreLink = [NSURL URLWithString: [NSString stringWithFormat:
                            ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f) ? iOS7AppStoreURLFormat : iOSAppStoreURLFormat, appStoreId]];
    
    [[UIApplication sharedApplication] openURL:appStoreLink];

}


#pragma mark - TableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = [self.tableViewListItems[indexPath.row] objectForKey:@"cellType"];
    IconTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.title = [self.tableViewListItems[indexPath.row] objectForKey:@"title"];
    cell.imageName = [self.tableViewListItems[indexPath.row] objectForKey:@"icon"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewListItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return IconTableViewCell.heightSize;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    NSDictionary *selectedObjItem = self.tableViewListItems[indexPath.row];
    if ([selectedObjItem objectForKey:@"selectorName"]) {
        SEL customSelector = NSSelectorFromString([selectedObjItem objectForKey:@"selectorName"]);
        [self performSelector:customSelector withObject: 0];
        return;
    }
    
    if ([selectedObjItem objectForKey:@"notification"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[selectedObjItem objectForKey:@"notification"]
                                                            object:@{@"animated":[selectedObjItem objectForKey:@"animated"]}
                                                          userInfo:@{@"from_checkout":@NO}];
    }
}


@end
