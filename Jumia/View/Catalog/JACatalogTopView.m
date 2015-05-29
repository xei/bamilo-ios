//
//  JACatalogTopView.m
//  Jumia
//
//  Created by Telmo Pinto on 09/02/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JACatalogTopView.h"

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
    
    self.sortingBackView.translatesAutoresizingMaskIntoConstraints = YES;
    self.sortingButton.translatesAutoresizingMaskIntoConstraints = YES;
    [self.sortingButton setImage:[UIImage imageNamed:@"sortingIcon_normal"] forState:UIControlStateNormal];
    [self.sortingButton setImage:[UIImage imageNamed:@"sortingIcon_highlighted"] forState:UIControlStateSelected];
    [self.sortingButton setImage:[UIImage imageNamed:@"sortingIcon_highlighted"] forState:UIControlStateHighlighted];
    [self.sortingButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.sortingButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateSelected];
    [self.sortingButton setTitleColor:UIColorFromRGB(0xffa200) forState:UIControlStateHighlighted];
    [self.sortingButton setFont:[UIFont fontWithName:kFontRegularName size:12.0f]];
    [self.sortingButton addTarget:self action:@selector(sortingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.filterBackView.translatesAutoresizingMaskIntoConstraints = YES;
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
}

- (void)repositionForWidth:(CGFloat)width
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                width,
                                self.frame.size.height);
        
        CGFloat margin = 6.0f;
        
        self.viewModeButton.frame = CGRectMake(width - self.viewModeButton.frame.size.width - margin,
                                               margin,
                                               self.viewModeButton.frame.size.width,
                                               self.viewModeButton.frame.size.height);
        
        CGFloat remainingWidth = width - self.viewModeButton.frame.size.width - margin*3;
        CGFloat halfWidth = (remainingWidth-1)/2;

        self.sortingBackView.frame = CGRectMake(margin,
                                                margin,
                                                halfWidth,
                                                self.sortingButton.frame.size.height);
        self.sortingButton.frame = CGRectMake(self.sortingBackView.frame.size.width - self.sortingButton.frame.size.width,
                                              0.0f,
                                              self.sortingButton.frame.size.width,
                                              self.sortingButton.frame.size.height);
        
        self.filterBackView.frame = CGRectMake(CGRectGetMaxX(self.sortingBackView.frame) + 1.0,
                                               margin,
                                               halfWidth,
                                               self.filterBackView.frame.size.height);
        self.filterButton.frame = CGRectMake(0.0f,
                                             0.0f,
                                             self.filterButton.frame.size.width,
                                             self.filterButton.frame.size.height);
        
    }
    
    if (RI_IS_RTL) {
        [self.viewModeButton flipViewPositionInsideSuperview];
        [self.sortingBackView flipViewPositionInsideSuperview];
        [self.sortingButton flipViewPositionInsideSuperview];
        [self.filterBackView flipViewPositionInsideSuperview];
        [self.filterButton flipViewPositionInsideSuperview];

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
    self.gridSelected = !self.gridSelected;
}



@end
