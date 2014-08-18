//
//  JATeaserView.m
//  Jumia
//
//  Created by Telmo Pinto on 01/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATeaserView.h"

@implementation JATeaserView

-(void)load;
{
    self.backgroundColor = [UIColor clearColor];
    
    if (ISEMPTY(self.teasers)) {
        return;
    }
}

- (void)teaserPressedWithTeaserImage:(RITeaserImage*)teaserImage
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kTeaserNotificationPushWithUrl
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjects:@[teaserImage.url,teaserImage.teaserDescription] forKeys:@[@"url",@"title"]]];
}

@end
