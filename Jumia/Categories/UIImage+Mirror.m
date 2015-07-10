//
//  UIImage+Mirror.m
//  Kaymu
//
//  Created by tiagodias on 14/04/15.
//  Copyright (c) 2015 KA. All rights reserved.
//

#import "UIImage+Mirror.h"

@implementation UIImage (Mirror)

- (UIImage *)flipImageWithOrientation:(UIImageOrientation)orientation
{
    UIImage *flippedImage = [UIImage imageWithCGImage:self.CGImage
                                                scale:self.scale
                                          orientation:orientation];
    
    return flippedImage;
}

@end