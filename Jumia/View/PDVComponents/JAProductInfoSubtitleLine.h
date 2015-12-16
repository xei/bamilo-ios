//
//  JAProductInfoSubtitleLine.h
//  Jumia
//
//  Created by Jose Mota on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAProductInfoBaseLine.h"

#define kProductInfoSubtitleLineHeight 64

@interface JAProductInfoSubtitleLine : JAProductInfoBaseLine

@property (nonatomic, strong) NSString *subTitle;

- (void)setImageWithURL:(NSString *)URL;

@end
