//
//  UIView+Extensions.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extensions)

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property (nonatomic, assign) IBInspectable CGFloat borderWidth;
@property (nonatomic, assign) IBInspectable UIColor *borderColor;
@property (nonatomic, assign) IBInspectable UIColor *shadowColor;
@property (nonatomic, assign) IBInspectable CGSize shadowOffset;
@property (nonatomic, assign) IBInspectable CGFloat shadowRadius;
@property (nonatomic, assign) IBInspectable CGFloat shadowOpacity;

-(void) anchorMatch:(UIView *)view;
-(CGSize) sizeToFitSubviews;
- (void)hide;
- (void)fadeIn:(NSTimeInterval) duration;

@end
