//
//  JAProductInfoRightSubtitleLine.h
//  Jumia
//
//  Created by Jose Mota on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoSingleLine.h"

#define kProductInfoRightSubtitleLineHeight 64

@interface JAProductInfoRightSubtitleLine : JAProductInfoSingleLine

@property (nonatomic, strong) NSString *rightTitle;
@property (nonatomic, strong) NSString *rightSubTitle;

@end
