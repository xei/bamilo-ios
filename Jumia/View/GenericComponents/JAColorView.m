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

@property (nonatomic, strong)UIImageView* crop;

@end

@implementation JAColorView

- (void)setColorWithHexString:(NSString*)hexString;
{
    unsigned int colorInt = [JAUtils intFromHexString:hexString];
    [self setBackgroundColor:UIColorFromRGB(colorInt)];
    
    [self.crop removeFromSuperview];
    self.crop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filterColorCrop"]];
    [self addSubview:self.crop];
}

@end
