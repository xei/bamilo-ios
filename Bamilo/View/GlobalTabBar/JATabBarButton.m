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

// These values are being used to calculate positions, using as reference its parent view's height.
// So, the bigger the number is, the smaller real top margin will be.
#define kImageTopMargin 8.f
#define kShopImageTopMargin 12.f

#define kLabelBottomMargin 8.f
#define kShopLabelBottomMargin 6.f

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
        [self.label setTextColor:JAOrange1Color];
    } else {
        [self.imageView setImage:self.normalImage];
        [self.label setTextColor:JABlackColor];
    }
    if (RI_IS_RTL) {
        [self.imageView flipViewImage];
    }
}

- (void)setupWithImageName:(NSString*)imageName
      highlightedImageName:(NSString*)highlightedImageName
                     title:(NSString*)title;
{
    // If font type is Zawgyi-One (expected to happen when target is shop),
    // Adjust variables accordingly.
    CGFloat labelBottomMargin = kLabelBottomMargin;
    CGFloat imageOffset = kImageTopMargin;
    UIFont *numberLabelFont = JACaptionFont;
    if ([@"Zawgyi-One" isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kFontRegularNameKey]]) {
        labelBottomMargin = kShopLabelBottomMargin;
        imageOffset = kShopImageTopMargin;
        numberLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:numberLabelFont.pointSize];
    }
    
    if (ISEMPTY(self.clickableView)) {
        self.clickableView = [[JAClickableView alloc] init];
        self.clickableView.frame = self.bounds;
        self.clickableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.clickableView];
    }
    
    if (ISEMPTY(self.separatorView)) {
        self.separatorView = [UIView new];
        self.separatorView.backgroundColor = JABlack400Color;
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
                                        (self.clickableView.height - (self.label.height + imageOffset + self.normalImage.size.height)) / 2, // 6.0f,
                                        self.normalImage.size.width,
                                        self.normalImage.size.height)];
    
    if (ISEMPTY(self.numberLabel)) {
        self.numberLabel = [UILabel new];
        self.numberLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.numberLabel.font = numberLabelFont;
        self.numberLabel.textColor = JAWhiteColor;
        self.numberLabel.adjustsFontSizeToFitWidth = YES;
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        [self.numberLabel setBackgroundColor:JARed1Color];
        [self addSubview:self.numberLabel];
        CGRect frame = CGRectMake(self.bounds.size.width / 2 + 1.f,
                                  8.f,
                                  15.f,
                                  15.f);
        [self.numberLabel setFrame:frame];
        self.numberLabel.layer.masksToBounds = YES;
        self.numberLabel.layer.cornerRadius = frame.size.width / 2;
        [self.numberLabel setHidden:YES];
    }
    
    if (!self.label) {
        self.label = [UILabel new];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        self.label.font = JACaptionFont;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self.clickableView addSubview:self.label];
    }
    [self.label setText:title];
    [self.label sizeToFit];
    [self.label setFrame:CGRectMake(self.clickableView.bounds.origin.x,
                                    self.clickableView.height - self.label.frame.size.height,
                                    self.clickableView.bounds.size.width,
                                    self.label.frame.size.height)];
    
    //default
    [self setSelected:NO];
}

- (void)setNumber:(NSInteger)number
{
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)number];
    [self.numberLabel setHidden:NO];
}

@end
