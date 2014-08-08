//
//  JARatingsView.m
//  Jumia
//
//  Created by Telmo Pinto on 07/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARatingsView.h"

@interface JARatingsView()

@property (weak, nonatomic) IBOutlet UIButton *starButton1;
@property (weak, nonatomic) IBOutlet UIButton *starButton2;
@property (weak, nonatomic) IBOutlet UIButton *starButton3;
@property (weak, nonatomic) IBOutlet UIButton *starButton4;
@property (weak, nonatomic) IBOutlet UIButton *starButton5;

@end

@implementation JARatingsView

+ (JARatingsView *)getNewJARatingsView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JARatingsView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JARatingsView class]]) {
            return (JARatingsView *)obj;
        }
    }
    
    return nil;
}

@synthesize rating=_rating;
-(void)setRating:(NSInteger)rating
{
    _rating = rating;
    
    for (UIButton* subview in self.subviews) {
        if (VALID_NOTEMPTY(subview, UIButton)) {
            
            if (rating < subview.tag) {
                subview.selected = NO;
            } else {
                subview.selected = YES;
            }
        }
    }
}

@end
