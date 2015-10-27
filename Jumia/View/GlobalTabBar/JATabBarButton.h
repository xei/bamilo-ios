//
//  JATabBarButton.h
//  Jumia
//
//  Created by Telmo Pinto on 26/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"

@interface JATabBarButton : UIView

@property (nonatomic, strong) JAClickableView* clickableView;

@property (nonatomic, assign) BOOL selected;

- (void)setupWithImageName:(NSString*)imageName
      highlightedImageName:(NSString*)highlightedImageName
                     title:(NSString*)title;

- (void)setNumber:(NSInteger)number;

@end
