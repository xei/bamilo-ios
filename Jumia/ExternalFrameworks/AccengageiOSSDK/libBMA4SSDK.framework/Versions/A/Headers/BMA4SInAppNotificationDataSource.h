//
//  BMA4SInAppNotificationDataSource.h
//  Accengage SDK 
//
//  Copyright (c) 2010-2015 Accengage. All rights reserved.
//


/**
 *  Options for overlay inApp position.
 *  @since Available in SDK 5.2.0 and later.
 */
typedef NS_ENUM(NSInteger, BMA4SOverlayInAppPosition){
  /**
   Default position
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleBottomMargin 
   | UIViewAutoresizingFlexibleRightMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionDefault = 0,
  
  /**
   Top.
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleBottomMargin
   | UIViewAutoresizingFlexibleRightMargin 
   | UIViewAutoresizingFlexibleLeftMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionTop = 1,
  
  /**
   Top left corner.
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleBottomMargin 
   | UIViewAutoresizingFlexibleRightMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionTopLeft = 2,
  
  /**
   Top right corner.
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleBottomMargin 
   | UIViewAutoresizingFlexibleLeftMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionTopRight = 3,
  
  /**
   Centred.
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleBottomMargin
   | UIViewAutoresizingFlexibleTopMargin 
   | UIViewAutoresizingFlexibleRightMargin 
   | UIViewAutoresizingFlexibleLeftMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionCenter = 4,
  
  /**
   Left.
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleBottomMargin 
   | UIViewAutoresizingFlexibleTopMargin 
   | UIViewAutoresizingFlexibleRightMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionCenterLeft = 5,
  
  /**
   Right.
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleBottomMargin 
   | UIViewAutoresizingFlexibleTopMargin 
   | UIViewAutoresizingFlexibleLeftMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionCenterRight = 6,
  
  /**
   Bottom
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleTopMargin 
   | UIViewAutoresizingFlexibleRightMargin 
   | UIViewAutoresizingFlexibleLeftMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionBottom = 7,
  
  /**
   Bottom left corner.
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleTopMargin 
   | UIViewAutoresizingFlexibleRightMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionBottomLeft = 8,
  
  /**
   Bottom right corner.

   AutoresizingMask : 
   UIViewAutoresizingFlexibleTopMargin 
   | UIViewAutoresizingFlexibleLeftMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionBottomRight = 9,
  
  /**
   Custom position returned by BMA4SOverlayInAppCustomPositionForTemplate:size:
   
   AutoresizingMask : 
   UIViewAutoresizingFlexibleBottomMargin 
   | UIViewAutoresizingFlexibleRightMargin
   
   @since Available in SDK 5.2.0 and later.
   */
  BMA4SOverlayInAppPositionCustom = 10
};

/**
 The data source of an inApp notifications position object must adopt the BMA4SInAppNotificationDataSource protocol. Optional methods of the protocol allow the data source to choose the default position, some predefined positions or a custom position of an inApp.
 
 @since Available in SDK 5.2.0 and later.
 */
@protocol BMA4SInAppNotificationDataSource <NSObject>

/**-----------------------------------------------------------------------------
 * @name Overlay inApp position
 * -----------------------------------------------------------------------------
 */
@optional
/**
 *  Asks the data source the position of an inApp.
 *
 *
 *  @param templateName inApp template name without extension (.XIB).
 *  @param templateSize inApp size.
 *
 *  @return position option. 
 *  @see BMA4SOverlayInAppPosition
 *  @since Available in SDK 5.2.0 and later.
 */
- (BMA4SOverlayInAppPosition)BMA4SOverlayInAppPositionForTemplate:(NSString *)templateName
                                                             size:(CGSize)templateSize;


/**
 *  Asks the data source the custom origin point of an inApp if BMA4SOverlayInAppPositionForTemplate:size: returned BMA4SOverlayInAppPositionCustom.
 *
 *  @param templateName inApp template name without extension (.XIB).
 *  @param templateSize inApp size.
 *
 *  @return origin point
 *  @since Available in SDK 5.2.0 and later.
 */
- (CGPoint)BMA4SOverlayInAppCustomPositionForTemplate:(NSString *)templateName
                                                 size:(CGSize)templateSize;

@end
