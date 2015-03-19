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

+ (JAPDVBundles *)getNewPDVBundleWithSize
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVBundlesWithSize"
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
    self.bundleTitle.font = [UIFont fontWithName:kFontRegularName size:self.bundleTitle.font.pointSize];
    [self.bundleTitle setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
    [self.bundleScrollView setFrame:CGRectMake(self.bundleScrollView.frame.origin.x,
                                               self.bundleScrollView.frame.origin.y,
                                               width,
                                               self.bundleScrollView.frame.size.height)];
    
    self.buynowButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.buynowButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.buynowButton setTitle:STRING_BUY_NOW forState:UIControlStateNormal];
    
    [self.buynowButton setFrame:CGRectMake(width - 6.0f - self.buynowButton.frame.size.width,
                                           self.buynowButton.frame.origin.y,
                                           self.buynowButton.frame.size.width,
                                           self.buynowButton.frame.size.height)];
    
    self.bundleTitle.text = STRING_BUNDLE_TITLE;
    self.totalLabel.font = [UIFont fontWithName:kFontRegularName size:self.totalLabel.font.pointSize];
    self.totalLabel.text = STRING_BUNDLE_TOTAL_PRICE;
    [self.totalLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    
    self.layer.cornerRadius = 5.0f;
}

@end