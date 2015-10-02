//
//  JAPDVProductInfoSellerInfo.h
//  Jumia
//
//  Created by josemota on 9/30/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RISeller.h"

@interface JAPDVProductInfoSellerInfo : UIView

@property (nonatomic) RISeller *seller;

- (void)addTarget:(id)target action:(SEL)action;

@end
