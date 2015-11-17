//
//  JACatalogTopView.m
//  Jumia
//
//  Created by Telmo Pinto on 09/02/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogTopView.h"

@interface JACatalogTopView()
{
    UIView* _seperatorFilter;
    UIView* _seperatorViewMode;
    UIView* _seperatorBottom;
}

@end

@implementation JACatalogTopView

@synthesize cellTypeSelected = _cellTypeSelected;
- (void)setCellTypeSelected:(JACatalogCollectionViewCellType)cellTypeSelected
{
    _cellTypeSelected = cellTypeSelected;
    
    switch (cellTypeSelected) {
        case JACatalogCollectionViewPictureCell:
            [self.viewModeButton setImage:[UIImage imageNamed:@"view_list"] forState:UIControlStateNormal];
            [self.viewModeButton setImage:[UIImage imageNamed:@"view_list_active"] forState:UIControlStateSelected];
            [self.viewModeButton setImage:[UIImage imageNamed:@"view_list_active"] forState:UIControlStateHighlighted];
            break;
            
            
        case  JACatalogCollectionViewListCell:
            [self.viewModeButton setImage:[UIImage imageNamed:@"view_grid"] forState:UIControlStateNormal];
            [self.viewModeButton setImage:[UIImage imageNamed:@"view_grid_active"] forState:UIControlStateSelected];
            [self.viewModeButton setImage:[UIImage imageNamed:@"view_grid_active"] forState:UIControlStateHighlighted];
            break;
            
        case JACatalogCollectionViewGridCell:
            [self.viewModeButton setImage:[UIImage imageNamed:@"view_singleline"] forState:UIControlStateNormal];
            [self.viewModeButton setImage:[UIImage imageNamed:@"view_singleline_active"] forState:UIControlStateSelected];
            [self.viewModeButton setImage:[UIImage imageNamed:@"view_singleline_active"] forState:UIControlStateHighlighted];
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewModeChanged)]) {
        [self.delegate viewModeChanged];
    }
}

@synthesize filterSelected=_filterSelected;
- (void)setFilterSelected:(BOOL)filterSelected
{
    _filterSelected=filterSelected;
    if (filterSelected) {
        [self.filterButton setImage:[UIImage imageNamed:@"filterIcon_highlighted"] forState:UIControlStateNormal];
        [self.filterButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateNormal];
    } else {
        [self.filterButton setImage:[UIImage imageNamed:@"filterIcon_normal"] forState:UIControlStateNormal];
        [self.filterButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    }
}

+ (JACatalogTopView *)getNewJACatalogTopView
{
    NSArray *xib;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        xib = [[NSBundle mainBundle] loadNibNamed:@"JACatalogTopView_iphone"
                                            owner:nil
                                          options:nil];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        xib = [[NSBundle mainBundle] loadNibNamed:@"JACatalogTopView_ipad"
                                            owner:nil
                                          options:nil];
    }
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JACatalogTopView class]]) {
            [(JACatalogTopView *)obj initializeCatalogTopView];
            return (JACatalogTopView *)obj;
        }
    }
    
    return nil;
}

- (void)initializeCatalogTopView
{
    self.backgroundColor = [UIColor clearColor];
    
    [self.sortingButton setImage:[UIImage imageNamed:@"sortingIcon_normal"] forState:UIControlStateNormal];
    [self.sortingButton setImage:[UIImage imageNamed:@"sortingIcon_highlighted"] forState:UIControlStateSelected];
    [self.sortingButton setImage:[UIImage imageNamed:@"sortingIcon_highlighted"] forState:UIControlStateHighlighted];
    [self.sortingButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.sortingButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateSelected];
    [self.sortingButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateHighlighted];
    [self.sortingButton setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
    [self.sortingButton addTarget:self action:@selector(sortingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.filterButton setImage:[UIImage imageNamed:@"filterIcon_normal"] forState:UIControlStateNormal];
    [self.filterButton setImage:[UIImage imageNamed:@"filterIcon_highlighted"] forState:UIControlStateSelected];
    [self.filterButton setImage:[UIImage imageNamed:@"filterIcon_highlighted"] forState:UIControlStateHighlighted];
    [self.filterButton setTitle:[NSString stringWithFormat:@" %@", STRING_FILTERS] forState:UIControlStateNormal];
    [self.filterButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.filterButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateSelected];
    [self.filterButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateHighlighted];
    [self.filterButton setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
    [self.filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewModeButton addTarget:self action:@selector(viewModeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.cellTypeSelected = JACatalogCollectionViewListCell;
    
    _seperatorFilter = [UIView new];
    [_seperatorFilter setBackgroundColor:JABlack700Color];
    [self addSubview:_seperatorFilter];
    _seperatorViewMode = [UIView new];
    [_seperatorViewMode setBackgroundColor:JABlack700Color];
    [self addSubview:_seperatorViewMode];
    _seperatorBottom = [UIView new];
    [_seperatorBottom setBackgroundColor:JABlack700Color];
    [self addSubview:_seperatorBottom];
}

- (void)repositionForWidth:(CGFloat)width
{
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            width,
                            self.frame.size.height);
    
    CGFloat modeButtonWidth = width*.2f;
    self.viewModeButton.frame = CGRectMake(width - modeButtonWidth,
                                           0,
                                           modeButtonWidth,
                                           self.viewModeButton.frame.size.height);
    
    CGFloat remainingWidth = width - modeButtonWidth;
    CGFloat halfWidth = (remainingWidth)/2;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        

        self.filterBackView.frame = CGRectMake(0,
                                               0,
                                               halfWidth,
                                               self.filterBackView.frame.size.height);
        self.filterButton.frame = CGRectMake(0,
                                             0.0f,
                                             halfWidth,
                                             self.filterButton.frame.size.height);
        
        
        self.sortingBackView.frame = CGRectMake( CGRectGetMaxX(self.filterBackView.frame),
                                                0,
                                                halfWidth,
                                                self.sortingBackView.frame.size.height);
        self.sortingButton.frame = CGRectMake(0,
                                              0.0f,
                                              halfWidth,
                                              self.sortingButton.frame.size.height);
        
        
    }else{
        self.filterButton.frame = CGRectMake(0,
                                             0,
                                             halfWidth,
                                             self.filterButton.frame.size.height);
        
        self.sortingButton.frame = CGRectMake(CGRectGetMaxX(self.filterButton.frame),
                                              0,
                                              halfWidth,
                                              self.sortingButton.frame.size.height);
        
    }
    CGFloat seperatorHeight = 32.f;
    [_seperatorFilter setFrame:CGRectMake(halfWidth,
                                          (self.frame.size.height - 1.f - seperatorHeight)/2.f,
                                          1.f,
                                          seperatorHeight)];
    [_seperatorViewMode setFrame:CGRectMake(self.viewModeButton.frame.origin.x,
                                            (self.frame.size.height - 1.f - seperatorHeight)/2.f,
                                            1.f,
                                            seperatorHeight)];
    [_seperatorBottom setFrame:CGRectMake(0, self.frame.size.height - 1.f,
                                          width, 1.f)];
    
    if (RI_IS_RTL) {
        [self.viewModeButton flipViewPositionInsideSuperview];
        [self.sortingBackView flipViewPositionInsideSuperview];
        [self.sortingButton flipViewPositionInsideSuperview];
        [self.filterBackView flipViewPositionInsideSuperview];
        [self.filterButton flipViewPositionInsideSuperview];
        [_seperatorViewMode flipViewPositionInsideSuperview];
        [_seperatorFilter flipViewPositionInsideSuperview];
        //the sorting button will be aligned when the text is set, but we need to align the filters here
        [self.filterButton flipViewAlignment];
    }
}

- (void)setSorting:(RICatalogSorting)sorting;
{
    NSString* title = [NSString stringWithFormat:@" %@", [kJASORTINGVIEW_OPTIONS_ARRAY objectAtIndex:sorting]];
    [self.sortingButton setTitle:title forState:UIControlStateNormal];
    if (RI_IS_RTL) {
        [self.sortingButton flipViewAlignment];
    }
}

- (void)sortingButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sortingButtonPressed)]) {
        [self.delegate sortingButtonPressed];
    }
}

- (void)filterButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterButtonPressed)]) {
        [self.delegate filterButtonPressed];
    }
}

- (void)viewModeButtonPressed:(id)sender
{
    //reverse selection
    if (self.cellTypeSelected++ == JACatalogCollectionViewPictureCell) {
        self.cellTypeSelected = JACatalogCollectionViewListCell;
    }
}



@end
