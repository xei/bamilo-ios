//
//  FormCustomFiled.h
//  Bamilo
//
//  Created by Ali Saeedifar on 9/30/18.
//  Copyright © 2018 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormElementProtocol.h"

@interface FormCustomFiled : NSObject <FormElementProtocol>
@property (nonatomic, strong) NSString *cellName;
@end
