//
//  AlertManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/16/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AlertCompletion)(BOOL OK);

@interface AlertManager : NSObject

+(instancetype) sharedInstance;

-(void) confirmAlert:(NSString *)title text:(NSString *)text confirm:(NSString *)confirm cancel:(NSString *)cancel completion:(AlertCompletion)completion;

@end
