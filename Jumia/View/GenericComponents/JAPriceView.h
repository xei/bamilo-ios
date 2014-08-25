//
//  JAPriceView.h
//  Jumia
//
//  Created by Telmo Pinto on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPriceView : UIView

- (void)loadWithPrice:(NSString*)price
         specialPrice:(NSString*)specialPrice
             fontSize:(CGFloat)fontSize
specialPriceOnTheLeft:(BOOL)specialPriceOnTheLeft;

@end
