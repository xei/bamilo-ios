//
//  BMA4SInBoxButton.h
//  Accengage SDK 4.1.6
//
//  Copyright (c) 2010-2014 Accengage. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BMA4SInBoxButtonWillInteract;


/**
 Define the structure of a BMA4SInBoxButton object
 */
@interface BMA4SInBoxButton : NSObject

/**
 This property define the title of BMA4SInBoxButton object
 */
@property (nonatomic, readonly) NSString *title;

/** 
 Call 'interact' method on appropriate BMA4SInBoxButton object
 */
-(void)interact;

@end
