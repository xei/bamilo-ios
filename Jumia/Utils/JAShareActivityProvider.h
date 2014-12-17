//
//  JAShareActivityProvider.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RIProduct.h"

@interface JAShareActivityProvider : UIActivityItemProvider
<
    UIActivityItemSource
>

- (id)initForProductShare:(RIProduct *)product;

- (id)initForAppShare;

@end
