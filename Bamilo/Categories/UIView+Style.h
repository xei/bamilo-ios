//
//  UIView+Style.h
//  Jumia
//
//  Created by Ali saiedifar on 1/23/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Style)
@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable UIColor *borderColor;
@end
