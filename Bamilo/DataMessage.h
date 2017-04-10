//
//  DataMessage.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/10/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"

@interface DataMessage : BaseModel

@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *reason;

@end
