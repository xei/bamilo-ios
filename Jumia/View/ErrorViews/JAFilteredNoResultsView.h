//
//  JAFilteredNoResultsView.h
//  Jumia
//
//  Created by jcarreira on 19/12/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAFilteredNoResultsView;

@protocol JAFilteredNoResulsViewDelegate <NSObject>

-(void)pressedEditFiltersButton:(JAFilteredNoResultsView *)view;

@end


@interface JAFilteredNoResultsView : UIView

@property(nonatomic, weak) id <JAFilteredNoResulsViewDelegate> delegate;

-(void)setupView:(CGRect)frame;


@end
