//
//  LoadingManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadingManager : NSObject

+(instancetype) sharedInstance;

-(void) showLoadingOn:(id)viewcontroller;
-(void) hideLoading;

@end
