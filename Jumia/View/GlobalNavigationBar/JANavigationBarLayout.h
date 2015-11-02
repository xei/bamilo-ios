//
//  JANavigationBarLayout.h
//  Jumia
//
//  Created by Telmo Pinto on 27/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JANavigationBarLayout : NSObject

@property (nonatomic, assign)BOOL showBackButton;
@property (nonatomic, strong)NSString* backButtonTitle;
@property (nonatomic, assign)BOOL showEditButton;
@property (nonatomic, assign)BOOL showMenuButton;

@property (nonatomic, assign)BOOL showLogo;
@property (nonatomic, assign)BOOL showTitleLabel;
@property (nonatomic, strong)NSString* title;
@property (nonatomic, strong)NSString* subTitle;

@property (nonatomic, assign)BOOL showDoneButton;
@property (nonatomic, strong)NSString* doneButtonTitle;
@property (nonatomic, assign)BOOL showCartButton;
@property (nonatomic, assign)BOOL showSearchButton;

@end
