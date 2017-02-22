//
//  AlertManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AlertManager.h"
#import "BMLAlertView.h"

#define cORAGNE_COLOR [UIColor withRGBA:247 green:151 blue:32 alpha:1.0f]
#define cDARK_GRAY_COLOR [UIColor withRepeatingRGBA:115 alpha:1.0f]
#define cEXTRA_DARK_GRAY_COLOR [UIColor withRepeatingRGBA:80 alpha:1.0f]

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
    alertView.theme = cORAGNE_COLOR;
    [alertView.contentTextLabel applyStyle:kFontRegularName fontSize:12.0f color:cDARK_GRAY_COLOR];
    [alertView.headerTitleLabel applyStyle:kFontBoldName fontSize:15.0f color:cEXTRA_DARK_GRAY_COLOR];
    [alertView.confirmButton applyStyle:kFontRegularName fontSize:12.0f color:[UIColor whiteColor]];
    [alertView.cancelButton applyStyle:kFontRegularName fontSize:12.0f color:[UIColor blackColor]];
    alertView.headerTitleLabel.textAlignment = NSTextAlignmentCenter;
    alertView.contentTextLabel.textAlignment = alertView.confirmButton.titleLabel.textAlignment = alertView.cancelButton.titleLabel.textAlignment = NSTextAlignmentRight;
}

@end
