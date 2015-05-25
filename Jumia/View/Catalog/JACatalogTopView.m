//
//  JACatalogTopView.m
//  Jumia
//
//  Created by Telmo Pinto on 09/02/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogTopView.h"
#import "UIView+Mirror.h"

@interface JACatalogTopView()

@property (weak, nonatomic) IBOutlet UIView *separatorView;

@end

@implementation JACatalogTopView

@synthesize gridSelected=_gridSelected;
- (void)setGridSelected:(BOOL)gridSelected
{
    _gridSelected=gridSelected;
    if (gridSelected) {
        [self.viewModeButton setImage:[UIImage imageNamed:@"listIcon_normal"] forState:UIControlStateNormal];
        [self.viewModeButton setImage:[UIImage imageNamed:@"listIcon_highlighted"] forState:UIControlStateSelected];
        [self.viewModeButton setImage:[UIImage imageNamed:@"listIcon_highlighted"] forState:UIControlStateHighlighted];
    } else {
        [self.viewModeButton setImage:[UIImage imageNamed:@"gridIcon_normal"] forState:UIControlStateNormal];
        [self.viewModeButton setImage:[UIImage imageNamed:@"gridIcon_highlighted"] forState:UIControlStateSelected];
        [self.viewModeButton setImage:[UIImage imageNamed:@"gridIcon_highlighted"] forState:UIControlStateHighlighted];
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
    
    self.sortingButton.translatesAutoresizingMaskIntoConstraints = YES;
    [self.sortingButton setImage:[UIImage imageNamed:@"sortingIcon_normal"] forState:UIControlStateNormal];
    [self.sortingButton setImage:[UIImage imageNamed:@"sortingIcon_highlighted"] forState:UIControlStateSelected];
    [self.sortingButton setImage:[UIImage imageNamed:@"sortingIcon_highlighted"] forState:UIControlStateHighlighted];
    [self.sortingButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.sortingButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateSelected];
    [self.sortingButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateHighlighted];
    [self.sortingButton setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
    [self.sortingButton addTarget:self action:@selector(sortingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.filterButton.translatesAutoresizingMaskIntoConstraints = YES;
    [self.filterButton setImage:[UIImage imageNamed:@"filterIcon_normal"] forState:UIControlStateNormal];
    [self.filterButton setImage:[UIImage imageNamed:@"filterIcon_highlighted"] forState:UIControlStateSelected];
    [self.filterButton setImage:[UIImage imageNamed:@"filterIcon_highlighted"] forState:UIControlStateHighlighted];
    [self.filterButton setTitle:[NSString stringWithFormat:@" %@", STRING_FILTERS] forState:UIControlStateNormal];
    [self.filterButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.filterButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateSelected];
    [self.filterButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateHighlighted];
    [self.filterButton setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
    [self.filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.viewModeButton.translatesAutoresizingMaskIntoConstraints = YES;
    [self.viewModeButton addTarget:self action:@selector(viewModeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.gridSelected = NO;
    
    self.separatorView.translatesAutoresizingMaskIntoConstraints = YES;
    self.separatorView.backgroundColor = UIColorFromRGB(0xcccccc);
    
    if (RI_IS_RTL) {
        [self flipSubviewPositions];
        [self flipSubviewAlignments];
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
    self.gridSelected = !self.gridSelected;
}



@end
