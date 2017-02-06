//
//  IconButton.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "IconButton.h"

@interface IconButton()
@property (nonatomic, strong) CABasicAnimation *bounceAnim;
@end

@implementation IconButton


- (CABasicAnimation *)bounceAnim {
    if (!_bounceAnim) {
        _bounceAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
        _bounceAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _bounceAnim.duration = 0.125;
        _bounceAnim.repeatCount = 1;
        _bounceAnim.autoreverses = YES;
        _bounceAnim.removedOnCompletion = YES;
        _bounceAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    }
    return _bounceAnim;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    const CGFloat spaceBtwIconAndLabel = 3;
    
    CGRect lableFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    CGFloat imageRatio = imageFrame.size.height / imageFrame.size.width;
    
    imageFrame.size.height = self.frame.size.height - 15;
    imageFrame.size.width = imageFrame.size.height / imageRatio;
    lableFrame.origin.x = (self.frame.size.width / 2)  - ((imageFrame.size.width + lableFrame.size.width + spaceBtwIconAndLabel) / 2);
    imageFrame.origin.x = lableFrame.origin.x + lableFrame.size.width + spaceBtwIconAndLabel;
    
    self.imageView.frame = imageFrame;
    self.titleLabel.frame = lableFrame;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.imageView.layer addAnimation: self.bounceAnim forKey:nil];
}

@end
