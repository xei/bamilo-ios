//
//  NSString+Size.h
//  Jumia
//
//  Created by Jose Mota on 09/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Size)

- (CGSize)sizeForFont:(UIFont *)font withMaxWidth:(CGFloat)width;

@end
