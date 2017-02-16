//
//  IconButton.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "IconButton.h"
#import "NSString+Size.h"

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
    const CGFloat spaceBtwIconAndLabel = 5;
    
    CGRect labelFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    
    labelFrame.size = [self.titleLabel.text sizeForFont:self.titleLabel.font withMaxWidth:self.size.width];
    
    imageFrame.size.height = self.size.height * 0.5;
    imageFrame.size.width = imageFrame.size.height;
    labelFrame.origin.x = (self.size.width / 2)  - ((imageFrame.size.width + labelFrame.size.width + spaceBtwIconAndLabel) / 2);
    imageFrame.origin.x = labelFrame.origin.x + labelFrame.size.width + spaceBtwIconAndLabel;
    imageFrame.origin.y = (self.size.height / 2) - (imageFrame.size.height / 2);
    labelFrame.origin.y = (self.size.height / 2) - (labelFrame.size.height / 2);
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.frame = imageFrame;
    self.titleLabel.frame = labelFrame;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.imageView.layer addAnimation: self.bounceAnim forKey:nil];
}

@end
