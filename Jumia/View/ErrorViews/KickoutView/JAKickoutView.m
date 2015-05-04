//
//  JAKickoutView.m
//  Jumia
//
//  Created by Telmo Pinto on 30/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAKickoutView.h"

@interface JAKickoutView()

@property (nonatomic, strong)UIImageView* backgroundImageView;
@property (nonatomic, strong)UIView* containerView;
@property (nonatomic, strong)UIImageView* logoImageView;
@property (nonatomic, strong)UILabel* firstMessageLabel;
@property (nonatomic, strong)UILabel* secondMessageLabel;
@property (nonatomic, strong)UILabel* thirdMessageLabel;

@end

@implementation JAKickoutView

void(^retryBock)(BOOL dismiss);
- (void)setRetryBlock:(void(^)(BOOL dismiss))completion
{
    retryBock = completion;
}

- (void)retryConnection
{
    if (retryBock) {
        retryBock(YES);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeFromSuperview];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(retryConnection)
                                                     name:kAppWillEnterForeground
                                                   object:nil];
    }
    return self;
}


- (void)setupKickoutView:(CGRect)frame orientation:(UIInterfaceOrientation)myOrientation
{
    [self removeViews];
    
    self.backgroundColor = [UIColor blackColor];
    
    CGFloat screenWidth = frame.size.width;
    CGFloat screenHeight = frame.size.height;
    
    if(UIInterfaceOrientationIsPortrait(myOrientation))
    {
        if(screenWidth > screenHeight)
        {
            frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
        else
        {
            frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
    }
    else
    {
        if(screenWidth > screenHeight)
        {
            frame  = CGRectMake(0, 0, screenWidth, screenHeight);
        }
        else
        {
            frame  = CGRectMake(0, 0, screenHeight, screenWidth);
        }
    }
    
    [self setFrame:frame];
    
    NSString* imageName = @"kickoutBackground";
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        imageName = [imageName stringByAppendingString:@"~ipad"];
    } else {
        imageName = [imageName stringByAppendingString:@"~iphone"];
    }
    UIImage* backgroundImage = [UIImage imageNamed:imageName];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [self addSubview:self.backgroundImageView];
    [self.backgroundImageView setFrame:CGRectMake(self.bounds.size.width - backgroundImage.size.width,
                                             self.bounds.size.height - backgroundImage.size.height,
                                             backgroundImage.size.width,
                                             backgroundImage.size.height)];

    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    [self addSubview:self.containerView];
    //height is variable and will be defined as we go along
    CGFloat currentY = 0.0f;
    //although the height will be defined at the end, the width as to be set now because it will be used to measure the labels
    CGFloat containerWidth = 272.0f;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        containerWidth = 380;
    }
    
    CGFloat verticalMarginBetweenComponents = 16.0f;
    
    currentY += verticalMarginBetweenComponents;
    
    UIImage* logoImage = [UIImage imageNamed:@"maintenanceLogo"];
    self.logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    [self.logoImageView setFrame:CGRectMake((containerWidth - logoImage.size.width) / 2,
                                            currentY,
                                            logoImage.size.width,
                                            logoImage.size.height)];
    [self.containerView addSubview:self.logoImageView];
    
    currentY += verticalMarginBetweenComponents + self.logoImageView.frame.size.height;
    
    CGFloat labelMargin = 8.0f;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        labelMargin = 50.0f;
    }
    CGFloat labelWidth = containerWidth - labelMargin*2;
    
    self.firstMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMargin,
                                                                       currentY,
                                                                       labelWidth,
                                                                       1)];
    self.firstMessageLabel.numberOfLines = -1;
    self.firstMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.firstMessageLabel.font = [UIFont fontWithName:kFontMediumName size:15.0f];
    self.firstMessageLabel.textColor = UIColorFromRGB(0xffa200);
    self.firstMessageLabel.text = STRING_KICKOUT_MESSAGE_1;
    [self.firstMessageLabel sizeToFit];
    [self.containerView addSubview:self.firstMessageLabel];
    
    currentY += verticalMarginBetweenComponents + self.firstMessageLabel.frame.size.height;
    
    self.secondMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMargin,
                                                                        currentY,
                                                                        labelWidth,
                                                                        1)];
    self.secondMessageLabel.numberOfLines = -1;
    self.secondMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.secondMessageLabel.font = [UIFont fontWithName:kFontLightName size:12.0f];
    self.secondMessageLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.secondMessageLabel.text = STRING_KICKOUT_MESSAGE_2;
    [self.secondMessageLabel sizeToFit];
    [self.containerView addSubview:self.secondMessageLabel];
    
    currentY += verticalMarginBetweenComponents + self.secondMessageLabel.frame.size.height;
    
    self.thirdMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMargin,
                                                                       currentY,
                                                                       labelWidth,
                                                                       1)];
    self.thirdMessageLabel.numberOfLines = -1;
    self.thirdMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.thirdMessageLabel.font = [UIFont fontWithName:kFontMediumName size:12.0f];
    self.thirdMessageLabel.textColor = UIColorFromRGB(0x4e4e4e);
    self.thirdMessageLabel.text = STRING_KICKOUT_MESSAGE_3;
    [self.thirdMessageLabel sizeToFit];
    [self.containerView addSubview:self.thirdMessageLabel];
    
    currentY += verticalMarginBetweenComponents + self.thirdMessageLabel.frame.size.height;
    
    CGFloat containerTopMargin = 30.0f;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        containerTopMargin = 50.0f;
    }
    [self.containerView setFrame:CGRectMake((self.frame.size.width - containerWidth) / 2,
                                            containerTopMargin,
                                            containerWidth,
                                            currentY)];
}

-(void) removeViews
{
    [self.backgroundImageView removeFromSuperview];
    [self.containerView removeFromSuperview];
    [self.logoImageView removeFromSuperview];
    [self.firstMessageLabel removeFromSuperview];
    [self.secondMessageLabel removeFromSuperview];
    [self.thirdMessageLabel removeFromSuperview];
}


@end
