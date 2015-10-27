//
//  JAPDVProductInfoSellerInfo.h
//  Jumia
//
//  Created by josemota on 9/30/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RISeller.h"
#import "JAClickableView.h"

@interface JAPDVProductInfoSellerInfo : JAClickableView

@property (nonatomic) RISeller *seller;

- (void)addTarget:(id)target action:(SEL)action;

@end
