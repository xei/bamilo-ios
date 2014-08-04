//
//  JATeaserPageView.h
//  Jumia
//
//  Created by Telmo Pinto on 30/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RITeaserCategory.h"

@interface JATeaserPageView : UIScrollView

@property (nonatomic, strong)RITeaserCategory* teaserCategory;
@property (nonatomic, assign)BOOL isLoaded;

- (void)loadTeasers;

@end
