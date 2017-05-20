//
//  FormHeaderModel.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/6/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormElementProtocol.h"

@interface FormHeaderModel : NSObject <FormElementProtocol>

@property (nonatomic, copy) NSString *headerString;

-(instancetype) initWithHeaderTitle:(NSString *)headerString;

@end
