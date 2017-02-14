//
//  JSONVerboseModel.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONModelProtocol <NSObject>

+(instancetype) parseToDataModelWithObjects:(NSArray *)objects;

@end
