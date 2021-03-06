//
//  Data.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/10/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "DataMessageList.h"

@interface ResponseData : BaseModel

@property (strong, nonatomic) NSDictionary *metadata;
@property (strong, nonatomic) DataMessageList *messages;
@property (assign, nonatomic) BOOL success;

@end
