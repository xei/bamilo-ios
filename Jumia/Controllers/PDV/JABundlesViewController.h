//
//  JABundlesViewController.h
//  Jumia
//
//  Created by josemota on 10/5/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIProduct.h"

@interface JABundlesViewController : JABaseViewController

@property (nonatomic) RIProduct *product;
@property (nonatomic) NSArray *bundles;
@property (nonatomic) NSMutableDictionary *selectedItems;
@property (nonatomic) RIBundle *bundle;

- (void)onBundleSelectionChanged:(void(^)(NSMutableDictionary *selectedSkus))changes;

@end
