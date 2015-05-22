//
//  JARatingsViewMedium.m
//  Jumia
//
//  Created by Telmo Pinto on 07/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARatingsViewMedium.h"

@interface JARatingsViewMedium()

@property (weak, nonatomic) IBOutlet UIButton *starButton1;
@property (weak, nonatomic) IBOutlet UIButton *starButton2;
@property (weak, nonatomic) IBOutlet UIButton *starButton3;
@property (weak, nonatomic) IBOutlet UIButton *starButton4;
@property (weak, nonatomic) IBOutlet UIButton *starButton5;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation JARatingsViewMedium

+ (JARatingsViewMedium *)getNewJARatingsViewMedium
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JARatingsViewMedium"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JARatingsViewMedium class]]) {
            return (JARatingsViewMedium *)obj;
        }
    }
    
    return nil;
}

-(void)setNumberOfReviews:(NSInteger)numberOfReviews
{
    self.label.font = [UIFont fontWithName:kFontRegularName size:self.label.font.pointSize];
    [self.label setText:[NSString stringWithFormat:STRING_REVIEWS, [NSString stringWithFormat:@"%ld",(long)numberOfReviews]]];
    [self.label setTextColor:UIColorFromRGB(0xcccccc)];
    [self.label sizeToFit];
    [self.label setFrame:CGRectMake(self.label.frame.origin.x,
                                    (self.frame.size.height - self.label.frame.size.height) / 2,
                                    self.label.frame.size.width,
                                    self.label.frame.size.height)];
    [self.label setHidden:NO];
}

@synthesize rating=_rating;
-(void)setRating:(NSInteger)rating
{
    _rating = rating;
    
    if (RI_IS_RTL)
        rating = 5-rating;
    
    for (UIButton* subview in self.subviews) {
        if (VALID_NOTEMPTY(subview, UIButton)) {
            if (RI_IS_RTL) {
                if (rating >= subview.tag) {
                    subview.selected = NO;
                } else {
                    subview.selected = YES;
                }
            }else
            {
                if (rating < subview.tag) {
                    subview.selected = NO;
                } else {
                    subview.selected = YES;
                }
            }
        }
    }
}

@end
