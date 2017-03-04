//
//  NoResultViewController.h
//  Jumia
//
//  Created by aliunco on 1/14/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatalogNoResultViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
    @property (nonatomic, strong) NSString* searchQuery;
@end
