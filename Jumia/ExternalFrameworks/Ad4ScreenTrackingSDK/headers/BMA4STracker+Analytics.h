//
//  BMA4STracker+Analytics.h
//  Ad4ScreenTrackingSDK
//
//  Created by Jérémie Girault on 24/01/13.
//
//

#import "BMA4STracker.h"

@interface BMA4SPurchasedItem : NSObject

@property (nonatomic, retain) NSString* itemId;
@property (nonatomic, retain) NSString* label;
@property (nonatomic, retain) NSString* category;
@property (nonatomic, assign) double price;
@property (nonatomic, assign) long quantity;

+(BMA4SPurchasedItem*)itemWithId:(NSString*)itemId label:(NSString*)label category:(NSString*)category price:(double)price quantity:(long)quantity;

@end

@interface BMA4STracker (Analytics)

// specialized analytics events

+ (void) trackCartWithId:(NSString*)cartId modificationWithLabel:(NSString*)label forArticleWithId:(NSString*)articleId
                   category:(NSString*)category  price:(double)price currency:(NSString*)currency quantity:(long)quantity;

// items = NSArray of BMA4SPurchasedItem
+ (void) trackPurchaseWithId:(NSString*)purchaseId currency:(NSString*)currency items:(NSArray*)items;
+ (void) trackPurchaseWithId:(NSString*)purchaseId currency:(NSString*)currency totalPrice:(double)totalPrice;
+ (void) trackPurchaseWithId:(NSString*)purchaseId currency:(NSString*)currency items:(NSArray*)items totalPrice:(double)totalPrice;

+ (void) trackLeadWithLabel:(NSString*)label value:(NSString*)value;

@end