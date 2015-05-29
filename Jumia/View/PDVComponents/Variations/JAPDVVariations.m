//
//  JAPDVVariations.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVVariations.h"

@interface JAPDVVariations ()

@property (weak, nonatomic) IBOutlet UIImageView *separator;

@end

@implementation JAPDVVariations

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

+ (JAPDVVariations *)getNewPDVVariationsSection
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVVariations"
                                                 owner:nil
                                               options:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVVariations~iPad"
                                            owner:nil
                                          options:nil];
    }
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVVariations class]]) {
            return (JAPDVVariations *)obj;
        }
    }
    
    return nil;
}

- (void)setupWithFrame:(CGRect)frame
{
    CGFloat width = frame.size.width - 12.0f;
    
    [self.separator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.separator setWidth:frame.size.width];
    self.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.titleLabel.font.pointSize];
    [self.titleLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            width = frame.size.width - 6.0f;
        }
    }
    
    self.layer.cornerRadius = 5.0f;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
}

@end
