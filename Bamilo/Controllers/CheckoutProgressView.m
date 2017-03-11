//
//  CheckoutProgressView.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutProgressView.h"

@interface CheckoutProgressView ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *stepButtonsCollection;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *stepButtonLabelsCollection;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *stepButtonBackgroundViewsCollection;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *stepButtonBorderViewsCollection;

@end

@implementation CheckoutProgressView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    //Initial Global Setup
    self.backgroundColor = [UIColor whiteColor];
    
    for(UIView *view in self.stepButtonBackgroundViewsCollection) {
        view.backgroundColor = self.backgroundColor;
        view.layer.cornerRadius = view.frame.size.width / 2;
        view.layer.masksToBounds = YES;
    }
    
    //Initial Buttons Setup
    for(UIButton *button in self.stepButtonsCollection) {
        button.layer.cornerRadius = button.frame.size.width / 2;
        button.layer.masksToBounds = YES;
        [button applyStyle:[Theme font:kFontVariationLight size:12] color:[Theme color:kColorDarkGray]];
    }
    
    //Initial Button Labels Setup
    for(UILabel *buttonLabel in self.stepButtonLabelsCollection) {
        [buttonLabel setBackgroundColor:[UIColor whiteColor]];
        [buttonLabel applyStyle:[Theme font:kFontVariationBold size:8] color:[Theme color:kColorDarkGray]];

        
        switch (buttonLabel.tag) {
            case 1:
                buttonLabel.text = STRING_LABEL_ADDRESS;
            break;
                
            case 2:
                buttonLabel.text = STRING_LABEL_REVIEW;
            break;
                
            case 3:
                buttonLabel.text = STRING_LABEL_PAY;
            break;
        }
    }
    
    //Initial Button Borders Setup
    for(UIView *borderView in self.stepButtonBorderViewsCollection) {
        borderView.layer.cornerRadius = borderView.frame.size.width / 2;
        borderView.layer.masksToBounds = YES;
    }
}

-(void)updateButton:(int)tag toModel:(CheckoutProgressViewButtonModel *)model {
    UIButton *targetButton = [[self.stepButtonsCollection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag == %d", tag]] lastObject];
    
    if(targetButton) {
        [self updateButton:targetButton forModel:model];
    }
}

- (IBAction)stepButtonTapped:(id)sender {
    [self.delegate checkoutProgressViewButtonTapped:sender];
}

#pragma mark - Private Methods
-(void) updateButton:(UIButton *)button forModel:(CheckoutProgressViewButtonModel *)model {
    
    UILabel *buttonLabel = [self getLabelForButton:button];
    UIView *borderView = [self getBorderViewForButton:button];
    
    switch (model.state) {
        case CHECKOUT_PROGRESSVIEW_BUTTON_STATE_PENDING:
            [button setEnabled:NO];
            [button.layer setBorderColor:[UIColor whiteColor].CGColor];
            [button.layer setBackgroundColor:[Theme color:kColorExtraLightGray].CGColor];
            [button setImage:nil forState:UIControlStateNormal];
            [button setTitle:[[@(button.tag) stringValue] numbersToPersian] forState:UIControlStateNormal];
            [borderView setBackgroundColor:[Theme color:kColorLightGray]];
            [buttonLabel setHidden:YES];
        break;
            
        case CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE:
            [button setEnabled:NO];
            [button.layer setBorderColor:[Theme color:kColorGreen].CGColor];
            [button.layer setBackgroundColor:[UIColor whiteColor].CGColor];
            [button setImage:nil forState:UIControlStateNormal];
            [button setTitle:[[@(button.tag) stringValue] numbersToPersian] forState:UIControlStateNormal];
            [borderView setBackgroundColor:[Theme color:kColorGreen]];
            [buttonLabel setHidden:NO];
        break;
            
        case CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE:
            [button setEnabled:YES];
            [button.layer setBorderColor:[Theme color:kColorGreen].CGColor];
            [button.layer setBackgroundColor:[Theme color:kColorGreen].CGColor];
            [button setTitle:nil forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"WhiteThinTick"] forState:UIControlStateNormal];
            [borderView setBackgroundColor:[Theme color:kColorGreen]];
            [buttonLabel setHidden:YES];
        break;
    }
}

#pragma mark - Helpers
-(UILabel *) getLabelForButton:(UIButton *)button {
    return [[self.stepButtonLabelsCollection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag == %d", 10 + button.tag]] lastObject];
}

-(UIView *) getBorderViewForButton:(UIButton *)button {
    return [[self.stepButtonBorderViewsCollection filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag == %d", 110 + button.tag]] lastObject];
}

@end
