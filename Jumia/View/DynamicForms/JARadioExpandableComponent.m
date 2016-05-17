//
//  JARadioExpandableComponent.m
//  Jumia
//
//  Created by telmopinto on 13/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JARadioExpandableComponent.h"
#import "JAClickableView.h"
#import "RIFieldOption.h"

@interface JARadioExpandableComponent()

@property (nonatomic, strong) NSMutableArray* checkboxViewsArray;
@property (nonatomic, strong) NSMutableArray* optionLabelsArray;
@property (nonatomic, strong) NSMutableArray* contentViewsArray;
@property (nonatomic, assign) CGRect labelBaseRect;
@property (nonatomic, assign) CGRect checkboxBaseRect;
@property (nonatomic, assign) CGSize contentBaseSize;

@property (nonatomic, strong) NSNumber *selectedIndex;

@property (nonatomic, strong) UILabel *selectedLabel;
@property (nonatomic, strong) UILabel *selectedSublabel;
@property (nonatomic, strong) UIView *selectedSublabelBackground;

@end

@implementation JARadioExpandableComponent

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
    
    CGFloat xOffset = 0.0f;
    CGFloat checkboxMargins = 10.0f;
    UIImage* checkboxImage = [UIImage imageNamed:@"round_checkbox_selected"];
    self.checkboxBaseRect = CGRectMake(xOffset,
                                       (self.contentBaseSize.height - checkboxImage.size.height) / 2,
                                       checkboxImage.size.width,
                                       checkboxImage.size.height);
    
    CGFloat labelHeight = 40.0f;
    self.labelBaseRect = CGRectMake(CGRectGetMaxX(self.checkboxBaseRect) + checkboxMargins,
                                    (self.contentBaseSize.height - labelHeight) / 2,
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
    
    UIImage* checkboxImage = [UIImage imageNamed:@"round_checkbox_selected"];
    UIImage* checkboxImageDeselected = [UIImage imageNamed:@"round_checkbox_deselected"];
    
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
        [optionLabel setFont:JATitleFont];
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
        
        currentY += contentView.frame.size.height;
        
        NSInteger selectedIndex = -1;
        if (VALID_NOTEMPTY(self.selectedIndex, NSNumber)) {
            selectedIndex = [self.selectedIndex integerValue];
        } else {
            if ([field.value isEqualToString:option.value]) {
                selectedIndex = i;
                self.selectedIndex = [NSNumber numberWithInteger:selectedIndex];
            }
        }
        if (i == selectedIndex) {
            [checkboxImageView setImage:checkboxImage];
            
            self.selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(optionLabel.frame.origin.x,
                                                                           self.contentBaseSize.height,
                                                                           optionLabel.frame.size.width,
                                                                           1.0f)];
            self.selectedLabel.textAlignment = NSTextAlignmentLeft;
            self.selectedLabel.textColor = JABlack800Color;
            self.selectedLabel.font = JAListFont;
            self.selectedLabel.text = [NSString stringWithFormat:@"%@ %@",option.linkLabel, option.text];
            [self.selectedLabel sizeToFit];
            [contentView addSubview:self.selectedLabel];
            
            self.selectedSublabel = [[UILabel alloc] initWithFrame:CGRectMake(optionLabel.frame.origin.x,
                                                                              CGRectGetMaxY(self.selectedLabel.frame) + 20.0f,
                                                                              optionLabel.frame.size.width,
                                                                              1.0f)];
            self.selectedSublabel.textAlignment = NSTextAlignmentLeft;
            self.selectedSublabel.textColor = JABlackColor;
            self.selectedSublabel.font = JAListFont;
            self.selectedSublabel.text = option.subtext;
            [self.selectedSublabel sizeToFit];
            //add to subview after background
            
            self.selectedSublabelBackground = [[UIView alloc] initWithFrame:CGRectMake(20.0f,
                                                                                       self.selectedSublabel.frame.origin.y - 5.0f,
                                                                                       contentView.frame.size.width - 20.0f*2,
                                                                                       self.selectedSublabel.frame.size.height + 10.0f)];
            self.selectedSublabelBackground.backgroundColor = JAYellow2Color;
            self.selectedSublabelBackground.layer.borderColor = [JAYellow1Color CGColor];
            self.selectedSublabelBackground.layer.borderWidth = 1.0f;
            [contentView addSubview:self.selectedSublabelBackground];
            
            [contentView addSubview:self.selectedSublabel];
            
            [contentView setHeight:CGRectGetMaxY(self.selectedSublabelBackground.frame) + 20.0f];
            
            currentY = CGRectGetMaxY(contentView.frame);
            
        } else {
            [checkboxImageView setImage:checkboxImageDeselected];
        }
    }
    
    CGFloat delta = self.frame.size.height - currentY;
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            currentY);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(radioExpandableComponent:changedHeight:)]) {
            [self.delegate radioExpandableComponent:self changedHeight:delta];
        }
    }
}

- (void)optionSelected:(UIControl*)sender
{
    self.selectedIndex = [NSNumber numberWithInteger:sender.tag];
    
    [self setupWithField:self.field];
}

- (NSDictionary*)getValues;
{
    NSMutableDictionary* values = [NSMutableDictionary new];
    
    RIFieldOption* option = [self.field.options objectAtIndex:[self.selectedIndex integerValue]];
    [values setObject:option.value forKey:self.field.name];
    
    return [values copy];
}

-(BOOL)isValid
{
    BOOL valid = VALID_NOTEMPTY(self.selectedIndex, NSNumber);
    if (!valid) {
        self.currentErrorMessage = self.field.requiredMessage;
    }
    return valid;
}

-(NSString*)getFieldName
{
    return self.field.name;
}

@end
