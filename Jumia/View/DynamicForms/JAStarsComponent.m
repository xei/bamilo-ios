//
//  JAStarsComponent.m
//  Jumia
//
//  Created by Miguel Chaves on 05/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAStarsComponent.h"

@implementation JAStarsComponent

+ (JAStarsComponent *)getNewJAStarsComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAStarsComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAStarsComponent class]]) {
            return (JAStarsComponent *)obj;
        }
    }
    
    return nil;
}

- (void)setupWithField:(RIField*)field
{
    self.field = field;
    
    self.values = [[NSMutableDictionary alloc] init];
    
    self.layer.cornerRadius = 5.0f;
    
    [self.title setTextColor:UIColorFromRGB(0x666666)];
    
    if(VALID_NOTEMPTY(field.label, NSString))
    {
        [self.title setText:field.label];
    }
}

#pragma mark - Action for button

- (IBAction)changeStars:(id)sender
{
    NSInteger tag = ((UIButton *)sender).tag;
    
    switch (tag) {
        case 1:
        {
            [((UIButton *)[self viewWithTag:1]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:2]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:3]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:4]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:5]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.starValue = 1;
        }
            break;
            
        case 2:
        {
            [((UIButton *)[self viewWithTag:1]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:2]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:3]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:4]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:5]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.starValue = 2;
        }
            break;
            
        case 3:
        {
            [((UIButton *)[self viewWithTag:1]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:2]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:3]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:4]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:5]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.starValue = 3;
        }
            break;
            
        case 4:
        {
            [((UIButton *)[self viewWithTag:1]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:2]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:3]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:4]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:5]) setImage:[self getEmptyStar] forState:UIControlStateNormal];
            self.starValue = 4;
        }
            break;
            
        case 5:
        {
            [((UIButton *)[self viewWithTag:1]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:2]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:3]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:4]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            [((UIButton *)[self viewWithTag:5]) setImage:[self getFilledStar] forState:UIControlStateNormal];
            self.starValue = 5;
        }
            break;
            
        default:
            break;
    }
}

- (UIImage *)getEmptyStar
{
    return [UIImage imageNamed:@"img_rating_star_big_empty"];
}

- (UIImage *)getFilledStar
{
    return [UIImage imageNamed:@"img_rating_star_big_full"];
}

@end
