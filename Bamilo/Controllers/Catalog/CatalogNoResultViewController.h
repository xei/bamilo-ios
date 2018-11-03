//
//  NoResultViewController.h
//  Jumia
//
//  Created by aliunco on 1/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewController.h"

@interface CatalogNoResultViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString* searchQuery;
- (void)getSuggestions;

@end
