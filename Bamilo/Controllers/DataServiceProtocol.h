//
//  DataServiceProtocol.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataServiceProtocol <NSObject>

-(void) parse:(id)data forRequestId:(int)rid;

@end
