//
//  JACatalogTopView.h
//  Jumia
//
//  Created by Telmo Pinto on 09/02/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAClickableView.h"
#import "JASortingView.h"
#import "JACatalogCollectionViewCell.h"

@protocol JACatalogTopViewDelegate <NSObject>

- (void)sortingButtonPressed;
- (void)filterButtonPressed;
- (void)viewModeChanged;

@end


@interface JACatalogTopView : UIView

+ (JACatalogTopView *)getNewJACatalogTopView;

@property (nonatomic, assign)id<JACatalogTopViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIView *sortingBackView;
@property (weak, nonatomic) IBOutlet UIView *filterBackView;
@property (weak, nonatomic) IBOutlet JAClickableView *sortingButton;
@property (weak, nonatomic) IBOutlet JAClickableView *filterButton;
@property (weak, nonatomic) IBOutlet JAClickableView *viewModeButton;
@property (nonatomic, assign) JACatalogCollectionViewCellType cellTypeSelected;
@property (nonatomic, assign) BOOL filterSelected;

- (void)setSorting:(RICatalogSortingEnum)sorting;
- (void)repositionForWidth:(CGFloat)width;

@end
