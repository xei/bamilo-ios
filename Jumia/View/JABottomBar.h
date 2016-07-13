//
//  JABottomBar.h
//  Jumia
//
//  Created by josemota on 10/2/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAButton.h"

@interface JABottomBar : UIView

@property (nonatomic) NSMutableArray *smallButtonsArray;

- (UIButton *)addSmallButton:(UIImage *)image target:(id)target action:(SEL)action;
- (JAButton *)addButton:(NSString*)name target:(id)target action:(SEL)action;
- (JAButton *)addAlternativeButton:(NSString*)name target:(id)target action:(SEL)action;

@end
