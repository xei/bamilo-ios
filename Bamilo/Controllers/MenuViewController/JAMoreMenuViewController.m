//
//  JAMoreMenuViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 22/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMoreMenuViewController.h"
#import "RICustomer.h"
#import "PlainTableViewCell.h"
#import "IconTableViewCell.h"
#import "PlainTableViewHeaderCell.h"
#import "VersionTableViewCell.h"
#import "IconTableViewCell.h"
#import "JAActivityViewController.h"
#import "JBWhatsAppActivity.h"

@interface JAMoreMenuViewController ()

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* tableViewListItems;
@property (strong, nonatomic) UIPopoverController *currentPopoverController;
@end

@implementation JAMoreMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    self.tabBarIsVisible = YES;
    self.searchBarIsVisible = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //   Nib registration for tableView
    [self.tableView registerNib:[UINib nibWithNibName:[IconTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [IconTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[VersionTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [VersionTableViewCell nibName]];
    
    
    [self.tableView registerNib: [UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil]
                    forHeaderFooterViewReuseIdentifier:[PlainTableViewHeaderCell nibName]];
    
    self.tableViewListItems = @[
                                @{
                                    @"title": STRING_CONTACT_US,
                                    @"icon": @"ContactUs",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"selector": [NSValue valueWithPointer:@selector(segueToContactUsViewController)]
                                    },
                                @{
                                    @"title": STRING_FAQ,
                                    @"icon": @"FAQ",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"selector": [NSValue valueWithPointer:@selector(fAQBtnTouchUpInside)]
                                    },
                                @{
                                    @"title": STRING_APP_SOCIAL,
                                    @"icon": @"share-icons",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"selector": [NSValue valueWithPointer:@selector(shareTheAppSelection)]
                                    
                                    },
                                @{
                                    @"title": STRING_RATE_THE_APP,
                                    @"icon": @"rate-icons",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"selector": [NSValue valueWithPointer:@selector(openAppStore)]
                                    
                                    },
                                @{
                                    @"title": STRING_APP_VERSION,
                                    @"icon": @"app-ver-icons",
                                    @"cellType": VersionTableViewCell.nibName,
                                    @"selector": [NSValue valueWithPointer:@selector(openAppStore)]
                                    }
                                ];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //Must be refactored later
    self.tableView.frame = self.viewBounds;
}


- (void)shareTheAppSelection {
    NSArray *appActivities = @[];
    
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

-(void)segueToContactUsViewController {
    [self performSegueWithIdentifier:@"pushMoreToContactUsViewController" sender:nil];
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

#pragma tableView DetaSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewListItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [self.tableViewListItems[indexPath.row] objectForKey:@"cellType"];
    IconTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.title = [self.tableViewListItems[indexPath.row] objectForKey:@"title"];
    cell.imageName = [self.tableViewListItems[indexPath.row] objectForKey:@"icon"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [IconTableViewCell heightSize];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlainTableViewHeaderCell * headerCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[PlainTableViewHeaderCell nibName]];
    headerCell.titleString = STRING_MORE;
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [IconTableViewCell heightSize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    NSDictionary *selectedObjItem = self.tableViewListItems[indexPath.row];
    if ([[selectedObjItem objectForKey:@"selector"] pointerValue]) {
        SEL customSelector = [[selectedObjItem objectForKey:@"selector"] pointerValue];
        //[self performSelector:customSelector withObject: 0];
        [self performSelector:customSelector];
        return;
    }
    
    if ([selectedObjItem objectForKey:@"notification"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[selectedObjItem objectForKey:@"notification"]
                                                            object:@{@"animated":[selectedObjItem objectForKey:@"animated"]}
                                                          userInfo:@{@"from_checkout":@NO}];
    }
}

- (void)fAQBtnTouchUpInside {
    NSDictionary *userInfo = @{
                 @"title"                   : @"راهنما",
                 @"targetString"            : @"shop_in_shop::help",
                 @"show_back_button_title"  : @""
                 };
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithShopUrlNofication object:nil userInfo: userInfo];
}

@end
