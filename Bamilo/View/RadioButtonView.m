//
//  RadioButtonView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/11/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "RadioButtonView.h"

#define iRADIO_BUTTON_IMAGE_REGULAR [UIImage imageNamed:@"RadioButtonRegular"]
#define iRADIO_BUTTON_IMAGE_SELECTED [UIImage imageNamed:@"RadioButtonSelected"]

@interface RadioButtonView()
@property (weak, nonatomic) IBOutlet UIButton *buttonView;
@end

@implementation RadioButtonView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    [self.buttonView setBackgroundImage:iRADIO_BUTTON_IMAGE_REGULAR forState:UIControlStateNormal];
    [self.buttonView setBackgroundImage:iRADIO_BUTTON_IMAGE_SELECTED forState:UIControlStateSelected];
}

#pragma mark - RadioButtonViewProtocol
-(void)update:(BOOL)isSelected {
    [self.buttonView setSelected:isSelected];
}

- (IBAction)radioButtonTapped:(id)sender {
    [self.delegate didSelectRadioButton:sender];
}

@end
