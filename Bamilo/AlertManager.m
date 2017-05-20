//
//  AlertManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AlertManager.h"
#import "BMLAlertView.h"

@implementation AlertManager

static AlertManager *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AlertManager alloc] init];
    });
    
    return instance;
}

-(void) confirmAlert:(NSString *)title text:(NSString *)text confirm:(NSString *)confirm cancel:(NSString *)cancel completion:(AlertCompletion)completion {
    BMLAlertView *alertView = [[BMLAlertView alloc] initWithStyle:CancelAndConfirmAlert width:0.8];
    alertView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self configure:alertView];
    
    alertView.isClickBackgroundCloseWindow = NO;
    alertView.headerTitleLabel.text = title;
    alertView.contentTextLabel.text = text;
    
    [alertView.confirmButton setTitle:confirm forState:UIControlStateNormal];
    alertView.confirm = ^(){
        if(completion) {
            completion(YES);
        }
    };
    
    [alertView.cancelButton setTitle:cancel forState:UIControlStateNormal];
    alertView.cancel = ^(){
        if(completion) {
            completion(NO);
        }
    };
}

#pragma mark - Helpers
-(void) configure:(RAlertView *)alertView {
    alertView.theme = [Theme color:kColorOrange];
    [alertView.contentTextLabel applyStyle:[Theme font:kFontVariationRegular size:12] color:[Theme color:kColorDarkGray]];
    [alertView.headerTitleLabel applyStyle:[Theme font:kFontVariationBold size:15] color:[Theme color:kColorExtraDarkGray]];
    [alertView.confirmButton applyStyle:[Theme font:kFontVariationRegular size:12] color:[UIColor whiteColor]];
    [alertView.cancelButton applyStyle:[Theme font:kFontVariationRegular size:12] color:[UIColor blackColor]];
    alertView.headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    alertView.contentTextLabel.textAlignment = alertView.confirmButton.titleLabel.textAlignment = alertView.cancelButton.titleLabel.textAlignment = NSTextAlignmentRight;
}

@end
