//
//  JASearchView.h
//  Jumia
//
//  Created by Telmo Pinto on 15/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASearchView : UIView <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame andText:(NSString *)text;

- (void)resetFrame:(CGRect)frame
       orientation:(UIInterfaceOrientation)orientation;

@end
