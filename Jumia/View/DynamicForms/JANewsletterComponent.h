//
//  JANewsletterComponent.h
//  Jumia
//
//  Created by Miguel Chaves on 18/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JANewsletterComponent : UIView

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UISwitch *optionSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;

+ (JANewsletterComponent *)getNewJANewsletterComponent;

- (void)setup;

- (void)setupWithField:(RIField *)field;

- (BOOL)isComponentWithKey:(NSString *)key;

- (void)resetValue;

- (NSDictionary *)getValues;

- (void)setValue:(NSString *)value;

- (BOOL)isCheckBoxOn;

- (NSArray *)getOptions;

@end
