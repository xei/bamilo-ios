//
//  JANavigationBarLayout.m
//  Jumia
//
//  Created by Telmo Pinto on 27/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANavigationBarLayout.h"

@implementation JANavigationBarLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        //defaults
        self.backButtonTitle=STRING_BACK;
        self.doneButtonTitle=STRING_DONE;
        self.showMenuButton=YES;
        self.showCartButton=YES;
        self.showSearchButton=YES;
        self.showLogo=YES;
    }
    return self;
}

#pragma mark - Automation

#pragma mark Left buttons

@synthesize showBackButton=_showBackButton;
- (void)setShowBackButton:(BOOL)showBackButton
{
    _showBackButton=showBackButton;
    if (showBackButton) {
        self.showEditButton = NO;
        self.showMenuButton = NO;
    }
}
@synthesize backButtonTitle=_backButtonTitle;
- (void)setBackButtonTitle:(NSString *)backButtonTitle
{
    if (VALID_NOTEMPTY(backButtonTitle, NSString)) {
        _backButtonTitle=backButtonTitle;
        self.showBackButton = YES;
    } else {
        _backButtonTitle = STRING_BACK;
    }
}

@synthesize showMenuButton=_showMenuButton;
- (void)setShowMenuButton:(BOOL)showMenuButton
{
    _showMenuButton=showMenuButton;
    if (showMenuButton) {
        self.showBackButton = NO;
        self.showEditButton = NO;
    }
}

@synthesize showEditButton=_showEditButton;
- (void)setShowEditButton:(BOOL)showEditButton
{
    _showEditButton=showEditButton;
    if (showEditButton) {
        self.showBackButton = NO;
        self.showMenuButton = NO;
    }
}


#pragma mark Center

@synthesize showLogo=_showLogo;
- (void)setShowLogo:(BOOL)showLogo
{
    _showLogo=showLogo;
    if (showLogo) {
        self.showTitleLabel = NO;
    }
}

@synthesize showTitleLabel=_showTitleLabel;
-(void)setShowTitleLabel:(BOOL)showTitleLabel
{
    _showTitleLabel=showTitleLabel;
    if (showTitleLabel) {
        self.showLogo = NO;
    }
}
@synthesize title=_title;
- (void)setTitle:(NSString *)title
{
    _title=title;
    if (VALID_NOTEMPTY(title, NSString)) {
        self.showTitleLabel = YES;
    }
}
@synthesize subTitle=_subTitle;
- (void)setSubTitle:(NSString *)subTitle
{
    _subTitle=subTitle;
    if (VALID_NOTEMPTY(subTitle, NSString)) {
        self.showTitleLabel = YES;
    }
}


#pragma mark Right buttons

@synthesize showDoneButton=_showDoneButton;
- (void)setShowDoneButton:(BOOL)showDoneButton
{
    _showDoneButton=showDoneButton;
    if (showDoneButton) {
        self.showCartButton = NO;
        self.showSearchButton = NO;
    }
}
@synthesize doneButtonTitle=_doneButtonTitle;
- (void)setDoneButtonTitle:(NSString *)doneButtonTitle
{
    if (VALID_NOTEMPTY(doneButtonTitle, NSString)) {
        _doneButtonTitle=doneButtonTitle;
        self.showDoneButton = YES;
    } else {
        _doneButtonTitle = STRING_DONE;
    }
}

@synthesize showCartButton=_showCartButton;
-(void)setShowCartButton:(BOOL)showCartButton
{
    _showCartButton=showCartButton;
    if (showCartButton) {
        self.showDoneButton = NO;
    }
}

@synthesize showSearchButton=_showSearchButton;
-(void)setShowSearchButton:(BOOL)showSearchButton
{
    _showSearchButton=showSearchButton;
}

@end
