//
//  JAUndefinedSearchView.h
//  Jumia
//
//  Created by Miguel Chaves on 10/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RISearchSuggestion.h"

@interface JABrandView : UIView

@property (strong, nonatomic) NSString *brandUrl;
@property (strong, nonatomic) NSString *brandName;

@end

@protocol JAUndefinedSearchViewDelegate <NSObject>

@optional
- (void)didSelectProduct:(NSString *)productUrl;

- (void)didSelectBrand:(NSString *)brandUrl
             brandName:(NSString *)brandName;

@end

@interface JAUndefinedSearchView : UIView

@property (weak, nonatomic) id<JAUndefinedSearchViewDelegate>delegate;

+ (JAUndefinedSearchView *)getNewJAUndefinedSearchView;

- (void)setupWithUndefinedSearchResult:(RIUndefinedSearchTerm *)searchTerm
                            searchText:(NSString *)searchText;

- (void)refreshContentSize;

@end