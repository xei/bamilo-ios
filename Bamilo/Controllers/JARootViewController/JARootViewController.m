////
////  JARootViewController.m
////  Jumia
////
////  Created by Miguel Chaves on 28/Jul/14.
////  Copyright (c) 2014 Rocket Internet. All rights reserved.
////
//
//#import "JARootViewController.h"
//#import "JACenterNavigationController.h"
//#import "JACategoriesSideMenuViewController.h"
//#import "RICustomer.h"
//#import "ViewControllerManager.h"
//
//@interface JARootViewController ()
//
//@property (assign, nonatomic) NSInteger requestCount;
//@property (strong, nonatomic) RICountry *selectedCountry;
//@property (strong, nonatomic) UIStoryboard *mainStoryboard;
//
//@end
//
//@implementation JARootViewController
//
//#pragma mark - View lifecycle
//
//- (instancetype)init {
//    self = [super init];
//    if(self) {
//        self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    }
//    return self;
//}
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    if(ISEMPTY(self.mainStoryboard)) {
//        self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    }
//    
//    self.shouldResizeLeftPanel = YES;
//    self.shouldResizeRightPanel = YES;
//    
//    //we need to allow panning for all view controllers
//    //(we will de-activate it in each JABaseViewController
//    self.panningLimitedToTopViewController = NO;
//    
//    //notifications to turn swipe on and off
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(turnOffMenuSwipe)
//                                                 name:kTurnOffMenuSwipePanelNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(openMainMenu:)
//                                                 name:kOpenMenuNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(showCenterViewController)
//                                                 name:kOpenCenterPanelNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(updateCountry:)
//                                                 name:kUpdateCountryNotification
//                                               object:nil];
//    
//    if(VALID_NOTEMPTY(self.notification, NSDictionary)) {
////        [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification
//                                                            object:self.selectedCountry
//                                                          userInfo:self.notification];
//    } else {
//        RICountry* uniqueCountry = [RICountry getUniqueCountry];
//        if (VALID_NOTEMPTY(uniqueCountry, RICountry)) {
//            if ([RIApi checkIfHaveCountrySelected] && [[RIApi getCountryUrlInUse] isEqualToString:uniqueCountry.url]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification
//                                                                    object:nil];
//            } else {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification
//                                                                    object:uniqueCountry];
//            }
//        } else {
//            
//            if(VALID_NOTEMPTY(self.selectedCountry, RICountry) || [RIApi checkIfHaveCountrySelected]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification
//                                                                    object:self.selectedCountry];
//            } else {
//                [[NSNotificationCenter defaultCenter] postNotificationName:kShowChooseCountryScreenNotification
//                                                                    object:nil];
//            }
//        }
//    }
//}
//
//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//}
//
//- (void)awakeFromNib {
//    [super awakeFromNib];
//    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    if (RI_IS_RTL) {
//        [self setRightPanel:[self.mainStoryboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
//    } else {
//        [self setLeftPanel:[self.mainStoryboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
//    }
//    [self setCenterPanel:[ViewControllerManager centerViewController]];
//    [self turnOffMenuSwipe];
//}
//
//- (void)updateCountry:(NSNotification*)notification {
//    if (RI_IS_RTL) {
//        [self setRightPanel:[self.mainStoryboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
//    } else {
//        [self setLeftPanel:[self.mainStoryboard instantiateViewControllerWithIdentifier:@"menuViewController"]];
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"first_screen"]];
//    
//    if(VALID_NOTEMPTY(notification.userInfo, NSDictionary) && VALID_NOTEMPTY([RIApi getCountryIsoInUse], NSString)) {
//        [[RITrackingWrapper sharedInstance] handlePushNotifcation:[notification.userInfo copy]];
//    }
//}
//
//- (void)turnOffMenuSwipe {
//    self.allowLeftSwipe = NO;
//    self.allowRightSwipe = NO;
//}
//
//- (void)openMainMenu:(NSNotification *)notification {
//    UIViewController *topViewController = [(JACenterNavigationController *)self.centerPanel topViewController];
//    if(VALID_NOTEMPTY(topViewController, UIViewController)) {
//        if([topViewController respondsToSelector:@selector(removeMessageView)]) {
//            [topViewController performSelector:@selector(removeMessageView)];
//        }
//    }
//    
//    if (RI_IS_RTL) {
//        [self showRightPanelAnimated:YES userInfo:nil];
//    } else {
//        [self showLeftPanelAnimated:YES userInfo:nil];
//    }
//}
//
//- (void)showCenterViewController {
//    [self showCenterPanelAnimated:YES];
//}
//
//@end
