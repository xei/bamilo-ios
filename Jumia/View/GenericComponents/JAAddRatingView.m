//
//  JAAddRatingView.m
//  Jumia
//
//  Created by plopes on 07/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddRatingView.h"

@interface JAAddRatingView()

@property (weak, nonatomic) IBOutlet UILabel  *label;
@property (weak, nonatomic) IBOutlet UIButton *starButton1;
@property (weak, nonatomic) IBOutlet UIButton *starButton2;
@property (weak, nonatomic) IBOutlet UIButton *starButton3;
@property (weak, nonatomic) IBOutlet UIButton *starButton4;
@property (weak, nonatomic) IBOutlet UIButton *starButton5;

@end

@implementation JAAddRatingView

+ (JAAddRatingView *)getNewJAAddRatingView;
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAAddRatingView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAAddRatingView class]]) {
            return (JAAddRatingView *)obj;
        }
    }
    
    return nil;
}

- (void)setupWithOption:(RIRatingsDetails*)option
{
    self.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self.label setTextColor:UIColorFromRGB(0x666666)];
    
    if(VALID_NOTEMPTY(option.title, NSString))
    {
        [self.label setText:option.title];
    }
    
    self.ratingOptions = option.options;
    self.rating = 1;
    
    [self.starButton1 setImage:[UIImage imageNamed:@"img_rating_star_big_full.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self.starButton2 setImage:[UIImage imageNamed:@"img_rating_star_big_full.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self.starButton3 setImage:[UIImage imageNamed:@"img_rating_star_big_full.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self.starButton4 setImage:[UIImage imageNamed:@"img_rating_star_big_full.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self.starButton5 setImage:[UIImage imageNamed:@"img_rating_star_big_full.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
    
    [self starPressed:self.starButton1];
}

- (IBAction)starPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger starPressedTag = button.tag;
    
    self.rating = starPressedTag;
    
    for (UIButton* subview in self.subviews)
    {
        if (VALID_NOTEMPTY(subview, UIButton))
        {
            if (starPressedTag < subview.tag)
            {
                subview.selected = NO;
            } else
            {
                subview.selected = YES;
            }
        }
    }
}

@end
