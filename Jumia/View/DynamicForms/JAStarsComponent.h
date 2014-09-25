//
//  JAStarsComponent.h
//  Jumia
//
//  Created by Miguel Chaves on 05/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAStarsComponent : UIView

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UIButton *starButton1;
@property (weak, nonatomic) IBOutlet UIButton *starButton2;
@property (weak, nonatomic) IBOutlet UIButton *starButton3;
@property (weak, nonatomic) IBOutlet UIButton *starButton4;
@property (weak, nonatomic) IBOutlet UIButton *starButton5;

@property (strong, nonatomic) RIField *field;
@property (strong, nonatomic) NSMutableDictionary *values;
@property (assign, nonatomic) NSInteger starValue;
@property (strong, nonatomic) NSArray *ratingOptions;
@property (strong, nonatomic) NSString *idRatingType;

+ (JAStarsComponent *)getNewJAStarsComponent;

- (void)setupWithField:(RIField *)field;

@end
