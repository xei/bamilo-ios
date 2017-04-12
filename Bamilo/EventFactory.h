//
//  EventFactory.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginEvent.h"
#import "SignUpEvent.h"
#import "LogoutEvent.h"
#import "OpenAppEvent.h"
#import "AddToFavoritesEvent.h"
#import "AddToCartEvent.h"
#import "AbandonCartEvent.h"
#import "PurchaseEvent.h"
#import "SearchEvent.h"
#import "ViewProductEvent.h"
#import "ViewCategoryEvent.h"
#import "RICart.h"

@interface EventFactory : NSObject

+(NSDictionary *) login:(NSString *)loginMethod success:(BOOL)success;
+(NSDictionary *) signup:(NSString *)signupMethod success:(BOOL)success;
+(NSDictionary *) logout:(BOOL)success;
+(NSDictionary *) openApp:(OpenAppEventSourceType)source;
+(NSDictionary *) addToFavorites:(NSString *)categoryUrlKey success:(BOOL)success;
+(NSDictionary *) addToCart:(NSString *)sku basketValue:(int)basketValue success:(BOOL)success;
+(NSDictionary *) purchase:(NSString *)categories basketValue:(int)basketValue success:(BOOL)success;
+(NSDictionary *) search:(NSString *)categoryUrlKey keywords:(NSString *)keywords;
+(NSDictionary *) viewProduct:(NSString *)categoryUrlKey price:(int)price;
+(NSDictionary *) viewCategory:(NSString *)categoryUrlKey;

@end
