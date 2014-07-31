//
//  JAMainTeaserView.h
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JAMainTeaserView : UIScrollView

@property (nonatomic, strong)NSOrderedSet* teasers;

- (void)load;

@end
