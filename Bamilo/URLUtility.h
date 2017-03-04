//
//  URLUtility.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/29/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLUtility : NSObject

+(NSDictionary *)parseQueryString:(NSURL *)url;

@end
