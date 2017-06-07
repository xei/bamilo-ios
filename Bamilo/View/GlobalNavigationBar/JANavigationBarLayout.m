//
//  JANavigationBarLayout.m
//  Jumia
//
//  Created by Telmo Pinto on 27/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANavigationBarLayout.h"

@implementation JANavigationBarLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        self.doneButtonTitle = STRING_DONE;
//        self.showMenuButton = YES;
        self.showCartButton = YES;
        self.showSearchButton = YES;
        self.showLogo = YES;
        self.showSeparatorView = YES;
    }
    return self;
}

#pragma mark - Automation
#pragma mark Left buttons

- (void)setShowBackButton:(BOOL)showBackButton {
    _showBackButton=showBackButton;
    if (showBackButton) {
        self.showEditButton = NO;
//        self.showMenuButton = NO;
    }
}

- (void)setBackButtonTitle:(NSString *)backButtonTitle {
    if (backButtonTitle.length) {
        _backButtonTitle=backButtonTitle;
        self.showBackButton = YES;
    }
}

- (void)setEditButtonTitle:(NSString *)editButtonTitle {
    if (editButtonTitle.length) {
        _editButtonTitle = editButtonTitle;
        self.showEditButton = YES;
    }
}

//- (void)setShowMenuButton:(BOOL)showMenuButton {
//    _showMenuButton=showMenuButton;
//    if (showMenuButton) {
//        self.showBackButton = NO;
//        self.showEditButton = NO;
//    }
//}

- (void)setShowEditButton:(BOOL)showEditButton {
    _showEditButton=showEditButton;
    if (showEditButton) {
        self.showBackButton = NO;
//        self.showMenuButton = NO;
    }
}


#pragma mark Center

- (void)setShowLogo:(BOOL)showLogo {
    _showLogo=showLogo;
    if (showLogo) {
        self.showTitleLabel = NO;
    }
}

-(void)setShowTitleLabel:(BOOL)showTitleLabel {
    _showTitleLabel=showTitleLabel;
    if (showTitleLabel) {
        self.showLogo = NO;
    }
}

- (void)setTitle:(NSString *)title {
    _title=title;
    if (title.length) {
        self.showTitleLabel = YES;
    }
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = [subTitle numbersToPersian];
    if (subTitle.length) {
        self.showTitleLabel = YES;
    }
}


#pragma mark Right buttons


- (void)setShowDoneButton:(BOOL)showDoneButton {
    _showDoneButton=showDoneButton;
    if (showDoneButton) {
        self.showCartButton = NO;
        self.showSearchButton = NO;
    }
}

- (void)setDoneButtonTitle:(NSString *)doneButtonTitle {
    if (doneButtonTitle.length) {
        _doneButtonTitle=doneButtonTitle;
        self.showDoneButton = YES;
    } else {
        _doneButtonTitle = STRING_DONE;
    }
}


- (void)setShowCartButton:(BOOL)showCartButton {
    _showCartButton=showCartButton;
    if (showCartButton) {
        self.showDoneButton = NO;
    }
}


- (void)setShowSearchButton:(BOOL)showSearchButton {
    _showSearchButton=showSearchButton;
}

@end
