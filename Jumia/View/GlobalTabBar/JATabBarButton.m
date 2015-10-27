//
//  JATabBarButton.m
//  Jumia
//
//  Created by Telmo Pinto on 26/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JATabBarButton.h"

#define kLabelNormalTextColor [UIColor blackColor]
#define kLabelHighlightedTextColor JAOrange1Color

@interface JATabBarButton ()

@property (nonatomic, strong) UIView* separatorView;
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIImage* normalImage;
@property (nonatomic, strong) UIImage* highlightedImage;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) UILabel* numberLabel;

@end

@implementation JATabBarButton

@synthesize selected=_selected;
- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
        [self.imageView setImage:self.highlightedImage];
        [self.label setTextColor:kLabelHighlightedTextColor];
    } else {
        [self.imageView setImage:self.normalImage];
        [self.label setTextColor:kLabelNormalTextColor];
    }
}

- (void)setupWithImageName:(NSString*)imageName
      highlightedImageName:(NSString*)highlightedImageName
                     title:(NSString*)title;
{
    if (ISEMPTY(self.clickableView)) {
        self.clickableView = [[JAClickableView alloc] init];
        self.clickableView.frame = self.bounds;
        self.clickableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.clickableView];
    }
    
    if (ISEMPTY(self.separatorView)) {
        self.separatorView = [UIView new];
        self.separatorView.backgroundColor = JABlack700Color;
        self.separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.clickableView addSubview:self.separatorView];
    }
    
    [self.separatorView setFrame:CGRectMake(self.clickableView.bounds.origin.x,
                                            self.clickableView.bounds.origin.y,
                                            self.clickableView.bounds.size.width,
                                            1)];
    
    if (ISEMPTY(self.imageView)) {
        self.imageView = [UIImageView new];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.clickableView addSubview:self.imageView];
    }
    
    self.normalImage = [UIImage imageNamed:imageName];
    self.highlightedImage = [UIImage imageNamed:highlightedImageName];
    [self.imageView setFrame:CGRectMake((self.clickableView.bounds.size.width - self.normalImage.size.width) / 2,
                                        8.0f,
                                        self.normalImage.size.width,
                                        self.normalImage.size.height)];
    
    if (ISEMPTY(self.numberLabel)) {
        self.numberLabel = [UILabel new];
        self.numberLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.numberLabel.font = [UIFont fontWithName:kFontRegularName size:9.0];
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.adjustsFontSizeToFitWidth = YES;
        [self.imageView addSubview:self.numberLabel];
    }
    
    if (ISEMPTY(self.label)) {
        self.label = [UILabel new];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        self.label.font = [UIFont fontWithName:kFontRegularName size:10.0f];
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.clickableView addSubview:self.label];
    }
    
    [self.label setText:title];
    [self.label sizeToFit];
    [self.label setFrame:CGRectMake(self.clickableView.bounds.origin.x,
                                    self.clickableView.bounds.size.height - 8.0f - self.label.frame.size.height,
                                    self.clickableView.bounds.size.width,
                                    self.label.frame.size.height)];
    
    //default
    [self setSelected:NO];
}

- (void)setNumber:(NSInteger)number
{
    //magic numbers... there's no way around it here
    CGRect frame;
    if (number < 10) {
        frame = CGRectMake(self.imageView.bounds.size.width/2 + 4.0f,
                           0.0f,
                           10.0f,
                           12.0f);
    } else if (number < 100) {
        frame = CGRectMake(self.imageView.bounds.size.width/2 + 2.0f,
                           0.0f,
                           12.0f,
                           12.0f);
    } else {
        frame = CGRectMake(self.imageView.bounds.size.width/2 + 2.0f,
                           0.0f,
                           12.0f,
                           12.0f);
    }
    [self.numberLabel setFrame:frame];
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)number];
}

@end
