//
//  JACenterNavigationController.h
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavigationController.h"
#import "JACustomNavigationBarView.h"
#import "JATabBarView.h"
#import "JAScreenTarget.h"
#import "RIOrder.h"
#import "RICart.h"

typedef void(^ProtectedBlock)(BOOL userHadSession);

@interface JACenterNavigationController : BaseNavigationController

@property (strong, nonatomic) RICart *cart;

//@property (strong, nonatomic) JACustomNavigationBarView *navigationBarView;
//@property (strong, nonatomic) JATabBarView *tabBarView;
@property (nonatomic, assign)BOOL searchViewAlwaysHidden;

- (void)openTargetString:(NSString *)targetString purchaseInfo:(NSString *)purchaseInfo currentScreenName:(NSString *)screenName;
- (BOOL)openScreenTarget:(RITarget *)target purchaseInfo:(NSString *)purchaseInfo currentScreenName:(NSString *)screenName;
- (void)showSearchView:(NSString *)screenName;
- (void)updateCartWith:(RICart *)cart;

//- (void)goToOnlineReturnsPaymentScreenForItems:(NSArray *)items order:(RITrackOrder*)order;
//- (void)goToOnlineReturnsWaysScreenForItems:(NSArray *)items order:(RITrackOrder*)order;
//- (void)goToOnlineReturnsReasonsScreenForItems:(NSArray *)items order:(RITrackOrder*)order;
//- (void)goToOnlineReturnsConfirmConditionsForItems:(NSArray *)items order:(RITrackOrder*)order;
//- (void)goToOnlineReturnsCall:(RIItemCollection *)item fromOrderNumber:(NSString *)orderNumber;
//- (void)goToOnlineReturnsConfirmScreenForItems:(NSArray *)items order:(RITrackOrder *)order;

- (BOOL)closeScreensToStackClass:(Class)classKind animated:(BOOL)animated;

//#####################################################################################################################
-(void) registerObservingOnNotifications;
-(void) removeObservingNotifications;
-(void) requestNavigateToNib:(NSString *)destNib args:(NSDictionary *)args;
- (UIViewController *)requestViewController:(NSString *)destNib ofStoryboard:(NSString *)storyboard useCache:(BOOL)useCache;
-(void) requestForcedLoginWithCompletion:(void (^)(void))completion;
-(void) requestNavigateToNib:(NSString *)destNib ofStoryboard:(NSString *)storyboard useCache:(BOOL)useCache args:(NSDictionary *)args;
-(void) requestNavigateToClass:(NSString *)destClass args:(NSDictionary *)args;
-(void) performProtectedBlock:(ProtectedBlock)block;

@end
