//
//  JASwitchRadioComponent.m
//  Jumia
//
//  Created by telmopinto on 11/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JASwitchRadioComponent.h"
#import "JAClickableView.h"
#import "RIFieldOption.h"

@interface JASwitchRadioComponent()

@property (strong, nonatomic) UILabel *labelText;
@property (strong, nonatomic) UISwitch *switchComponent;

@property (nonatomic, strong) UIView* switchExpandableContainer;

@property (nonatomic, strong) NSMutableArray* checkboxViewsArray;
@property (nonatomic, strong) NSMutableArray* contentViewsArray;
@property (nonatomic, assign) CGRect labelBaseRect;
@property (nonatomic, assign) CGRect checkboxBaseRect;
@property (nonatomic, assign) CGSize contentBaseSize;

@property (nonatomic, assign) NSInteger selectedIndex;

@end

@implementation JASwitchRadioComponent

- (UILabel *)labelText
{
    if (!VALID_NOTEMPTY(_labelText, UILabel)) {
        _labelText = [[UILabel alloc]init];
        _labelText.frame = CGRectMake(76.f,
                                      14.0f,
                                      self.width - 76.0f - 16.0f,
                                      20.0f);
        [_labelText setFont:JABody3Font];
        [_labelText setTextColor:JABlackColor];
        [_labelText setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_labelText];
    }
    return _labelText;
}

- (UISwitch *)switchComponent
{
    if (!VALID_NOTEMPTY(_switchComponent, UISwitch)) {
        _switchComponent = [UISwitch new];
        _switchComponent.frame = CGRectMake(16.f,
                                            (48.0f - _switchComponent.height) / 2,
                                            _switchComponent.width,
                                            _switchComponent.height);
        [_switchComponent addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_switchComponent];
    }
    return _switchComponent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0.f, 0.f, 320.f, 48.f)];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat xOffset = 16.f;
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
    
    self.labelText.frame = CGRectMake(76.f,
                                      14.0f,
                                      self.width - 76.0f - 16.0f,
                                      20.0f);
    self.labelText.textAlignment = NSTextAlignmentLeft;
    self.switchComponent.frame = CGRectMake(16.f,
                                            (48.0f - self.switchComponent.height) / 2,
                                            self.switchComponent.width,
                                            self.switchComponent.height);
    
    [self flipIfIsRTL];
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        [self.switchComponent flipViewPositionInsideSuperview];
        [self.labelText flipViewPositionInsideSuperview];
        [self.labelText flipViewAlignment];
        
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

-(void)setupWithField:(RIField*)field
{
    self.field = field;
    
    [self.switchComponent setOn:[field.checked boolValue] animated:NO];
    
    self.labelText.text = field.label;
    
    
    if (VALID_NOTEMPTY_VALUE(field.relatedFields, NSOrderedSet)) {
        
        [self.switchExpandableContainer removeFromSuperview];
        
        self.switchExpandableContainer = [[UIView alloc] init];
        [self addSubview:self.switchExpandableContainer];
        
        self.contentViewsArray = [NSMutableArray new];
        self.checkboxViewsArray = [NSMutableArray new];
        
        UIImage* checkboxImage = [UIImage imageNamed:@"selectionCheckmark"];
        
        CGFloat currentY = 0.0f;
        for (int i = 0; i < field.relatedFields.count; i++) {
            RIField* relatedField = [field.relatedFields objectAtIndex:i];
            
            JAClickableView* contentView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                             currentY,
                                                                                             self.contentBaseSize.width,
                                                                                             self.contentBaseSize.height)];
            contentView.tag = i;
            [contentView addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self.switchExpandableContainer addSubview:contentView];
            [self.contentViewsArray addObject:contentView];
            
            UILabel* optionLabel = [[UILabel alloc] initWithFrame:self.labelBaseRect];
            [optionLabel setTextColor:JABlackColor];
            [optionLabel setFont:JABody3Font];
            optionLabel.text = relatedField.label;
            optionLabel.textAlignment = NSTextAlignmentLeft;
            if (RI_IS_RTL) {
                optionLabel.textAlignment = NSTextAlignmentRight;
            }
            [contentView addSubview:optionLabel];
            
            UIImageView* checkboxImageView = [[UIImageView alloc] initWithImage:checkboxImage];
            [checkboxImageView setFrame:self.checkboxBaseRect];
            [contentView addSubview:checkboxImageView];
            [self.checkboxViewsArray addObject:checkboxImageView];
            
            if ([relatedField.checked boolValue]) {
                [checkboxImageView setHidden:NO];
                self.selectedIndex = i;
            } else {
                [checkboxImageView setHidden:YES];
            }
            
            if (i < field.relatedFields.count - 1) {
                UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(self.labelBaseRect.origin.x,
                                                                                 contentView.frame.size.height - 1.0f,
                                                                                 contentView.frame.size.width - 16.0f,
                                                                                 1.0f)];
                [separatorView setBackgroundColor:JABlack400Color];
                [contentView addSubview:separatorView];
            }
            
            currentY += contentView.frame.size.height;
        }
        
        [self.switchExpandableContainer setFrame:CGRectMake(0.0f,
                                                            48.0f,
                                                            self.frame.size.width,
                                                            currentY)];
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                CGRectGetMaxY(self.switchExpandableContainer.frame));

    }
    
    [self changedState:self.switchComponent];
}

- (void)changedState:(UISwitch*)sender
{
    CGFloat oldHeight = self.frame.size.height;
    CGFloat newHeight = 0.0f;
    if (sender.isOn) {
        newHeight = CGRectGetMaxY(self.switchExpandableContainer.frame);
    } else {
        newHeight = 48.0f;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  newHeight)];
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchRadioComponent:changedHeight:)]) {
        CGFloat delta = newHeight - oldHeight;
        [self.delegate switchRadioComponent:self changedHeight:delta];
    }
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
    
    if (self.switchComponent.isOn) {
     
        //search for selected field
        RIField* field = [self.field.relatedFields objectAtIndex:self.selectedIndex];
        
        [values setObject:field.value forKey:self.field.name];
    }
    
    return values;
}

- (void)forceSelection;
{
    [self.switchComponent setOn:YES];
    [self changedState:self.switchComponent];
}

@end
