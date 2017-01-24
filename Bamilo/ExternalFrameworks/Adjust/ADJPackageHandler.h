//
//  ADJPackageHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ADJActivityPackage.h"
#import "ADJPackageHandler.h"
#import "ADJActivityHandler.h"
#import "ADJResponseData.h"

@protocol ADJPackageHandler

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                  startPaused:(BOOL)startPaused;

- (void)addPackage:(ADJActivityPackage *)package;
- (void)sendFirstPackage;
- (void)sendNextPackage:(ADJResponseData *)responseData;
- (void)closeFirstPackage:(ADJResponseData *)responseData;;
- (void)pauseSending;
- (void)resumeSending;

@end

@interface ADJPackageHandler : NSObject <ADJPackageHandler>

+ (id<ADJPackageHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                                        startPaused:(BOOL)startPaused;

@end
