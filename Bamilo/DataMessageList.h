//
//  DataMessageList.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/10/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "DataMessage.h"

@protocol DataMessage;

@interface DataMessageList : BaseModel

@property (strong, nonatomic) NSArray<DataMessage> *success;

@end
