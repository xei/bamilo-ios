//
//  DeepLinkManager.h
//  Bamilo
//
//  Created by Ali Saeedifar on 3/25/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeepLinkManager : NSObject

+ (void)handleUrl:(NSURL *)url;
+ (void)listenersReady;

@end
