//
//  JAProductInfoSingleLine.h
//  Jumia
//
//  Created by josemota on 9/23/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAProductInfoBaseLine.h"

#define kProductInfoSingleLineHeight 48

@interface JAProductInfoSingleLine : JAProductInfoBaseLine

@property (strong,nonatomic) UILabel *lineLabel;

-(void) setText:(NSString*)txt;

@end
