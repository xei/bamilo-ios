//
//  JARadioGroupComponent.m
//  Jumia
//
//  Created by telmopinto on 10/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JARadioGroupComponent.h"
#import "RIFieldOption.h"
#import "JAClickableView.h"

@interface JARadioGroupComponent ()

@property (nonatomic, strong) NSMutableArray* checkboxViewsArray;
@property (nonatomic, strong) NSMutableArray* optionLabelsArray;
@property (nonatomic, strong) NSMutableArray* contentViewsArray;
@property (nonatomic, assign) CGRect labelBaseRect;
@property (nonatomic, assign) CGRect checkboxBaseRect;
@property (nonatomic, assign) CGSize contentBaseSize;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation JARadioGroupComponent

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0.f, 0, 320.f, 48.f)];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    self.contentBaseSize = CGSizeMake(self.width,
                                      48.0f);
    
    CGFloat xOffset = 16.0f;
    CGFloat checkboxMargins = 0.0f;
    UIImage* checkboxImage = [UIImage imageNamed:@"selectionCheckmark"];
    self.checkboxBaseRect = CGRectMake(self.contentBaseSize.width - checkboxMargins - checkboxImage.size.width - xOffset,
                                       (self.contentBaseSize.height - checkboxImage.size.height) / 2,
                                       checkboxImage.size.width,
                                       checkboxImage.size.height);
    
    CGFloat labelHeight = 40.0f;
    CGFloat labelBottom = 40.0f;
    self.labelBaseRect = CGRectMake(xOffset,
                                    self.contentBaseSize.height - labelBottom,
                                    self.contentBaseSize.width - self.checkboxBaseRect.size.width - checkboxMargins*2 - xOffset,
                                    labelHeight);
    
    [self flipIfIsRTL];
    
    for (UIView* contentView in self.contentViewsArray) {
        contentView.width = self.contentBaseSize.width;
        contentView.height = self.contentBaseSize.height;
    }
    
    for (UIView* checkbox in self.checkboxViewsArray) {
        [checkbox setFrame:self.checkboxBaseRect];
    }
    
    for (UIView* optionLabel in self.optionLabelsArray) {
        [optionLabel setFrame:self.labelBaseRect];
    }
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        self.checkboxBaseRect = CGRectMake(self.frame.size.width - self.checkboxBaseRect.origin.x - self.checkboxBaseRect.size.width,
                                           self.checkboxBaseRect.origin.y,
                                           self.checkboxBaseRect.size.width,
                                           self.checkboxBaseRect.size.height);
        self.labelBaseRect = CGRectMake(self.frame.size.width - self.labelBaseRect.origin.x - self.labelBaseRect.size.width,
                                        self.labelBaseRect.origin.y,
                                        self.labelBaseRect.size.width,
                                        self.labelBaseRect.size.height);
    }
}

- (void)setupWithField:(RIField*)field
{
    self.field = field;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.contentViewsArray = [NSMutableArray new];
    self.optionLabelsArray = [NSMutableArray new];
    self.checkboxViewsArray = [NSMutableArray new];
    
    UIImage* checkboxImage = [UIImage imageNamed:@"selectionCheckmark"];

    CGFloat currentY = 0.0f;
    for (int i = 0; i < field.options.count; i++) {
        RIFieldOption* option = [field.options objectAtIndex:i];
        
        JAClickableView* contentView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                         currentY,
                                                                                         self.contentBaseSize.width,
                                                                                         self.contentBaseSize.height)];
        contentView.tag = i;
        [contentView addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:contentView];
        [self.contentViewsArray addObject:contentView];
        
        UILabel* optionLabel = [[UILabel alloc] initWithFrame:self.labelBaseRect];
        [optionLabel setNumberOfLines:2];
        [optionLabel setTextColor:JABlackColor];
        [optionLabel setFont:JABodyFont];
        optionLabel.textAlignment = NSTextAlignmentLeft;
        if (RI_IS_RTL) {
            optionLabel.textAlignment = NSTextAlignmentRight;
        }
        optionLabel.text = option.label;
        [contentView addSubview:optionLabel];
        [self.optionLabelsArray addObject:optionLabel];
        
        UIImageView* checkboxImageView = [[UIImageView alloc] initWithImage:checkboxImage];
        [checkboxImageView setFrame:self.checkboxBaseRect];
        [contentView addSubview:checkboxImageView];
        [self.checkboxViewsArray addObject:checkboxImageView];
        
        if ([field.value isEqualToString:option.value]) {
            [checkboxImageView setHidden:NO];
            self.selectedIndex = i;
        } else {
            [checkboxImageView setHidden:YES];
        }
        
        UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(self.labelBaseRect.origin.x,
                                                                         contentView.frame.size.height - 1.0f,
                                                                         contentView.frame.size.width - 16.0f,
                                                                         1.0f)];
        [separatorView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [separatorView setBackgroundColor:JABlack400Color];
        [contentView addSubview:separatorView];
        
        currentY += contentView.frame.size.height;
    }
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            currentY);
}

- (void)optionSelected:(UIControl*)sender
{
    NSInteger indexToSelect = sender.tag;
    
    for (int i = 0; i < self.checkboxViewsArray.count; i++) {
        UIImageView* checkboxImageView = [self.checkboxViewsArray objectAtIndex:i];
        
        if (i == indexToSelect) {
            [checkboxImageView setHidden:NO];
            self.selectedIndex = i;
        } else {
            [checkboxImageView setHidden:YES];
        }
    }
}

- (NSDictionary*)getValues;
{
    NSMutableDictionary* values = [NSMutableDictionary new];
    
    RIFieldOption* option = [self.field.options objectAtIndex:self.selectedIndex];
    [values setObject:option.value forKey:self.field.name];
    
    return [values copy];
}

@end
