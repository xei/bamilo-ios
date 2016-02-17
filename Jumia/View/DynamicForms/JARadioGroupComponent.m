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

    CGFloat xOffset = 16.0f;
    CGFloat checkboxMargins = 0.0f;
    UIImage* checkboxImage = [UIImage imageNamed:@"selectionCheckmark"];
    self.checkboxBaseRect = CGRectMake(self.frame.size.width - checkboxMargins - checkboxImage.size.width - xOffset,
                                       (self.frame.size.height - checkboxImage.size.height) / 2,
                                       checkboxImage.size.width,
                                       checkboxImage.size.height);
    
    CGFloat labelHeight = 20.0f;
    CGFloat labelBottom = 28.0f;
    self.labelBaseRect = CGRectMake(xOffset,
                                    self.height - labelBottom,
                                    self.width - self.checkboxBaseRect.size.width - checkboxMargins*2,
                                    labelHeight);
    
    self.contentBaseSize = CGSizeMake(320.0f,
                                      48.0f);

    
    [self flipIfIsRTL];
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        //$$$ DO RTL
    }
}

- (void)setupWithField:(RIField*)field
{
    self.field = field;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.contentViewsArray = [NSMutableArray new];
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
        [optionLabel setTextColor:JABlackColor];
        [optionLabel setFont:JABody3Font];
        optionLabel.text = option.label;
        [contentView addSubview:optionLabel];
        
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
        
        if (i < field.options.count - 1) {
            UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(16.0f,
                                                                             contentView.frame.size.height - 1.0f,
                                                                             contentView.frame.size.width - 16.0f,
                                                                             1.0f)];
            [separatorView setBackgroundColor:JABlack400Color];
            [contentView addSubview:separatorView];
        }
        
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
