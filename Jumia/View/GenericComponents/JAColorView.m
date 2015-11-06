//
//  JAColorView.m
//  Jumia
//
//  Created by Telmo Pinto on 14/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAColorView.h"
#import "JAUtils.h"

@interface JAColorView()

@property (nonatomic, strong)UIView* centerView;

@end

@implementation JAColorView

- (void)setColorWithHexString:(NSString*)hexString;
{
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat centerViewHeight = 22.0f;
    CGFloat centerViewX = 16.0f;
    [self.centerView removeFromSuperview];
    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(centerViewX,
                                                               (self.frame.size.height - centerViewHeight) / 2,
                                                               centerViewHeight,
                                                               centerViewHeight)];
    unsigned int colorInt = [JAUtils intFromHexString:hexString];
    [self.centerView setBackgroundColor:UIColorFromRGB(colorInt)];
    [self addSubview:self.centerView];
    
    self.centerView.layer.cornerRadius = self.centerView.frame.size.height /2;
    self.centerView.layer.masksToBounds = YES;
    self.centerView.layer.borderWidth = 0;
}

@end
