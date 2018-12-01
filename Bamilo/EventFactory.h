////
////  EventFactory.h
////  Bamilo
////
////  Created by Narbeh Mirzaei on 4/8/17.
////  Copyright © 2017 Rocket Internet. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#import "LoginEvent.h"
//#import "SignUpEvent.h"
//#import "LogoutEvent.h"
//#import "OpenAppEvent.h"
//#import "AddToFavoritesEvent.h"
//#import "AddToCartEvent.h"
//#import "AbandonCartEvent.h"
//#import "PurchaseEvent.h"
//#import "SearchEvent.h"
//#import "ViewProductEvent.h"
//#import "TapRecommendationEvent.h"
//#import "FilterSearchEvent.h"
//#import "SearchBarSearchEvent.h"
//
//@interface EventFactory : NSObject
//
//+(NSDictionary *) login:(NSString *)loginMethod success:(BOOL)success;
//+(NSDictionary *) signup:(NSString *)signupMethod success:(BOOL)success;
//+(NSDictionary *) logout:(BOOL)success;
//+(NSDictionary *) openApp:(OpenAppEventSourceType)source;
//+(NSDictionary *) addToFavoritesByCategoryUrlKey:(NSString *)categoryUrlKey sku:(NSString *)sku success:(BOOL)success;
//+(NSDictionary *) addToCart:(NSString *)sku basketValue:(long)basketValue success:(BOOL)success;
//+(NSDictionary *) purchase:(NSString *)categories basketValue:(long)basketValue success:(BOOL)success;
//+(NSDictionary *) search:(RITarget *)searchTarget;
//+(NSDictionary *) viewProduct:(NSString *)categoryUrlKey price:(long)price;
//+(NSDictionary *) tapRecommectionInScreenName:(NSString *)screenName logic:(NSString *)logic;
//+(NSDictionary *) filterSearchByFilterKeys:(NSString *)filterKeys filterValue:(NSString *)filterValues;
//+(NSDictionary *) searchBarSearched:(NSString *)searchString screenName:(NSString *)screenName;
//
//@end
