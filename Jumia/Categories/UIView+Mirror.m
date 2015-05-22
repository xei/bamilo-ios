//
//  UIView+Mirror.m
//  Jumia
//
//  Created by Telmo Pinto on 22/05/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "UIView+Mirror.h"
#import "UIImage+Mirror.h"

@implementation UIView (Mirror)

- (void)flipViewPositionInsideSuperview
{
    CGFloat superviewWidth = self.superview.frame.size.width;
    
    CGFloat newX = superviewWidth - self.frame.origin.x - self.frame.size.width;
    
    [self setFrame:CGRectMake(newX,
                              self.frame.origin.y,
                              self.frame.size.width,
                              self.frame.size.height)];
}

- (void)flipViewAlignment
{
    if ([self isKindOfClass:[UILabel class]]) {
        
        UILabel* label = (UILabel*)self;
        NSTextAlignment currentAlignment = label.textAlignment;
        
        if (NSTextAlignmentLeft == currentAlignment) {
            label.textAlignment = NSTextAlignmentRight;
        } else if (NSTextAlignmentRight == currentAlignment) {
            label.textAlignment = NSTextAlignmentLeft;
        }
    } else if ([self isKindOfClass:[UIButton class]]) {
        
        UIButton* button = (UIButton*)self;
        UIControlContentHorizontalAlignment currentAlignment = button.contentHorizontalAlignment;
        
        if (UIControlContentHorizontalAlignmentLeft == currentAlignment) {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        } else if (UIControlContentHorizontalAlignmentRight == currentAlignment) {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
    }
}

- (void)flipViewImage
{
    if ([self isKindOfClass:[UIButton class]]) {
        
        UIButton* button = (UIButton*)self;
        
        UIImage* currentImageNormal = [button imageForState:UIControlStateNormal];
        UIImage* currentImageHighlighted = [button imageForState:UIControlStateHighlighted];
        UIImage* currentImageSelected = [button imageForState:UIControlStateSelected];
        UIImage* currentImageDisabled = [button imageForState:UIControlStateDisabled];
        
        UIImage* newImageNormal = [currentImageNormal flipImageWithOrientation:UIImageOrientationUpMirrored];
        UIImage* newImageHighlighted = [currentImageHighlighted flipImageWithOrientation:UIImageOrientationUpMirrored];
        UIImage* newImageSelected = [currentImageSelected flipImageWithOrientation:UIImageOrientationUpMirrored];
        UIImage* newImageDisabled = [currentImageDisabled flipImageWithOrientation:UIImageOrientationUpMirrored];
        
        [button setImage:newImageNormal forState:UIControlStateNormal];
        [button setImage:newImageHighlighted forState:UIControlStateHighlighted];
        [button setImage:newImageSelected forState:UIControlStateSelected];
        [button setImage:newImageDisabled forState:UIControlStateDisabled];
        
    } else if ([self isKindOfClass:[UIImageView class]]) {
     
        UIImageView* imageView = (UIImageView*)self;
        UIImage* currentImage = imageView.image;
        
        UIImage* newImage = [currentImage flipImageWithOrientation:UIImageOrientationUpMirrored];
        imageView.image = newImage;
    }
}

- (void)flipSubviewPositions
{
    for (UIView* view in self.subviews) {
        [view flipViewPositionInsideSuperview];
    }
}

- (void)flipSubviewAlignments
{
    for (UIView* view in self.subviews) {
        [view flipViewAlignment];
    }
}

- (void)flipSubviewImages
{
    for (UIView* view in self.subviews) {
        [view flipViewImage];
    }
}

@end
