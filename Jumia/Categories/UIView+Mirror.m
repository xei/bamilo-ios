//
//  UIView+Mirror.m
//  Jumia
//
//  Created by Telmo Pinto on 22/05/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "UIView+Mirror.h"
#import "UIImage+Mirror.h"
#import "JAClickableView.h"
#import "JADynamicForm.h"
#import "JAAddRatingView.h"
#import "JAPagedView.h"

@implementation UIView (Mirror)

- (void)flipViewPositionInsideSuperview
{
    CGFloat superviewWidth = self.superview.frame.size.width;
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        if (((UIScrollView *)self.superview).contentSize.width > ((UIScrollView *)self.superview).width) {
            superviewWidth = ((UIScrollView *)self.superview).contentSize.width;
        }
    }

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
    } else if ([self isKindOfClass:[UITextField class]]) {
        
        UITextField* textField = (UITextField*)self;
        NSTextAlignment currentAlignment = textField.textAlignment;
        
        if (NSTextAlignmentLeft == currentAlignment) {
            textField.textAlignment = NSTextAlignmentRight;
        } else if (NSTextAlignmentRight == currentAlignment) {
            textField.textAlignment = NSTextAlignmentLeft;
        }
    } else if ([self isKindOfClass:[UIButton class]]) {
        
        UIButton* button = (UIButton*)self;
        UIControlContentHorizontalAlignment currentAlignment = button.contentHorizontalAlignment;
        
        if (UIControlContentHorizontalAlignmentLeft == currentAlignment) {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        } else if (UIControlContentHorizontalAlignmentRight == currentAlignment) {
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        } else if (UIControlContentHorizontalAlignmentCenter == currentAlignment) {
            
            CGFloat imageWidth = button.imageView.frame.size.width;
            CGFloat textWidth = button.titleLabel.frame.size.width;
            
            CGFloat newTextX = -imageWidth;
            CGFloat newImageX = textWidth;
            
            UIEdgeInsets currentImageInsets = button.imageEdgeInsets;
            UIEdgeInsets currentTextInsets = button.titleEdgeInsets;
            
            button.imageEdgeInsets = UIEdgeInsetsMake(currentImageInsets.top,
                                                      newImageX,
                                                      currentImageInsets.bottom,
                                                      -newImageX);
            button.titleEdgeInsets = UIEdgeInsetsMake(currentTextInsets.top,
                                                      newTextX,
                                                      currentTextInsets.bottom,
                                                      -newTextX);
            
        }
    } else if ([self isKindOfClass:[JAClickableView class]]) {
    
        JAClickableView* clickableView = (JAClickableView*)self;
        UIControlContentHorizontalAlignment currentAlignment = clickableView.contentHorizontalAlignment;
        
        if (UIControlContentHorizontalAlignmentLeft == currentAlignment) {
            clickableView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        } else if (UIControlContentHorizontalAlignmentRight == currentAlignment) {
            clickableView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        } else if (UIControlContentHorizontalAlignmentCenter == currentAlignment) {
            
            CGFloat imageWidth = clickableView.imageView.frame.size.width;
            CGFloat textWidth = clickableView.titleLabel.frame.size.width;
            
            CGFloat newTextX = -imageWidth;
            CGFloat newImageX = textWidth;
            
            UIEdgeInsets currentImageInsets = clickableView.imageEdgeInsets;
            UIEdgeInsets currentTextInsets = clickableView.titleEdgeInsets;
            
            clickableView.imageEdgeInsets = UIEdgeInsetsMake(currentImageInsets.top,
                                                             newImageX,
                                                             currentImageInsets.bottom,
                                                             -newImageX);
            clickableView.titleEdgeInsets = UIEdgeInsetsMake(currentTextInsets.top,
                                                             newTextX,
                                                             currentTextInsets.bottom,
                                                             -newTextX);
        }
    } else if ([self isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self;
        [((UIScrollView *)self) setContentOffset:CGPointMake(scrollView.contentSize.width - scrollView.width, scrollView.contentOffset.y)];
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

    } else if ([self isKindOfClass:[JAClickableView class]]) {
    
        JAClickableView* clickableView = (JAClickableView*)self;
        
        UIImage* currentImageNormal = [clickableView imageForState:UIControlStateNormal];
        UIImage* currentImageHighlighted = [clickableView imageForState:UIControlStateHighlighted];
        UIImage* currentImageSelected = [clickableView imageForState:UIControlStateSelected];
        UIImage* currentImageDisabled = [clickableView imageForState:UIControlStateDisabled];
        
        UIImage* newImageNormal = [currentImageNormal flipImageWithOrientation:UIImageOrientationUpMirrored];
        UIImage* newImageHighlighted = [currentImageHighlighted flipImageWithOrientation:UIImageOrientationUpMirrored];
        UIImage* newImageSelected = [currentImageSelected flipImageWithOrientation:UIImageOrientationUpMirrored];
        UIImage* newImageDisabled = [currentImageDisabled flipImageWithOrientation:UIImageOrientationUpMirrored];
        
        [clickableView setImage:newImageNormal forState:UIControlStateNormal];
        [clickableView setImage:newImageHighlighted forState:UIControlStateHighlighted];
        [clickableView setImage:newImageSelected forState:UIControlStateSelected];
        [clickableView setImage:newImageDisabled forState:UIControlStateDisabled];
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

- (void)flipAllSubviews
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollview = (UIScrollView *)view;
            if (scrollview.contentSize.width < view.width) {
                [scrollview setContentSize:CGSizeMake(view.width, scrollview.contentSize.height)];
            }
        }
        if ([view isKindOfClass:[UITableView class]]) {
            [view flipViewPositionInsideSuperview];
            continue;
        } else if ([view isKindOfClass:[JADynamicField class]]) {
            continue;
        } else if ([view isKindOfClass:[JAPagedView class]]) {
            continue;
        } else {
            [view flipViewPositionInsideSuperview];
            [view flipViewAlignment];
//            [view flipViewImage];
            if ([view isKindOfClass:[UISwitch class]]) {
                continue;
            } else {
                [view flipAllSubviews];
            }
        }
    }
}

- (void)flipSubviewImages
{
    for (UIView* view in self.subviews) {
        [view flipViewImage];
    }
}

@end
