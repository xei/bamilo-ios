//
//  BMA4SInAppMessage.h
//  BMA4SSDK
//
//  Created by Yassir BARCHI on 22/06/2015.
//  Copyright (c) 2015 Accengage. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const BMA4SInAppOverlayViewBodyTag;
extern NSInteger const BMA4SInAppOverlayViewCloseTag;
extern NSInteger const BMA4SInAppOverlayViewBackTag;
extern NSInteger const BMA4SInAppOverlayViewForwardTag;
extern NSInteger const BMA4SInAppOverlayViewToolbarTag;
extern NSInteger const BMA4SInAppOverlayViewActivityTag;
extern NSInteger const BMA4SInAppOverlayViewReloadTag;
extern NSInteger const BMA4SInAppOverlayViewStopTag;
extern NSInteger const BMA4SInAppOverlayViewSafariTag;

@interface BMA4SInAppMessage : NSObject
/**
 *  Returns the in-app message id.
 */
@property (nonatomic, readonly) NSString* messageID;

/**
 *  Returns the in-app message template name.
 */
@property (nonatomic, readonly) NSString* templateNibName;

/**
 *  Returns the in-app message additional display parameters.
 */
@property (nonatomic, readonly) NSDictionary* displayCustomParams;

/**
 *  Returs `YES` if the template is an interstitial, `NO` otherwise.
 */
@property (nonatomic, readonly, getter=isInterstitial) BOOL interstitial;

@end


@interface BMA4SInAppTextMessage : BMA4SInAppMessage
/**
 *  Returns the text in-app message body.
 */
@property (nonatomic, readonly) NSString* body;

@end

@interface BMA4SInAppWebMessage : BMA4SInAppMessage
/**
 *  Returns the web in-app message url.
 */
@property (nonatomic, readonly) NSURL* url;
@end

