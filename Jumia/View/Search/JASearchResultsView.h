//
//  JASearchResultsView.h
//  Jumia
//
//  Created by Telmo Pinto on 05/05/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JASearchResultsViewDelegate <NSObject>

- (void)searchResultsViewWillPop;

@end

@interface JASearchResultsView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<JASearchResultsViewDelegate> delegate;
@property (nonatomic, strong) NSString* searchText;

- (void)reloadFrame:(CGRect)frame;
- (void)searchFor:(NSString*)stringToSearch;

@end
