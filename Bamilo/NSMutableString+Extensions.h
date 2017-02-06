//
//  NSMutableString+Extensions.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (Extensions)

-(void) smartAppend:(NSString *)string;
-(void) smartAppend:(NSString *)string replacer:(NSString *)replacer;

@end
