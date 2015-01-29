//
//  JAPDVBundles.m
//  Jumia
//
//  Created by epacheco on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JAPDVBundles.h"

@interface JAPDVBundles()

@property (weak, nonatomic) IBOutlet UIImageView *separatorView;


@end

@implementation JAPDVBundles

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}


+ (JAPDVBundles *)getNewPDVBundle
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVBundles"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVBundles class]]) {
            return (JAPDVBundles *)obj;
        }
    }
    
    return nil;
}


- (void)setupWithFrame:(CGRect)frame
{
    self.buynowButton.translatesAutoresizingMaskIntoConstraints = YES;
    CGFloat width = frame.size.width-12.0f;
    
    self.layer.cornerRadius = 5.0f;
    
    [self.separatorView setBackgroundColor: UIColorFromRGB(0xfaa41a)];
    [self.bundleTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
    [self.bundleScrollView setFrame:CGRectMake(self.bundleScrollView.frame.origin.x,
                                               self.bundleScrollView.frame.origin.y,
                                               width, self.bundleScrollView.frame.size.height)];
    [self.bottomView setFrame:CGRectMake(self.bottomView.frame.origin.x,
                                         self.bottomView.frame.origin.y, width, self.bottomView.frame.size.height)];
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [self.buynowButton setFrame:CGRectMake(self.bottomView.frame.size.width - self.buynowButton.frame.size.width - 10.0f,
                                               self.buynowButton.frame.origin.y,
                                               self.buynowButton.frame.size.width,
                                               self.buynowButton.frame.size.height)];
        
    }
    
    //[self.buynowButton setTitle:STRING_BUY_NOW forState:UIControlStateNormal];
}

@end