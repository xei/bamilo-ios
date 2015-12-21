//
//  JAAddRatingView.m
//  Jumia
//
//  Created by plopes on 07/11/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAAddRatingView.h"

#define KHeight 48.f
#define KLineContentXOffset 16.f
#define KStarSpacing 10.f

@interface JAAddRatingView()

@property (strong, nonatomic) UILabel  *label;
@property (strong, nonatomic) UIButton *starButton1;
@property (strong, nonatomic) UIButton *starButton2;
@property (strong, nonatomic) UIButton *starButton3;
@property (strong, nonatomic) UIButton *starButton4;
@property (strong, nonatomic) UIButton *starButton5;

@end

@implementation JAAddRatingView

-(void)setRating:(NSInteger)rating {
    switch (rating) {
        case 1:
            [self starPressed:self.starButton1];
            break;
        case 2:
            [self starPressed:self.starButton2];
            break;
        case 3:
            [self starPressed:self.starButton3];
            break;
        case 4:
            [self starPressed:self.starButton4];
            break;
        case 5:
            [self starPressed:self.starButton5];
            break;
            
        default:
            break;
    }
}

- (void)setupWithFieldRatingStars:(RIFieldRatingStars*)fieldRatingStars
{
    [self setHeight:KHeight];
    
    self.fieldRatingStars = fieldRatingStars;
    
    if(VALID_NOTEMPTY(fieldRatingStars.title, NSString)) {
        [self.label setText:fieldRatingStars.title];
    }
    
    [self starPressed:self.starButton1];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}

- (IBAction)starPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    //cannot be self.rating beacuse of cyclic call
    _rating = button.tag;
    
    switch (self.rating) {
        case 1:
            [self.starButton1 setSelected:YES];
            [self.starButton2 setSelected:NO];
            [self.starButton3 setSelected:NO];
            [self.starButton4 setSelected:NO];
            [self.starButton5 setSelected:NO];
            break;
            
        case 2:
            [self.starButton1 setSelected:YES];
            [self.starButton2 setSelected:YES];
            [self.starButton3 setSelected:NO];
            [self.starButton4 setSelected:NO];
            [self.starButton5 setSelected:NO];
            break;
            
        case 3:
            [self.starButton1 setSelected:YES];
            [self.starButton2 setSelected:YES];
            [self.starButton3 setSelected:YES];
            [self.starButton4 setSelected:NO];
            [self.starButton5 setSelected:NO];
            break;
            
        case 4:
            [self.starButton1 setSelected:YES];
            [self.starButton2 setSelected:YES];
            [self.starButton3 setSelected:YES];
            [self.starButton4 setSelected:YES];
            [self.starButton5 setSelected:NO];
            break;
            
        case 5:
            [self.starButton1 setSelected:YES];
            [self.starButton2 setSelected:YES];
            [self.starButton3 setSelected:YES];
            [self.starButton4 setSelected:YES];
            [self.starButton5 setSelected:YES];
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

- (UIButton *)starButton1 {
    if (!VALID_NOTEMPTY(_starButton1, UIButton)) {
        _starButton1 = [UIButton new];
        [_starButton1 addTarget:self
                         action:@selector(starPressed:)
               forControlEvents:UIControlEventTouchUpInside];
        UIImage * emptyStar = [self getEmptyStar];
        [_starButton1 setImage:emptyStar forState:UIControlStateNormal];
        [_starButton1 setImage:[self getFilledStar] forState:UIControlStateSelected];
        [_starButton1 setTag:1];
        [_starButton1 setFrame:CGRectMake(KLineContentXOffset,
                                          self.height/2 - emptyStar.size.height/2,
                                          emptyStar.size.width, emptyStar.size.height)];
        [self addSubview:_starButton1];
    }
    return _starButton1;
}

-(UIButton *)starButton2 {
    if (!VALID_NOTEMPTY(_starButton2, UIButton)) {
        _starButton2 = [UIButton new];
        [_starButton2 addTarget:self
                         action:@selector(starPressed:)
               forControlEvents:UIControlEventTouchUpInside];
        UIImage * emptyStar = [self getEmptyStar];
        [_starButton2 setImage:emptyStar forState:UIControlStateNormal];
        [_starButton2 setImage:[self getFilledStar] forState:UIControlStateSelected];
        [_starButton2 setTag:2];
        [_starButton2 setFrame:CGRectMake(CGRectGetMaxX(self.starButton1.frame) + KStarSpacing,
                                          self.height/2 - emptyStar.size.height/2,
                                          emptyStar.size.width, emptyStar.size.height)];
        [self addSubview:_starButton2];
    }
    return _starButton2;
}

-(UIButton *)starButton3 {
    if (!VALID_NOTEMPTY(_starButton3, UIButton)) {
        _starButton3 = [UIButton new];
        [_starButton3 addTarget:self
                         action:@selector(starPressed:)
               forControlEvents:UIControlEventTouchUpInside];
        UIImage * emptyStar = [self getEmptyStar];
        [_starButton3 setImage:emptyStar forState:UIControlStateNormal];
        [_starButton3 setImage:[self getFilledStar] forState:UIControlStateSelected];
        [_starButton3 setTag:3];
        [_starButton3 setFrame:CGRectMake(CGRectGetMaxX(self.starButton2.frame) + KStarSpacing,
                                          self.height/2 - emptyStar.size.height/2,
                                          emptyStar.size.width, emptyStar.size.height)];
        [self addSubview:_starButton3];
    }
    return _starButton3;
}

-(UIButton *)starButton4 {
    if (!VALID_NOTEMPTY(_starButton4, UIButton)) {
        _starButton4 = [UIButton new];
        [_starButton4 addTarget:self
                         action:@selector(starPressed:)
               forControlEvents:UIControlEventTouchUpInside];
        UIImage * emptyStar = [self getEmptyStar];
        [_starButton4 setImage:emptyStar forState:UIControlStateNormal];
        [_starButton4 setImage:[self getFilledStar] forState:UIControlStateSelected];
        [_starButton4 setTag:4];
        [_starButton4 setFrame:CGRectMake(CGRectGetMaxX(self.starButton3.frame) + KStarSpacing,
                                          self.height/2 - emptyStar.size.height/2,
                                          emptyStar.size.width, emptyStar.size.height)];
        [self addSubview:_starButton4];
    }
    return _starButton4;
}

-(UIButton *)starButton5 {
    if (!VALID_NOTEMPTY(_starButton5, UIButton)) {
        _starButton5 = [UIButton new];
        [_starButton5 addTarget:self
                         action:@selector(starPressed:)
               forControlEvents:UIControlEventTouchUpInside];
        UIImage * emptyStar = [self getEmptyStar];
        [_starButton5 setImage:emptyStar forState:UIControlStateNormal];
        [_starButton5 setImage:[self getFilledStar] forState:UIControlStateSelected];
        [_starButton5 setTag:5];
        [_starButton5 setFrame:CGRectMake(CGRectGetMaxX(self.starButton4.frame) + KLineContentXOffset,
                                          self.height/2 - emptyStar.size.height/2,
                                          emptyStar.size.width, emptyStar.size.height)];
        [self addSubview:_starButton5];
    }
    return _starButton5;
}

- (UILabel *)label
{
    if (!VALID_NOTEMPTY(_label, UILabel)) {
        _label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.starButton5.frame), 0,
                                                          self.width - KLineContentXOffset - CGRectGetMaxX(self.starButton5.frame),
                                                          self.height)];
        _label.font = JACaptionFont;//[UIFont fontWithName:kFontRegularName size:self.label.font.pointSize];
        [_label setTextColor:UIColorFromRGB(0x666666)];
        [_label setTextAlignment:NSTextAlignmentRight];
        [self addSubview:_label];
    }
    return _label;
}
@end
