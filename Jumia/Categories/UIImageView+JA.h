//
//  UIImageView+JA.h
//  Jumia
//
//  Created by Pedro Lopes on 05/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

@interface UIImageView (JA)

/**
 Method to set the image
 @param image The image to be setted
 @param height The height of the image to be setted
 @param width The width of the image to be setted
 
 */
- (void) setImage:(UIImage*)image
       withHeight:(CGFloat)height
         andWidth:(CGFloat)width;

- (void) changeImageHeight:(CGFloat)height
                  andWidth:(CGFloat)width;
@end
