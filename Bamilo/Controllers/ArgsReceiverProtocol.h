//
//  ArgsReceiverProtocol.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/21/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ArgsReceiverProtocol <NSObject>

@required
-(void) updateWithArgs:(NSDictionary *)args;

@end
