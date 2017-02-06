//
//  SearchBaseViewController.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/1/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseViewController.h"

@interface SearchBaseViewController : BaseViewController <UISearchBarDelegate> {
@private
    UISearchBar *_searchBar;
    UIView *_searchBarBackground;
    UIImageView *_searchIconImageView;
}

@end
