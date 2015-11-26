//
//  RITarget.h
//  Jumia
//
//  Created by Telmo Pinto on 23/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RITarget : NSObject

@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* node;
@property (nonatomic, strong) NSString* urlString;

+ (RITarget*)parseTarget:(NSString*)targetString;
+ (NSString*)getURLStringforTargetString:(NSString*)targetString;

@end
