//
//  JAUndefinedSearchView.h
//  Jumia
//
//  Created by Miguel Chaves on 10/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RISearchSuggestion.h"
#import "JAClickableView.h"

@interface JABrandView : JAClickableView

@property (strong, nonatomic) NSString *brandTargetString;
@property (strong, nonatomic) NSString *brandName;

@end

@protocol JAUndefinedSearchViewDelegate <NSObject>

@optional
- (void)didSelectProduct:(NSString *)productTargetString;

- (void)didSelectBrandTargetString:(NSString *)brandTargetString
             brandName:(NSString *)brandName;

@end

@interface JAUndefinedSearchView : UIView

@property (weak, nonatomic) id<JAUndefinedSearchViewDelegate>delegate;

- (void)setupWithUndefinedSearchResult:(RIUndefinedSearchTerm *)searchResult
                            searchText:(NSString *)searchText orientation: (UIInterfaceOrientation)myOrientation;
-(void)didRotate;

@end