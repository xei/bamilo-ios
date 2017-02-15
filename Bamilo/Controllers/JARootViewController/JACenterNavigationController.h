//
//  JACenterNavigationController.h
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACustomNavigationBarView.h"
#import "JATabBarView.h"
#import "JAScreenTarget.h"
#import "RIOrder.h"
#import "RICart.h"

@interface JACenterNavigationController : UINavigationController

@property (strong, nonatomic) RICart *cart;

@property (strong, nonatomic) JACustomNavigationBarView *navigationBarView;
@property (strong, nonatomic) JATabBarView *tabBarView;

@property (nonatomic, assign)BOOL searchViewAlwaysHidden;

- (void)openTargetString:(NSString *)targetString;
- (BOOL)openScreenTarget:(JAScreenTarget *)target;
- (void)showSearchView;

- (void)goToPickupStationWebViewControllerWithCMS:(NSString*)cmsBlock;

- (void)goToOnlineReturnsPaymentScreenForItems:(NSArray *)items
                                         order:(RITrackOrder*)order;
- (void)goToOnlineReturnsWaysScreenForItems:(NSArray *)items
                                      order:(RITrackOrder*)order;
- (void)goToOnlineReturnsReasonsScreenForItems:(NSArray *)items
                                         order:(RITrackOrder*)order;

- (void)goToOnlineReturnsConfirmConditionsForItems:(NSArray *)items
                                             order:(RITrackOrder*)order;

- (void)goToOnlineReturnsCall:(RIItemCollection *)item
              fromOrderNumber:(NSString *)orderNumber;

- (void)goToOnlineReturnsConfirmScreenForItems:(NSArray *)items
                                         order:(RITrackOrder *)order;

- (BOOL)closeScreensToStackClass:(Class)classKind animated:(BOOL)animated;

//#####################################################################################################################
-(void) requestNavigateTo:(NSString *)destination args:(NSDictionary *)args;
-(void) requestNavigateTo:(NSString *)destination ofStoryboard:(NSString *)storyboard useCache:(BOOL)useCache args:(NSDictionary *)args;

@end
