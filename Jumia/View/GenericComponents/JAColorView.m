//
//  JAColorView.m
//  Jumia
//
//  Created by Telmo Pinto on 14/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAColorView.h"
#import "JAUtils.h"
#import "UIColor+Format.h"

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
    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(centerViewX, (self.frame.size.height - centerViewHeight) / 2, centerViewHeight, centerViewHeight)];

    [self.centerView setBackgroundColor: [UIColor withHexString: hexString]];
    
    
    [self addSubview:self.centerView];
    
    self.centerView.layer.cornerRadius = self.centerView.frame.size.height /2;
    self.centerView.layer.masksToBounds = YES;

    
    if ([[hexString uppercaseString] isEqualToString:@"#FFFFFF"]) {
        self.centerView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.centerView.layer.borderWidth = 1;
    }
}

@end
