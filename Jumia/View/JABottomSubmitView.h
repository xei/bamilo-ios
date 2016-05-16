//
//  JABottomSubmitView.h
//  Jumia
//
//  Created by Jose Mota on 13/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAButton.h"

@interface JABottomSubmitView : UIView

@property (nonatomic, strong) JAButton *button;

+ (CGFloat)defaultHeight;

@end
